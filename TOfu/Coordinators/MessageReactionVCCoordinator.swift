import UIKit

class MessageReactionVCCoordinator: NSObject, Coordinator {
  var navigation: UINavigationController
  var firebase: FirebaseCommunicator
  var childCoordinators: [Coordinator] = []
  weak var parentCoordinator: Coordinator?
  var selectedCellValues: (UIView, CGRect, ChatMessage)?
  var chatID: String?
  var chatVCView: UIImage?
  
  func setup() {
    guard let selectedCellValues = selectedCellValues,
          let userModel = firebase.userModel
    else {
      print("\(self) needs a MessageCell object")
      return
    }
    
    let isSender = userModel.id == selectedCellValues.2.messageSenderID
    let messageReactionVC = MessageReactionViewController()
    messageReactionVC.db = firebase
    messageReactionVC.coordinator = self
    messageReactionVC.selectedChatID = chatID
    messageReactionVC.transitioningDelegate = self
    messageReactionVC.modalPresentationStyle = .custom
    messageReactionVC.isSender = isSender
    
    let selectedCell = selectedCellValues.0
    let selectedCellFrame = selectedCellValues.1
    let selectedCellView = selectedCell.snapshotView(afterScreenUpdates: false)!
    let newOrigin = CGPoint(x: selectedCellFrame.origin.x - selectedCellFrame.width * 0.1, y: selectedCellFrame.origin.y)
    let enlargedFrame = CGRect(
      origin: isSender ? newOrigin : selectedCellFrame.origin,
      size: CGSize(width: selectedCellFrame.width * 1.1, height: selectedCellFrame.height * 1.1))
    let chatVCImageView  = UIImageView(image: chatVCView)
    
    selectedCellView.frame  = enlargedFrame
    messageReactionVC.selectedMessageView = selectedCellView
    messageReactionVC.selectedChatMessage = selectedCellValues.2
    messageReactionVC.chatVCView = chatVCImageView
        
    navigation.present(messageReactionVC, animated: true)
  }
  
  func restart() {
    
  }
  
  func returnToPreviousView() {
    navigation.dismiss(animated: true) {
      self.parentCoordinator?.childViewDidPop()
    }
  }
  
  func childViewDidPop() {
    
  }
  
  required init(_ navigation: UINavigationController, _ firebase: FirebaseCommunicator) {
    self.navigation = navigation
    self.firebase   = firebase
  }
}

extension MessageReactionVCCoordinator: UIViewControllerTransitioningDelegate {
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    AnimatorFactory.supplyAnimator(fromVC: presenting, toVC: presented, forType: .presenting, presentation: .presentDismissType)
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    AnimatorFactory.supplyAnimator(fromVC: dismissed, forType: .dismissing, presentation: .presentDismissType)
  }
}
