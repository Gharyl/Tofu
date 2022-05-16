import UIKit

class ChatVCCoordinator: Coordinator {
  var navigation: UINavigationController
  var firebase: FirebaseCommunicator
  var childCoordinators: [Coordinator] = []
  var parentCoordinator: Coordinator?
  var chat: Chat!
  
  private lazy var chatVC: ChatViewController = {
    let chatVC = ChatViewController(coordinator: self, db: firebase)
    return chatVC
  }()
  
  func setup() {
    chatVC.chat = chat
    navigation.interactivePopGestureRecognizer?.delegate = chatVC
    navigation.pushViewController(chatVC, animated: true)
    setupObserver()
  }
  
  func restart() {
    
  }
    
  func returnToPreviousView() {
    navigation.popViewController(animated: true)
  }
  
  func viewDidPop() {
    userModel.removeChatSubscription()
    parentCoordinator?.childViewDidPop()
  }
  
  func childViewDidPop() {
    childCoordinators.removeLast()
  }
  
  func setupObserver() {
    userModel.subscribeToChats { [weak self] chats in
      guard let self = self else { return }
      if let updatedChat = chats.filter({ $0.id == self.chat.id }).first {
        self.chatVC.chat = updatedChat
      }
    }
  }
  
  required init(_ navigation: UINavigationController, _ firebase: FirebaseCommunicator) {
    self.navigation = navigation
    self.firebase   = firebase
  }
}

extension ChatVCCoordinator: ChatVCCoordinating {
  func showMessageReactionVC(_ messageView: UIView, _ chatVCView: UIImage, _ cellFrame: CGRect, _ chatMessage: ChatMessage) {
    let messageReactionVCCoordinator = MessageReactionVCCoordinator(navigation, firebase)
    messageReactionVCCoordinator.parentCoordinator = self
    messageReactionVCCoordinator.selectedCellValues = (messageView, cellFrame, chatMessage)
    messageReactionVCCoordinator.chatID = self.chat.id
    messageReactionVCCoordinator.chatVCView = chatVCView
    messageReactionVCCoordinator.setup()
  
    childCoordinators.append(messageReactionVCCoordinator)
  }
}

protocol ChatVCCoordinating {
  func showMessageReactionVC(_: UIView, _: UIImage, _: CGRect, _: ChatMessage)
}
