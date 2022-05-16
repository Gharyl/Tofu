import UIKit

class FriendVCCoordinator: Coordinator {
  var navigation: UINavigationController
  var firebase: FirebaseCommunicator
  var childCoordinators: [Coordinator] = []
  weak var parentCoordinator: Coordinator?
  
  private lazy var friendVC: FriendViewController = {
    let friendVC = FriendViewController(
      db: firebase,
      coordinator: self,
      friends: userModel.friends)
    return friendVC
  }()
  
  func setup() {
    navigation.pushViewController(friendVC, animated: true)
  }
  
  func restart() {
    
  }
  
  func returnToPreviousView() {
    navigation.popViewController(animated: true)
    userModel.removeProfileSubscription()
    parentCoordinator?.childViewDidPop()
  }
  
  func setupProfileObserver() {
    userModel.subscribeToProfile { profile in
      self.friendVC.friends = profile.friends
    }
  }
  
  func childViewDidPop() {
    childCoordinators.removeLast()
  }
  
  required init(_ navigation: UINavigationController, _ firebase: FirebaseCommunicator) {
    self.navigation = navigation
    self.firebase   = firebase
  }
}

extension FriendVCCoordinator: FriendVCCoordinating {
  func showNewFriendViewController() {
    let newFriendVCCoordinator = NewFriendVCCoordinator(navigation, firebase)
    newFriendVCCoordinator.parentCoordinator = self
    childCoordinators.append(newFriendVCCoordinator)
    newFriendVCCoordinator.setup()
  }
}

protocol FriendVCCoordinating {
  func showNewFriendViewController()
}
