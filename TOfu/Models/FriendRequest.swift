import FirebaseFirestoreSwift

class FriendRequest: Codable {
  @DocumentID
  var id: String?
  // True: Friend request is accepted
  // False: Friend request is denied
  // Nil: Pending
  var isAccepted: Bool? = nil
  let fromUser: Friend
  let toUser: Friend
  
  init(toUser: Friend, fromUser: Friend, id: String = UUID().uuidString) {
    self.id = id
    self.toUser   = toUser
    self.fromUser = fromUser
  }
}

extension FriendRequest: Equatable {
  static func == (lhs: FriendRequest, rhs: FriendRequest) -> Bool {
    return (
      lhs.fromUser.id == rhs.fromUser.id &&
      lhs.toUser.id   == rhs.toUser.id
    )
  }
}
