class Friend: Codable {
  var id: String
  var firstName: String
  var lastName: String
  var username: String
  
  init(id: String, firstName: String, lastName: String, username: String) {
    self.id = id
    self.firstName = firstName
    self.lastName = lastName
    self.username = username
  }
  
  init(profile: Profile) {
    self.id = profile.id!
    self.firstName = profile.firstName
    self.lastName = profile.lastName
    self.username = profile.username
  }
}

extension Friend: Equatable {
  static func ==(lhs: Friend, rhs: Friend) -> Bool {
    return lhs.id == rhs.id
  }
}
