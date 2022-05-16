import UIKit

class FriendRequestViewController: UIViewController {
  weak var coordinator: FriendRequestVCCoordinator?
  var db: FirebaseCommunicator?
  var receivedRequests: [FriendRequest] {
    didSet {
      print("received request: \(receivedRequests)")
    }
  }
  
  private lazy var friendTitle: CustomButton = {
    let friendTitle = CustomButton(frame: .zero, title: "Friend Requests: \(receivedRequests.count)")
    friendTitle.layer.cornerRadius = 10
    friendTitle.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    friendTitle.backgroundColor = K.colorTheme2.blue2
    friendTitle.isUserInteractionEnabled = true
    friendTitle.translatesAutoresizingMaskIntoConstraints = false
    return friendTitle
  }()
  
  private lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.allowsSelection = false
    tableView.register(ContactCell.self, forCellReuseIdentifier: "ContactCell")
    tableView.separatorInset = .zero
    tableView.sectionHeaderTopPadding = 0
    tableView.layer.cornerRadius = 30
    tableView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    tableView.translatesAutoresizingMaskIntoConstraints = false
    return tableView
  }()

  private lazy var vStack: UIStackView = {
    let vStack = UIStackView()
    vStack.axis = .vertical
    vStack.alignment = .fill
    vStack.distribution = .equalSpacing
    vStack.addArrangedSubview(friendTitle)
    vStack.addArrangedSubview(tableViewRef)
    vStack.translatesAutoresizingMaskIntoConstraints = false
    return vStack
  }()
  
  private lazy var blurView: UIVisualEffectView = {
    let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
    let blurView   = UIVisualEffectView(effect: blurEffect)
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissView(_:)))
    blurView.contentView.addGestureRecognizer(tapGesture)
    blurView.translatesAutoresizingMaskIntoConstraints = false
    return blurView
  }()
  
  @objc
  private func dismissView(_ sender: UITapGestureRecognizer) {
    coordinator?.returnToPreviousView()
  }
  
  private func setSubviews(){
    view.addSubview(blurView)
    view.addSubview(vStack)
  }
  
  private func setConstraints(){
    NSLayoutConstraint.activate([
      blurView.topAnchor.constraint(equalTo: view.topAnchor),
      blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: K.Screen.height * 0.25),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: K.Screen.width * 0.1),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: K.Screen.width * -0.1),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: K.Screen.height * -0.25),
      
      friendTitle.heightAnchor.constraint(equalToConstant: 35),
    ])
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .clear
    
    setSubviews()
    setConstraints()
    view.layoutIfNeeded() // Manually calling this earlier so I can access the frame in Custom Transition
  }
  
  init(friendRequests: [FriendRequest]) {
    self.receivedRequests = friendRequests
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension FriendRequestViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { receivedRequests.count }
  
  func numberOfSections(in tableView: UITableView) -> Int { 1 }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let contactCell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") as? ContactCell else {
      print("ContactCell not registered? in FriendRequestVC")
      return UITableViewCell()
    }
    
    let currentRequest = receivedRequests[indexPath.row]
    contactCell.contactID = currentRequest.id!
    contactCell.isRequest = true
    contactCell.username.text  = currentRequest.fromUser.username
    contactCell.profileName.text = currentRequest.fromUser.firstName + " " + currentRequest.fromUser.lastName
    contactCell.requestDelegate = self
    
    return contactCell
  }
}


// MARK: - FriendRequestTransitionDelegate
// For FriendRequestAnimator
extension FriendRequestViewController: FriendRequestTransitionDelegate {
  var buttonCopy: UIButton {
    let button = UIButton(frame: friendTitle.frame)
    button.setTitle("Friend Requests: \(receivedRequests.count)", for: .normal)
    button.setTitleColor(K.colorTheme2.gray1, for: .normal)
    button.backgroundColor = K.colorTheme2.blue2
    button.isUserInteractionEnabled = false
    return button
  }
  
  var buttonRef: CustomButton { friendTitle }
  var tableViewRef: UITableView { tableView }
  var vStackRef: UIStackView { vStack }
  var blurViewRef: UIVisualEffectView { blurView }
}

protocol FriendRequestTransitionDelegate: AnyObject {
  var buttonCopy: UIButton { get }
  var buttonRef: CustomButton { get }
  var tableViewRef: UITableView { get }
  var vStackRef: UIStackView { get }
  var blurViewRef: UIVisualEffectView { get }
}


// MARK: - ContactCellRequestDelegate
extension FriendRequestViewController: ContactCellRequestDelegate {
  func requestResponded(response: Bool, cell: ContactCell) {
    // Update TableView
    let friendRequestCOPY: [FriendRequest] = receivedRequests.map{ $0 }
    guard let indexToRemove = receivedRequests.firstIndex(where: { $0.id == cell.contactID }) else { return }
    let deletedRequest = receivedRequests.remove(at: indexToRemove)
    
    let difference = receivedRequests.difference(from: friendRequestCOPY)
    
    let deletedIndex = difference.compactMap { difference -> IndexPath? in
      guard case let .remove(offset: index, element: _, associatedWith: _) = difference else { return nil }
      return IndexPath(row: index, section: 0)
    }
    
    print("Awaiting updateFriendRequests")
    db?.updateFriendRequests(friendRequest: deletedRequest, isAccepted: response) { error in
      if let error = error {
        print("Error from requestResponded \(error.localizedDescription)")
      }
    }
    
    friendTitle.title = "Friend Requests: \(receivedRequests.count)"
    
    tableView.beginUpdates()
    tableView.deleteRows(at: deletedIndex, with: response ? .right : .left)
    tableView.endUpdates()
  }
}
