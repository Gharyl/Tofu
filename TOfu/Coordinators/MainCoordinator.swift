import UIKit

class MainCoordinator: NSObject, Coordinator {
  var navigation: UINavigationController
  var firebase: FirebaseCommunicator
  var childCoordinators: [Coordinator] = []
  
  func setup() {
    let signUpVC = SignUpViewController()
    let signInVC = SignInViewController()
    let welcomeVC = WelcomeVC(signinVC: signInVC, signupVC: signUpVC)
    
    signUpVC.delegate = welcomeVC
    signUpVC.submissionDelegate = welcomeVC
    signInVC.delegate = welcomeVC
    signInVC.submissionDelegate = welcomeVC
    
    welcomeVC.coordinator = self
    welcomeVC.firebase    = firebase
    navigation.pushViewController(welcomeVC, animated: true)
  }
  
  func restart() {
    
  }
  
  func returnToPreviousView() {
    
  }
  
  func childViewDidPop() {
    childCoordinators.removeLast()
  }
  
  required init(_ navigation: UINavigationController, _ firebase: FirebaseCommunicator) {
    self.navigation = navigation
    self.firebase   = firebase
  }
}

extension MainCoordinator: MainCoordinating {
  func showHomeViewController() {
    let homeVCCoordinator = HomeVCCoordinator(navigation, firebase)
    homeVCCoordinator.parentCoordinator = self
    childCoordinators.append(homeVCCoordinator)
    homeVCCoordinator.setup()
  }
}

extension MainCoordinator: UINavigationControllerDelegate {
  func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    switch operation {
      case .push:
        return AnimatorFactory.supplyAnimator(fromVC: fromVC, toVC: toVC, forType: .presenting, presentation: .pushPopType)
      case .pop:
        return AnimatorFactory.supplyAnimator(fromVC: fromVC, toVC: toVC, forType: .dismissing, presentation: .pushPopType)
      default:
        return nil
    }
  }
}

protocol MainCoordinating {
  func showHomeViewController()
}
