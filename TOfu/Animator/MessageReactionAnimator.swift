import UIKit

class MessageReactionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  let presenting: Bool
  var duration: CGFloat = 1
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { duration }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    if presenting {
      presentAnimation(transitionContext: transitionContext)
    } else {
      dismissAnimation(transitionContext: transitionContext)
    }
  }
  
  // Animation for PRESENTING MessageReactionViewController.swift
  private func presentAnimation(transitionContext: UIViewControllerContextTransitioning) {
    guard
      let navigation: UINavigationController = transitionContext.viewController(forKey: .from) as? UINavigationController,
      let chatVC: ChatViewController = navigation.children.last as? ChatViewController,
      let messageReactionVC: MessageReactionViewController = transitionContext.viewController(forKey: .to) as? MessageReactionViewController
    else {
      print("MessageReactionAnimator failed to cast to appropriate tyeps")
      return
    }
    
    let transitionContainer = transitionContext.containerView
    
    // 1. Make original message invisible and replace that with the copy
    // 2. Change alpha to 0 in MessageReactionVC. Then, animate it fading in
    // 3. Make the copy shrink first. Then animate its frame to the final frame
    // 4. Excecute ReactionPopUpMenu's compression animation (in ReactionPupUpMenu.swift)
    
    let entireReactionMenuRef = [
      messageReactionVC.reactionPopUpMenuRef,
      messageReactionVC.bubbleShapeRef
    ]
    
    let selectedCellCopy = chatVC.selectedCell!.messageTextView.snapshotView(afterScreenUpdates: false)!
    selectedCellCopy.frame = chatVC.selectedCellFrame
    selectedCellCopy.layer.shadowColor = K.colorTheme2.gray3.cgColor
    selectedCellCopy.layer.shadowRadius = 3
    selectedCellCopy.layer.shadowOpacity = 0
    selectedCellCopy.layer.shadowOffset = CGSize(width: 0, height: 5)
    
    chatVC.selectedCell?.messageTextView.alpha = 0
    messageReactionVC.background.alpha = 0
    messageReactionVC.darkenedViewRef.alpha = 0
    messageReactionVC.selectedCellViewRef.alpha = 0
    entireReactionMenuRef.forEach{
      $0.alpha = 0
      $0.transform = CGAffineTransform(scaleX: 0.01, y: 1).translatedBy(x: -50, y: 50)
    }
    
    transitionContainer.addSubview(messageReactionVC.view)
    transitionContainer.addSubview(selectedCellCopy)
    
    UIView.animate(withDuration: 0.3, delay: 0, options: []) {
      selectedCellCopy.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    } completion: { _ in
      
      // Executing aniamtion involving both UIBezierPath and CAShapeLayer in their own class
      messageReactionVC.reactionPopUpMenuRef.beginExpandAnimation()
      
      UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: []) {
        selectedCellCopy.frame = messageReactionVC.selectedMessageView.frame
        selectedCellCopy.layer.shadowOpacity = 0.3
        messageReactionVC.background.alpha = 1
        messageReactionVC.darkenedViewRef.alpha = 1
        entireReactionMenuRef.forEach{
          $0.alpha = 1
          $0.transform = .identity
        }

      } completion: { finished in
        if finished {
          // Clean up aniamtion changes and completing transition
          messageReactionVC.selectedCellViewRef.alpha = 1
          chatVC.selectedCell?.messageTextView.alpha = 1
          selectedCellCopy.removeFromSuperview()
          transitionContext.completeTransition(true)
        }
      }
    }
  }
  
  // Animation for DISMISSING MessageReactionViewController.swift
  private func dismissAnimation(transitionContext: UIViewControllerContextTransitioning) {
    guard let navigation = transitionContext.viewController(forKey: .to) as? UINavigationController,
          let messageReactionVC = transitionContext.viewController(forKey: .from) as? MessageReactionViewController,
          let chatVC = navigation.children.last as? ChatViewController
    else { return print("\(self) failed to cast to appropriate types.") }

    let transitionContainer = transitionContext.containerView
    let selectedCellFrame = chatVC.selectedCellFrame
    
    // If there is a frame, the user had reacted to the message
    if let reactionButtonFrame = messageReactionVC.reactionPopUpMenuRef.reactionButtonFrame {
      UIView.animate(withDuration: 0.4, delay: 0.5, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: []) {
        messageReactionVC.reactionPopUpMenuRef.hStackRef.alpha = 0
        messageReactionVC.darkenedViewRef.alpha = 0
        messageReactionVC.chatVCView.alpha = 0
        messageReactionVC.selectedMessageView.frame = selectedCellFrame
      } completion: { finished in
        if finished {
          if chatVC.wasUserEditing {
            chatVC.wasUserEditing = false
            chatVC.messageTextfieldRef.becomeFirstResponder()
          }
          transitionContext.completeTransition(true)
        }
      }
    // If there is no frame, the user did not react to the message
    } else {
      let bubblesCopy = messageReactionVC.bubbleShapeRef.snapshotView(afterScreenUpdates: false)!
      bubblesCopy.frame = messageReactionVC.view.convert(messageReactionVC.bubbleShapeRef.frame, to: nil)
      messageReactionVC.bubbleShapeRef.alpha = 0
      transitionContainer.addSubview(bubblesCopy)
            
      messageReactionVC.reactionPopUpMenuRef.beginCompressAnimation()
      
      let animation = CGAffineTransform(translationX: 0, y: 20).scaledBy(x: 0.001, y: 0.001)
      
      UIView.animate(withDuration: 0.4, delay: 0.15, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: []) {
        messageReactionVC.reactionPopUpMenuRef.transform = animation
        bubblesCopy.transform = animation
        messageReactionVC.reactionPopUpMenuRef.alpha = 0
        messageReactionVC.darkenedViewRef.alpha = 0
        messageReactionVC.chatVCView.alpha = 0
        messageReactionVC.selectedMessageView.frame = selectedCellFrame
        messageReactionVC.selectedMessageView.layer.shadowOpacity = 0
      } completion: { finished in
        if finished {
          if chatVC.wasUserEditing {
            chatVC.wasUserEditing = false
            chatVC.messageTextfieldRef.becomeFirstResponder()
          }
          transitionContext.completeTransition(true)
        }
      }
    }
  }
  
  init(presenting: Bool) {
    self.presenting = presenting
  }
}
