import UIKit

protocol Coordinator: AnyObject {
  var navigation: UINavigationController {get}
  var firebase: FirebaseCommunicator     {get}
  var childCoordinators: [Coordinator]   {get set}
  var userModel: UserModel {get}
  
  func setup()
  func restart()
  func returnToPreviousView()
  func childViewDidPop()
  init(_:UINavigationController, _:FirebaseCommunicator)
}

extension Coordinator {
  var userModel: UserModel {
    guard let safeUserModel = firebase.userModel else {
      print("CURRENTUSERMODEL FAILED IN COORDINATOR")
      return UserModel(nil)
    }
    return safeUserModel
  }
}

