import FirebaseAuth

protocol ContactCellAddFriendDelegate: AnyObject {
  func addNewFriend(_: ContactCell, completion: @escaping (Error?) -> Void)
  func animationComplete(_: Bool)
}
