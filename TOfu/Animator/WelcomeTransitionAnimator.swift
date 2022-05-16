import UIKit

class WelcomeTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  let duration: CGFloat = 1
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return duration
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard
      let destinationVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? HomeViewController,
      let originVC      = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? WelcomeVC
    else {
      transitionContext.containerView.addSubview(transitionContext.viewController(forKey: .to)!.view)
      transitionContext.completeTransition(true)
      return
    }
    
    let transitionContainer = transitionContext.containerView
    let childVC = originVC.children[0] as! TransitionBlurProtocol // Could either be SignInVC or SignUpVC
        
    let blankView = UIView()
    blankView.alpha = 0
    blankView.backgroundColor = .white
    blankView.translatesAutoresizingMaskIntoConstraints = false
    
    let blurViewOGFrame = childVC.blurViewRef.frame
    childVC.blurViewRef.contentView.addSubview(blankView)
    
    NSLayoutConstraint.activate([
      blankView.topAnchor.constraint(equalTo: childVC.blurViewRef.topAnchor),
      blankView.leadingAnchor.constraint(equalTo: childVC.blurViewRef.leadingAnchor),
      blankView.trailingAnchor.constraint(equalTo: childVC.blurViewRef.trailingAnchor),
      blankView.bottomAnchor.constraint(equalTo: childVC.blurViewRef.bottomAnchor)
    ])
    
    destinationVC.navigationController?.navigationBar.alpha = 0
    destinationVC.navigationController?.navigationBar.transform = CGAffineTransform(translationX: 0, y: -20)
    
    // When a transition takes place, the animatedBackground's layer animation will be reverted
    // back to its original value, which looks abrupt and most importantly, ugly.
    // Solution: create a snapshot right before it reverts back and use that as the new temporary backgorund
    
    originVC.bubbleBackground.pauseAnimation()
    let bg = originVC.animatedBackground.snapshotView(afterScreenUpdates: false)! // Copy of the background
    bg.frame = originVC.animatedBackground.frame
    originVC.animatedBackground.alpha = 0
    originVC.view.insertSubview(bg, aboveSubview: originVC.animatedBackground) // Add to the screen
    
    UIView.animateKeyframes(withDuration: duration, delay: 0, options: [.init(rawValue: UIView.AnimationOptions.curveEaseOut.rawValue)]) {
      UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3) {
        childVC.blurViewRef.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
      }
      UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.4) {
        blankView.alpha = 1
        originVC.loadingView.alpha = 0
        originVC.checkmarkView.alpha = 0
        childVC.blurViewRef.bounds = originVC.view.bounds
        childVC.blurViewRef.transform = .identity
      }
      UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25) {
        destinationVC.navigationController?.navigationBar.alpha = 1
        destinationVC.navigationController?.navigationBar.transform = .identity
      }
    } completion: { completed in
      if completed {
        /*
         This part is important. After whatever custom animated transition is finished,
         you must MANUALLY prepare the ACTUAL UI of the app after this transition.

         'transitionContainer' is not a 'copy' of the actual UI of the app; by calling
         'transitionContext.completeTransition(true)', the 'transitionContainer' would not be
         deinitialized and the ACTUAL UI would not appear.

         You are actually manipulating the views that are being pushed onto the screen or that
         are being popped off of the screen. Those 'toVC' and 'fromVC' are actually, the same exact
         VC that you wrote. It is NOT A COPY!!! So anything that you modified during this transition,
         will take permanent effect if you DON'T reverse it!!! That means, whatever new UIView you
         added, whatever transform, color, alpha, frame, position changed, YOU must reverse it after
         the transition is compelte.

         'transitionContainer' only contains 'fromVC'. Therefore, 'toVC' must be added manually after
         transition is complete.

         'UIViewControllerAnimatedTransitioning' lets you have the power to control the
         transition with YOUR VERY OWN VC. THERE IS NO COPY INVOLVED!!!!
         */
        
        blankView.removeFromSuperview()
        childVC.blurViewRef.frame = blurViewOGFrame
        originVC.loadingView.alpha = 1
        originVC.checkmarkView.alpha = 1
        transitionContainer.addSubview(destinationVC.view)
        transitionContext.completeTransition(true)
      }
    }
  }
}
