import FirebaseFirestoreSwift

class ChatMessage: Codable {
  let id: String
  let messageBody: String
  let messageSenderID: String
  let messageDate: Date
  // For animation and 'Read' status
  var displayed: Bool
  var reactions: [ReactionPopUpMenu.ReactionType] = []
  
  init(messageBody: String, messageSender: String, date: Date, id: String = UUID().uuidString, reactions: [ReactionPopUpMenu.ReactionType] = []) {
    self.id            = id
    self.messageBody   = messageBody
    self.messageSenderID = messageSender
    self.messageDate   = date
    self.displayed     = false
    self.reactions     = reactions
  }
}

extension ChatMessage: Equatable {
  static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
    return lhs.id == rhs.id && lhs.reactions == rhs.reactions
  }
}

extension ChatMessage: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(reactions)
  }
}

extension ChatMessage: NSCopying {
  func copy(with zone: NSZone? = nil) -> Any {
    ChatMessage(
      messageBody: self.messageBody,
      messageSender: self.messageSenderID,
      date: self.messageDate,
      id: self.id,
      reactions: self.reactions
    )
  }
}
