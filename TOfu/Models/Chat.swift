import FirebaseFirestoreSwift

class Chat: Codable {
  // @DocumentID from FirebaseFirestoreSwift
  // @DocumentID matches Firebase's document ID 
  @DocumentID var id: String?

  var participants: [Friend]
  var messages: [ChatMessage]
  // get-only
  var previewMessage: String { messages.last!.messageBody }
  var latestActivityDate: Date { messages.last!.messageDate }
  
  init(
    participants: [Friend],
    messages: [ChatMessage]
  ) {
    self.id           = UUID().uuidString
    self.participants = participants
    self.messages     = messages
  }
}
