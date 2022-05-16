import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Foundation

class FirebaseCommunicator {
  let db      = Firestore.firestore()
  let storage = Storage.storage()
  let auth    = FirebaseAuth.Auth.auth()
  var user: User? { Auth.auth().currentUser }
  var userModel: UserModel?
  
  var shouldObserveNewChat: Bool = false {
    didSet {
      if shouldObserveNewChat {
        observeChats { error in
          if let error = error {
            print("Error observing chats in 'shouldObserveNewChat'")
          }
        }
      }
    }
  }
  
  var chatIDCount: Int = 0 {
    didSet {
      shouldObserveNewChat = oldValue < chatIDCount }
  }
  
  private var chatDB: CollectionReference { db.collection("chats") }
  private var userDB: CollectionReference { db.collection("users") }
  private var friendRequestDB: CollectionReference { db.collection("friend_requests") }
  private var batch:  WriteBatch { db.batch() }
  
  private var firebaseChatListener: ListenerRegistration?
  private var firebaseProfileListener: ListenerRegistration?
  
  enum FBError: String, Error {
    case FIELD_EMPTY = "Email, password, or your name cannot be empty"
    case USER_NOT_FOUND = "User Object Is Empty"
    case CHAT_EMPTY   = "This chat contains no messages"
    case PROFILE_FAIL_CAST = "Failed to cast Document to Profile Object"
    case SNAPSHOT_FAILED = "DocumentSnapshot failed to retrieve"
    
    var description: String { self.rawValue }
  }
  
  func createUser(
    withEmail email:   String?,
    andPassword password: String?,
    firstName:    String?,
    lastName:     String?,
    imageData:    UIImage?,
    username:     String?,
    completed: @escaping (Error?) -> Void
  ) {
    guard let safeEmail     = email,
          let safePassword  = password,
          let safeFirstname = firstName,
          let safeLastName  = lastName,
          let safeUername   = username
    else {
      completed(FBError.FIELD_EMPTY)
      return
    }
    
    Task {
      do {
        let authenticatedUser = try await Auth.auth().createUser(withEmail: safeEmail, password: safePassword)
        let safeID = authenticatedUser.user.uid
        let newProfile = Profile(id: safeID, username: safeUername, firstName: safeFirstname, lastName: safeLastName, chatIDs: [])
        try userDB.document(safeID).setData(from: newProfile)
        let newUserModel = UserModel(profile: newProfile)
        userModel = newUserModel
        completed(nil)
      } catch  {
        print("errlr: \(error.localizedDescription)")
        completed(error)
      }
    }
  }
  
  func signinUser(
    withEmail   email:    String,
    andPassword password: String
  ) async -> Error? {
    do {
      let authenticatedUser = try await Auth.auth().signIn(withEmail: email, password: password)
      
      let safeID = authenticatedUser.user.uid
      await fetchUser(for: safeID)
      
      guard let chatIDsCount = userModel?.chatIDs.count else { return FBError.CHAT_EMPTY }
      self.chatIDCount = chatIDsCount
      
      observeProfile()
      return nil
    } catch let error {
      print("Error in catch block \(error.localizedDescription)")
      return error
    }
  }
  
  @discardableResult
  func fetchUser(for id: String, isCurrentUser: Bool = true) async -> Profile? {
    do {
      let documentSnapshot = try await userDB.document(id).getDocument()
      guard let profile: Profile = try? documentSnapshot.data(as: Profile.self) else {
        print("Failure to unwrap Profile data")
        return nil
      }
      if isCurrentUser {
        let newUserModel = UserModel(profile: profile)
        userModel = newUserModel
      }
      return profile
    } catch {
      print("Async error")
      return nil
    }
  }
  
  func sendFriendRequest(
    participantID id: String,
    firstName newFriendFirstName: String,
    lastName newFriendLastName: String,
    username newFriendUsername: String,
    completed: @escaping (Error?) -> Void
  ) {
    guard let currentUserModel = userModel else { return print("Please log in again") }
    
    let toUserID = id
    let toUser: Friend   = Friend(id: toUserID,firstName: newFriendFirstName, lastName: newFriendLastName, username: newFriendUsername)
    let fromUser: Friend = Friend(profile: currentUserModel.currentProfile)
    
    let friendRequest: FriendRequest = FriendRequest(toUser: toUser, fromUser: fromUser)
    do {
      try friendRequestDB
        .document("\(friendRequest.id!)")
        .setData(from: friendRequest)
      { error in
        if let error = error {
          completed(error)
        } else {
          do {
            let encodedFriendRequest = try Firestore.Encoder().encode(friendRequest)
            let fromUser = self.userDB.document(toUserID)
            let toUser   = self.userDB.document(currentUserModel.id)
            
            let batch = self.batch
            batch.updateData(
              ["friendRequests": FieldValue.arrayUnion([encodedFriendRequest])],
              forDocument: fromUser)
            batch.updateData(
              ["friendRequests": FieldValue.arrayUnion([encodedFriendRequest])],
              forDocument: toUser)
            batch.commit { error in
              if let error = error {
                print("Batch commit error \(error.localizedDescription)")
              }
            }
            
            completed(nil)
          } catch {
            completed(error)
          }
        }
      }
    } catch {
      completed(error)
    }
  }
  
