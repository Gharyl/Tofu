import UIKit
import PhotosUI

final class HomeVCCoordinator: Coordinator {
  let navigation: UINavigationController
  let firebase: FirebaseCommunicator
  var childCoordinators: [Coordinator] = []
  weak var parentCoordinator: Coordinator?
  
  private lazy var profileVC: ProfileViewController = {
    let profileVC = ProfileViewController(userProfile: userModel.currentProfile)
    return profileVC
  }()
  
  private lazy var chatListVC: ChatListViewController = {
    let chatListVC = ChatListViewController(chats: userModel.currentChats)
    return chatListVC
  }()
  
  private lazy var homeVC: HomeViewController = {
    let homeVC = HomeViewController(profileVC: profileVC, chatListVC: chatListVC)
    return homeVC
  }()
  
  func setup() {
    profileVC.coordinator  = self
    chatListVC.coordinator = self
    homeVC.coordinator     = self
    
    profileVC.db  = firebase
    chatListVC.db = firebase
    homeVC.db     = firebase

    chatListVC.delegate = homeVC
    
    navigation.pushViewController(homeVC, animated: true)
    
    setupChatsObserver()
    setupProfileObserver()
  }
  
  func restart() {
    // Restart app, clear firebase auth and all data
  }
  
  func returnToPreviousView() {
    navigation.dismiss(animated: true)
  }
  
  func setupChatsObserver() {
    userModel.subscribeToChats { [weak self] newChats in
      guard let self = self else { return }
      self.chatListVC.chats = newChats
    }
  }
  
  func setupProfileObserver() {
    userModel.subscribeToProfile { [weak self] newProfile in
      guard let self = self else { return }
      self.profileVC.profile = newProfile
    }
  }
  
  func childViewDidPop() {
    childCoordinators.removeLast()
  }
  
  init(_ navigation: UINavigationController, _ firebase: FirebaseCommunicator) {
    self.navigation = navigation
    self.firebase   = firebase
  }
}

extension HomeVCCoordinator: HomeVCCoordinating {
  func showNewChatViewController() {
    let newChatVCCoordinator = NewChatVCCoordinator(navigation, firebase)
    newChatVCCoordinator.parentCoordinator = self
    childCoordinators.append(newChatVCCoordinator)
    newChatVCCoordinator.setup()
  }
  
  func showFriendViewController() {
    let friendVCCoordinator = FriendVCCoordinator(navigation, firebase)
    friendVCCoordinator.parentCoordinator = self
    childCoordinators.append(friendVCCoordinator)
    friendVCCoordinator.setup()
  }
  
  func showFriendRequestViewController() {
    let friendRequestVCCoordinator = FriendRequestVCCoordinator(navigation, firebase)
    friendRequestVCCoordinator.parentCoordinator = self
    childCoordinators.append(friendRequestVCCoordinator)
    friendRequestVCCoordinator.setup()
  }
  
  func showChatViewController(_ id: String?, _ chat: Chat?) {
    guard let chat = chat else { return }

    let chatVCCoordinator = ChatVCCoordinator(navigation, firebase)
    chatVCCoordinator.chat = chat
    chatVCCoordinator.parentCoordinator = self
    childCoordinators.append(chatVCCoordinator)
    chatVCCoordinator.setup()
  }
  
  // Standalone PHPickerViewController, no coordinator is given because there's no customizability
  func showPickerViewController() {
    var config = PHPickerConfiguration()
    config.selectionLimit = 1
    config.filter = .images
    
    let pickerVC = PHPickerViewController(configuration: config)
    pickerVC.delegate = profileVC
    
    navigation.present(pickerVC, animated: true)
  }
}

protocol HomeVCCoordinating {
  func showNewChatViewController()
  func showFriendViewController()
  func showFriendRequestViewController()
  func showChatViewController(_: String?, _: Chat?)
}
