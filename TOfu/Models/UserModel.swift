class UserModel {
  var firebase: FirebaseCommunicator?
  
  private var profile: Observer<Profile>!
  private var chats: Observer<[Chat]> = Observer([])
  
  var currentProfile: Profile {
    get { profile.object }
    set { profile.object = newValue }
  }
  
  var currentChats: [Chat] {
    get { chats.object }
    set { chats.object = newValue }
  }
  
  var id: String {
    get { profile.object.id! }
  }
  
  var chatIDs: [String] {
    get { profile.object.chatIDs }
  }
  
  var allRequests: [FriendRequest] {
    get { profile.object.friendRequests }
  }
  
  var sentRequests: [FriendRequest] {
    get { profile.object.sentRequests }
  }
  
  var receivedRequests: [FriendRequest] {
    get { profile.object.receivedRequests }
  }
  
  var friends: [Friend] {
    get { profile.object.friends }
  }
  
  var fullName: String {
    get { firstName + " " + lastName }
  }
  
  var firstName: String {
    get { profile.object.firstName }
  }
  
  var lastName: String {
    get { profile.object.lastName }
  }
  
  var username: String {
    get { profile.object.username }
  }
  
  var status: String {
    get { profile.object.status }
    set { profile.object.status = newValue }
  }
  
  func subscribeToChats(callback: @escaping ([Chat]) -> Void) {
    chats.observe(callback)
  }
  
  func subscribeToProfile(callback: @escaping (Profile) -> Void) {
    profile.observe(callback)
  }
  
  func removeChatSubscription() {
    chats.pop()
  }
  
  func removeProfileSubscription() {
    profile.pop()
  }
  
  init(profile: Profile) {
    print("New UserModel created")
    self.profile = Observer(profile)
  }
  
  init(_ error: Error?) {
    print("ERROR CURRENTUSERMODEL")
  }
}