  func updateFriendRequests(friendRequest: FriendRequest, isAccepted: Bool, completion: @escaping (Error?) -> Void ) {
    let batch = batch
    let fromUser: DocumentReference = userDB.document(friendRequest.fromUser.id)
    let toUser:   DocumentReference = userDB.document(friendRequest.toUser.id)
    let respondedRequest: DocumentReference = friendRequestDB.document(friendRequest.id!)
    
    guard let encodedFriendRequest = try? Firestore.Encoder().encode(friendRequest) else { return print("Encoding failed in updatedFriendRequest()")}
    
    Task {
      // Removing FriendRequest from both parties
      batch.updateData(
        ["friendRequests": FieldValue.arrayRemove([encodedFriendRequest])],
        forDocument: fromUser)
      batch.updateData(
        ["friendRequests": FieldValue.arrayRemove([encodedFriendRequest])],
        forDocument: toUser)
      // Removing FriendRequest from database
      batch.deleteDocument(respondedRequest)
      // Adding both parties to each other's friends list
      for (id, reference) in zip([friendRequest.fromUser.id, friendRequest.toUser.id], [toUser, fromUser]) {
        guard let profile = await fetchUser(for: id, isCurrentUser: false) else {
          print("Profile didnt' return")
          return
        }
        guard let encodedFriend = try? Firestore.Encoder().encode(Friend(profile: profile)) else {
          print("Profile encode error in updateFriendRequest")
          return
        }
        if isAccepted {
          batch.updateData(["friends": FieldValue.arrayUnion([encodedFriend])], forDocument: reference)
        }
      }
      do {
        _ = try await batch.commit()
        print("finished batch commit")
      } catch {
        print(error.localizedDescription)
      }
    }
  }
  
