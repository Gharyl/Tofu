import FirebaseFirestoreSwift

class Profile: Codable {
  @DocumentID
  var id:        String?
  var username:  String
  var firstName: String
  var lastName:  String
  var status:    String
  var chatIDs:   [String]
  var friends:   [Friend]
  var friendRequests: [FriendRequest]
  // Array containing user's first name, last name, and username for querying purposes
  var keywords: [String]
  
  init(
    id:           String = UUID().uuidString,
    username:     String,
    firstName:    String,
    lastName:     String,
    status:       String = "",
    chatIDs:      [String] = [],
    friends:      [Friend] = [],
    friendRequests: [FriendRequest] = []
  ){
    self.id           = id
    self.username     = username
    self.firstName    = firstName
    self.lastName     = lastName
    self.status       = status
    self.chatIDs      = chatIDs
    self.friends      = friends
    self.friendRequests = friendRequests
    self.keywords     = [self.firstName, self.lastName, self.username]
  }
}

extension Profile {
  var sentRequests:     [FriendRequest] { friendRequests.filter{ $0.fromUser.id == id } }
  var receivedRequests: [FriendRequest] { friendRequests.filter{ $0.toUser.id   == id } }
}
