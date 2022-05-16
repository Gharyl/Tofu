import UIKit

enum AnimatorFactory {
  enum ActionType {
    case presenting
    case dismissing
  }
  enum PresentationType {
    case pushPopType
    case presentDismissType
  }
  
  static func supplyAnimator(
    fromVC: UIViewController? = nil,
    toVC:   UIViewController? = nil,
    forType actionType: ActionType,
    presentation presentationType: PresentationType
  ) -> UIViewControllerAnimatedTransitioning? {
    
    //MARK: - presentType: 'present/dismiss(UIViewController)' type
    if case .presentDismissType = presentationType,
       case .presenting  = actionType
    {
      if let _ = toVC as? FriendRequestViewController { return FriendRequestAnimator(presenting: true)}
      if let _ = toVC as? MessageReactionViewController { return MessageReactionAnimator(presenting: true) }
    }
    
    if case .presentDismissType = presentationType,
       case .dismissing  = actionType
    {
      if let _ = fromVC as? FriendRequestViewController { return FriendRequestAnimator() }
      if let _ = fromVC as? MessageReactionViewController { return MessageReactionAnimator(presenting: false) }
    }
    
    //MARK: - pushType: 'pushViewController()/popViewController()' type
    if case .pushPopType   = presentationType,
       case .presenting = actionType
    {
      if let _ = fromVC as? WelcomeVC { return WelcomeTransitionAnimator() }
    }
    
    if case .pushPopType   = presentationType,
       case .dismissing = actionType
    {
      
    }
    
    return nil
  }
}