  func uploadImage(with imageData: Data, _ metaData: StorageMetadata? = nil) {
    guard let safeID = userModel?.id else {
      print("Please log in again")
      return
    }
    
    let storageRef = storage.reference().child("profileImages/\(safeID)")
    // Saving to firebase storage
    storageRef.putData(imageData, metadata: metaData) { metaData, error in
      if let error = error {
        print("Upload failed. \(error.localizedDescription)")
        return
      }
    }
  }
  
  
  func downloadImage(withID id: String, completion: @escaping (Data?) -> Void) {
    // Check if we already downloaded this image
    // If yes, retrieve it from the cache and skip Firebase request
    
    let storageRef = storage.reference().child("profileImages/\(id)")
    storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
      if let error = error {
        print("No image found on Firebase? \(error)")
        completion(nil)
      } else {
        completion(data!)
      }
    }
    
  }
  
  func createNewChat(
    with friends: [Friend],
    and firstMessage: String,
    completed: @escaping (Result<Chat,Error>) -> Void
  ) {
    Task {
      // extracting all participants in this Chat, including the sender
      guard let userModel = userModel else { return }
      let batch = batch
      var participants = friends
      participants.append(Friend(profile: userModel.currentProfile))
      
      let newMessage = ChatMessage(messageBody: firstMessage, messageSender: userModel.id, date: Date())
      let newChat = Chat(
        participants: participants,
        messages:     [newMessage]
      )
      
      do {
        try chatDB.document(newChat.id!).setData(from: newChat) // Create chat document
        participants.forEach { participant in   // Update each participant 'chatIDs' field
          let id = participant.id
          let user = self.userDB.document(id)
          batch.updateData(
            ["chatIDs": FieldValue.arrayUnion([newChat.id!])],
            forDocument: user
          )
        }
        try await batch.commit()
        
        completed(.success(newChat))
      } catch {
        completed(.failure(error))
      }
    }
  } // End of createChat()
  
  func updateChat(
    forChatID chatID:    String,
    newMessage message: String,
    completed: @escaping (Error?) -> Void
  ) {
    guard let userModel = userModel else { return print("Please log in again") }
    
    let newMessage = ChatMessage(messageBody: message, messageSender: userModel.id, date: Date())
    let encodedMessage = try! Firestore.Encoder().encode(newMessage)
    
    Task {
      let batch = batch
      let chat = chatDB.document(chatID)
      batch.updateData(["messages": FieldValue.arrayUnion([encodedMessage])], forDocument: chat)
      do {
        try await batch.commit()
        completed(nil)
      } catch {
        print("Error updating chat: \(error.localizedDescription)")
        completed(error)
      }
    }
  }
  
  func updateChatMessageReaction(_ chatID: String, _ chatMessage: ChatMessage, completion: @escaping (Error?) -> Void) {
    Task {
      guard let userModel = userModel else {
        print("in updateChatMessageReaction(), chat failed to cast")
        return
      }
      
      if let chatToUpdate = userModel.currentChats.first(where: { $0.id == chatID }) {
        do {
          let messageArrayCopy: [ChatMessage] = chatToUpdate.messages.map({ $0.copy() as! ChatMessage })
          guard let messageToUpdaate: ChatMessage = messageArrayCopy.first(where: { $0.id == chatMessage.id }) else {
            print("Cannot find corresponding ChatMessage in the array")
            return
          }
          messageToUpdaate.reactions = chatMessage.reactions
          // Need to encode each Codable object, instead of an array of Codable objects
          let encodedMessaageArray: [[String: Any?]] = messageArrayCopy.map{ object in
            if let encodedObject = try? Firestore.Encoder().encode(object) {
              return encodedObject
            }
            print("Failed to encode ChatMessage")
            return ["": nil]
          }
          
          try await chatDB.document(chatID).updateData([
            "messages": encodedMessaageArray
          ])
          completion(nil)
        } catch let error {
          completion(error)
        }
      }
    }
  }
  
  func fetchChats(for ids: [String]) async {
    // Querying 'FieldPath.documentID()' has a return limit of 10
    // When the user contains more than 10 Chat objects, this query needs to be repeated
    do {
      let querySnapshot = try await chatDB.whereField(FieldPath.documentID(), in: ids).getDocuments()
      let chats: [Chat] = querySnapshot.documents.compactMap{ document in
        return try? document.data(as: Chat.self)
      }
      self.userModel?.currentChats = chats
    } catch {
      print("Error fetching chats: \(error.localizedDescription)")
    }
  }
  
  func fetchUsers(for queryStr: String, completed: @escaping (Result<[Friend], Error>) -> Void) {
    userDB
      .whereField("keywords", arrayContainsAny: [queryStr])
      .getDocuments { querySnapshot, error in
        if let error = error {
          print("Error while searching for user: \(error.localizedDescription)")
          return
        }
        
        guard let document = querySnapshot else {
          print("QuerySnapshot is nil")
          return
        }
        let users: [Friend] = document.documents
          .compactMap { return try? $0.data(as: Profile.self) }
          .map { Friend.init(profile: $0) }
        
        completed(.success(users))
      }
  }
  
  private func observeProfile() {
    guard let safeID = userModel?.id else {
      print("no safe id")
      return
    }
    
    firebaseProfileListener?.remove()
    
    firebaseProfileListener = userDB.document(safeID).addSnapshotListener { snapshot, error in
      if let error = error {
        print("Error in observing profile \(error.localizedDescription)")
        return
      }
      guard let safeDocument = snapshot else {
        return
      }
      guard let profile = try? safeDocument.data(as: Profile.self) else {
        return
      }
      guard let userModel = self.userModel else { return print("Please log in again") }
      
      userModel.currentProfile = profile
      self.chatIDCount = profile.chatIDs.count
    }
  }
  
  private func observeChats(completion: @escaping (Error?) -> Void ) {
    guard let userModel = userModel else {
      return print("Please log in again")
    }
    
    if userModel.chatIDs.isEmpty {
      print("No chatID found")
      return
    }
    
    // **IMPORTANT**
    // Firebase's snapshotListener will be registered on the physical app and ALSO ON THE FIREBASE SERVER
    // If you remove snapshotListener's reference by setting it to nil, ie. 'firebaseChatListener = nil',
    // you simply remove the reference in your app; the reference still exists on Firebase's server
    // Therefore, you must remove it from the Firebase server FIRST in any scenario
    firebaseChatListener?.remove()
    firebaseChatListener = chatDB.whereField(FieldPath.documentID(), in: userModel.chatIDs).addSnapshotListener { querySnapshot, error in
      if let error = error {
        completion(error)
        return
      }
      guard let safeQuerySnapshot = querySnapshot else {
        completion(FBError.SNAPSHOT_FAILED)
        return
      }
      let chats = safeQuerySnapshot.documents.compactMap{ data in
        try? data.data(as: Chat.self)
      }
      
      // Only accept after database has been updated
      if !safeQuerySnapshot.metadata.hasPendingWrites {
        userModel.currentChats = chats
        completion(nil)
      }
    }
  }
  
  init() {
    ImageManager.shared.firebase = self
  }
}
