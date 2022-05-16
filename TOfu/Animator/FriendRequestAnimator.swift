import UIKit

class FriendRequestAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  let presenting: Bool
  var duration: CGFloat = 1
  
  init(presenting: Bool = false) {
    self.presenting = presenting
  }
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return duration
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    if presenting {
      presentAnimation(transitionContext: transitionContext)
    } else {
      dismissAnimation(transitionContext: transitionContext)
    }
  }
  
  func presentAnimation(transitionContext: UIViewControllerContextTransitioning) {
    guard
      let navigation    = transitionContext.viewController(forKey: .from) as? UINavigationController,
      let homeVC        = navigation.children.last as? HomeViewController,
      let originVC      = homeVC.children.first as? ProfileViewController,
      let destinationVC = transitionContext.viewController(forKey: .to) as? FriendRequestViewController
    else { return print("FriendRequestAnimator failed to cast to appropriate types") }
    
    let transitionContainer = transitionContext.containerView
    let finalTableViewFrame = destinationVC.vStackRef.convert(destinationVC.tableViewRef.frame, to: transitionContainer)
    let finalButtonFrame    = destinationVC.vStackRef.convert(destinationVC.buttonRef.frame, to: transitionContainer)
    
    let blur     = UIBlurEffect(style: .systemUltraThinMaterialLight)
    let blurView = UIVisualEffectView(effect: blur)
    blurView.frame = UIScreen.main.bounds
    blurView.alpha = 0
    
    let buttonCopy = originVC.friendButtonCopy
    originVC.friendRequestButtonRef.transform = CGAffineTransform(scaleX: 0.001, y: 0.8)
    originVC.friendRequestButtonRef.alpha = 0
        
    destinationVC.view.alpha = 0
    transitionContainer.addSubview(destinationVC.view)
    transitionContainer.addSubview(blurView)
    transitionContainer.addSubview(buttonCopy)
    
    // Must create a snapshot AFTER adding destinationVC.view to the container
    // Otherwise, the snapshot will be invisible
    let tableViewCopy = destinationVC.tableViewRef.snapshotView(afterScreenUpdates: true)!
    tableViewCopy.frame = CGRect(origin: finalTableViewFrame.origin, size: CGSize(width: finalTableViewFrame.width, height: 0))
    transitionContainer.addSubview(tableViewCopy)

    let animator1 = UIViewPropertyAnimator(
      duration: 0.4,
      controlPoint1: CGPoint(x: 0.1, y: 0.5),
      controlPoint2: CGPoint(x: 0.6, y: 1.2)
    ) {
      blurView.alpha = 1
      buttonCopy.center = destinationVC.buttonRef.center
      buttonCopy.frame = finalButtonFrame
    }
    let animator2 = UIViewPropertyAnimator(duration: 0.3, dampingRatio: 0.8) {
      tableViewCopy.frame = finalTableViewFrame
    }
    animator1.addCompletion { _ in
      animator2.startAnimation()
    }
    animator2.addCompletion { _ in
      blurView.removeFromSuperview()
      buttonCopy.removeFromSuperview()
      tableViewCopy.removeFromSuperview()
      destinationVC.view.alpha = 1
      transitionContext.completeTransition(true)
    }
    animator1.startAnimation()
  }
  
  func dismissAnimation(transitionContext: UIViewControllerContextTransitioning) {
    guard
      let originVC = transitionContext.viewController(forKey: .from) as? FriendRequestViewController,
      let navigation = transitionContext.viewController(forKey: .to) as? UINavigationController,
      let destinationVC = navigation.children.last as? HomeViewController,
      let profileVC = destinationVC.children.first as? ProfileViewController
    else { return print("\(self) failed to cast to appropriate types") }
    
    let transitionContainer = transitionContext.containerView
    
    let vStackCopy = originVC.vStackRef.snapshotView(afterScreenUpdates: true)!
    vStackCopy.frame = originVC.vStackRef.frame
    transitionContainer.addSubview(vStackCopy)
    
    originVC.buttonRef.alpha = 0
    originVC.tableViewRef.alpha = 0

    let randomXOffset: CGFloat = [
      CGFloat.random(in: (K.Screen.width * -3)...(K.Screen.width * -1)),
      CGFloat.random(in: (K.Screen.width *  1)...(K.Screen.width *  3))
    ].randomElement()!
    let randomYOffset: CGFloat = [
      CGFloat.random(in: (K.Screen.height * -2)...(K.Screen.height * -1)),
      CGFloat.random(in: (K.Screen.height *  1)...(K.Screen.height *  2))
    ].randomElement()!
    
    CATransaction.begin()
    let animations = CAAnimationGroup()
    animations.duration = 0.5
    
    let positionAnimation = CABasicAnimation(keyPath: "position")
    positionAnimation.fromValue = vStackCopy.layer.position
    positionAnimation.toValue   = CGPoint(x: randomXOffset, y: randomYOffset)
    vStackCopy.layer.add(positionAnimation, forKey: positionAnimation.keyPath)
    
    let rotationAnimation = CABasicAnimation(keyPath: "transform")
    rotationAnimation.fromValue = vStackCopy.layer.transform
    rotationAnimation.toValue   = CATransform3DMakeRotation(.pi, 0, 0, 1)
    rotationAnimation.repeatCount = Float.infinity
    
    let opacityAnimation = CABasicAnimation(keyPath: "opacity")
    opacityAnimation.fromValue = 1
    opacityAnimation.toValue   = 0
    
    animations.animations = [positionAnimation, rotationAnimation]
    vStackCopy.layer.add(animations, forKey: nil)
    
    originVC.blurViewRef.layer.add(opacityAnimation, forKey: "opacity")
    originVC.blurViewRef.layer.opacity = 0
    
    vStackCopy.layer.position = CGPoint(x: randomXOffset, y: randomYOffset)
    vStackCopy.layer.transform  = CATransform3DMakeRotation(.pi, 0, 0, 1)
    CATransaction.commit()
    // Bouncy effect
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: []) {
      profileVC.friendRequestButtonRef.transform = .identity
      profileVC.friendRequestButtonRef.alpha = 1
    } completion: { _ in
      transitionContext.completeTransition(true)
    }
  }
}
