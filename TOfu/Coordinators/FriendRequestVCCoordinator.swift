import UIKit

class FriendRequestVCCoordinator: NSObject, Coordinator {
  var navigation: UINavigationController
  var firebase: FirebaseCommunicator
  var childCoordinators: [Coordinator] = []
  weak var parentCoordinator: Coordinator?
  
  func setup() {
    let friendRequestVC = FriendRequestViewController(friendRequests: userModel.receivedRequests)
    friendRequestVC.coordinator = self
    friendRequestVC.db = firebase
    friendRequestVC.transitioningDelegate = self
    friendRequestVC.modalPresentationStyle = .custom
    navigation.present(friendRequestVC, animated: true)
  }
  
  func restart() {
    
  }
  
  func returnToPreviousView() {
    navigation.dismiss(animated: true)
    parentCoordinator?.childViewDidPop()
  }
  
  func childViewDidPop() {
      
  }
  
  required init(_ navigation: UINavigationController, _ firebase: FirebaseCommunicator) {
    self.navigation = navigation
    self.firebase   = firebase
  }
}

extension FriendRequestVCCoordinator: UIViewControllerTransitioningDelegate {
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return AnimatorFactory.supplyAnimator(fromVC: presenting, toVC: presented, forType: .presenting, presentation: .presentDismissType)
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return AnimatorFactory.supplyAnimator(fromVC: dismissed, forType: .dismissing, presentation: .presentDismissType)
  }
}
