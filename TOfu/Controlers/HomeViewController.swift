import UIKit

class HomeViewController: UIViewController {
  weak var coordinator: HomeVCCoordinator?
  var db: FirebaseCommunicator!
  
  var currentUserModel: UserModel!  {
    didSet {
      profileVC.profile = currentUserModel.currentProfile
    }
  }
  
  enum HomeViewState {
    case chat
    case profile
    case friends
  }
  
  var homeViewState: HomeViewState = .chat {
    didSet {
      if homeViewState == .profile {
        chatListVC.overlayInvisibleView()
      }
    }
  }
  
  let profileVC: ProfileViewController
  let chatListVC: ChatListViewController
  
  private lazy var newMessageButton: UIBarButtonItem = {
    let newMessageButton = UIBarButtonItem()
    newMessageButton.target = self
    newMessageButton.image = UIImage(systemName: "plus.bubble")
    newMessageButton.tintColor = K.colorTheme2.blue2
    return newMessageButton
  }()
  
  private lazy var profileButton: UIBarButtonItem = {
    let profileButton = UIBarButtonItem()
    profileButton.target = self
    profileButton.image = UIImage(systemName: "person.crop.circle")
    profileButton.tintColor = K.colorTheme2.blue2
    return profileButton
  }()
  
  private lazy var friendButton: UIBarButtonItem = {
    let addFriendButton = UIBarButtonItem()
    addFriendButton.target = self
    addFriendButton.image  = UIImage(systemName: "person.3")
    addFriendButton.tintColor = K.colorTheme2.blue2
    return addFriendButton
  }()
  
  private func setChildren() {
    addSubVC(profileVC)
    addSubVC(chatListVC) // Must be on top of ProfileViewController
  }
  
  private func setSubviews() {
    setChildren()
  }
  
  private func setConstraints() {
    NSLayoutConstraint.activate([
      profileVC.view.topAnchor.constraint(equalTo: view.topAnchor),
      profileVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      profileVC.view.widthAnchor.constraint(equalToConstant: K.slideOffset),
      
      chatListVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      chatListVC.view.topAnchor.constraint(equalTo: view.topAnchor),
      chatListVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      chatListVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
  }
  
  private func setNavigationBar() {
    title = "Messages"
    navigationItem.hidesBackButton = true
    navigationItem.rightBarButtonItems = [friendButton, newMessageButton]
    navigationItem.leftBarButtonItems = [profileButton]
    profileButton.action = #selector(profileButtonTapped(_:))
    newMessageButton.action = #selector(newMessageButtonTapped(_:))
    friendButton.action = #selector(friendList(_:))
  }
  
  private func setGestures() {
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
    chatListVC.view.addGestureRecognizer(panGesture)
  }
  
  private func setShadows() {
    chatListVC.view.layer.shadowColor = UIColor.black.cgColor
    chatListVC.view.layer.shadowOffset = CGSize(width: -10, height: 0)
    chatListVC.view.layer.shadowRadius = 10
    chatListVC.view.layer.shadowOpacity = 0.2
  }
  
  @objc
  private func newMessageButtonTapped(_ sender: UIBarButtonItem) {
    // Show NewMessageVC
    print("Showing newChatVC")
    coordinator?.showNewChatViewController()
  }
  
  
  @objc
  private func friendList(_ sender: UIBarButtonItem) {
    // Show FriendListVC
    coordinator?.showFriendViewController()
  }
  
  @objc
  private func profileButtonTapped(_ sender: UIBarButtonItem) {
    UIView.animate(withDuration: 0.3) {
      self.chatListVC.view.transform = CGAffineTransform(translationX: K.slideOffset, y: 0)
      self.navigationController?.navigationBar.transform = CGAffineTransform(translationX: K.slideOffset, y: 0)
      self.homeViewState = .profile
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setSubviews()
    setConstraints()
    setNavigationBar()
    setGestures()
    setShadows()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    coordinator?.navigation.interactivePopGestureRecognizer?.isEnabled = false
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    coordinator?.navigation.interactivePopGestureRecognizer?.isEnabled = true
  }
  
  init(profileVC: ProfileViewController, chatListVC: ChatListViewController) {
    self.profileVC = profileVC
    self.chatListVC = chatListVC
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}


// MARK: - Pan Gesture Recognizer
extension HomeViewController {
  @objc
  private func panGesture(_ sender: UIPanGestureRecognizer) {
    let xOffset = sender.translation(in: view).x
    
    // Invalid states
    if homeViewState == .profile && xOffset > 0 { return }
    if homeViewState == .chat    && xOffset < 0 { return }
    
    showProfile(sender, xOffset)
  }

  private func showProfile(_ sender: UIPanGestureRecognizer, _ offset: CGFloat) {
    switch sender.state {
      case .began, .changed:
        if (0...K.slideOffset).contains(offset) && homeViewState == .chat { // xOffset within 0 - K.slideOffset
          self.chatListVC.view.transform = CGAffineTransform(translationX: offset, y: 0)
          self.navigationController?.navigationBar.transform = CGAffineTransform(translationX: offset, y: 0)
        } else if (-K.slideOffset...0).contains(offset) && homeViewState == .profile {  // xOffset within -K.slideOffset - 0
          self.chatListVC.view.transform = CGAffineTransform(translationX: offset + K.slideOffset, y: 0)
          self.navigationController?.navigationBar.transform = CGAffineTransform(translationX: offset + K.slideOffset, y: 0)
        }

      case .ended:
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: [.curveEaseOut]) {
          if offset > UIScreen.main.bounds.width * 0.2 {
            self.chatListVC.view.transform = CGAffineTransform(translationX: K.slideOffset, y: 0)
            self.navigationController?.navigationBar.transform = CGAffineTransform(translationX: K.slideOffset, y: 0)
            self.homeViewState = .profile
          } else {
            self.chatListVC.view.transform = .identity
            self.navigationController?.navigationBar.transform = .identity
            self.homeViewState = .chat
          }
        } completion: { _ in }

      case .cancelled, .failed:
        print("Gesture cancelled, failed Case")
      default:
        print("Gesture Default Case")
    }
  }
  
  private func resetHome() {
    navigationController?.navigationBar.transform = .identity
    chatListVC.view.transform = .identity
    homeViewState = .chat
  }
}


// MARK: - ChatListViewController Delegate
extension HomeViewController: ChatListViewDelegate {
  func reset(completion: () -> Void) {
    UIView.animate(withDuration: 0.4) {
      self.resetHome()
    }
    completion()
  }
}
