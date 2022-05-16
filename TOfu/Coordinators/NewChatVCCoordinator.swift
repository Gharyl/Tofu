import UIKit

class NewChatVCCoordinator: Coordinator {
  var navigation: UINavigationController
  var childCoordinators: [Coordinator] = []
  var firebase: FirebaseCommunicator
  weak var parentCoordinator: Coordinator?
  
  func setup() {
    let newChatVC = NewChatViewController(
      friends: userModel.currentProfile.friends,
      coordinator: self,
      firebase: firebase)
    navigation.present(newChatVC, animated: true)
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

