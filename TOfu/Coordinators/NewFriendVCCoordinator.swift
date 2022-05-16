import UIKit

class NewFriendVCCoordinator: Coordinator {
  var navigation: UINavigationController
  var firebase: FirebaseCommunicator
  var childCoordinators: [Coordinator] = []
  weak var parentCoordinator: Coordinator?
  
  private lazy var newFriendVC: NewFriendViewController = {
    let newFriendVC = NewFriendViewController()
    newFriendVC.coordinator = self
    newFriendVC.db = firebase
    return newFriendVC
  }()
  
  func setup() {
    navigation.present(newFriendVC, animated: true)
    setupProfileObserver()
  }
  
  private func setupProfileObserver() {
    userModel.subscribeToProfile { profile in
      self.newFriendVC.friends = profile.friends
    }
  }
  
  func restart() {
      
  }
  
  func returnToPreviousView() {
    parentCoordinator?.childViewDidPop()
  }
  
  func dismissByButton() {
    navigation.dismiss(animated: true)
  }
  
  func childViewDidPop() {
      
  }
  
  required init(_ navigation: UINavigationController, _ firebase: FirebaseCommunicator) {
    self.navigation = navigation
    self.firebase   = firebase
  }
}
