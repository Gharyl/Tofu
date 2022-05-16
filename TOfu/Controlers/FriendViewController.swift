import UIKit

class FriendViewController: UIViewController {
  enum Filter{
    case yes
    case no
  }
  
  let db: FirebaseCommunicator
  let coordinator: FriendVCCoordinator?
  
  var friends: [Friend] {
    didSet {
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
    }
  }
  private var matchedFriends = [Friend]()
  
  private var friendsModified: [String:[Friend]] = [:]
  private var matchedModified: [String:[Friend]] = [:]
  private var sectionTitle: [String] = []
  
  private let dividerMargin: CGFloat = 10
  // 'isUserEditing' reflects whenever textfield is being used and tableView's datasource
  // will be updated accordingly
  private var isUserEditing: Bool {
    didSet {
      print("is user editing? \(isUserEditing)")
      if isUserEditing {
        updateSectionsAndRows(for: matchedFriends)
      } else {
        updateSectionsAndRows(for: friends)
      }
    }
  }
  
  private lazy var searchTextField: UITextField = {
    let searchTextField = UITextField()
    searchTextField.delegate = self
    searchTextField.autocorrectionType = .no
    searchTextField.backgroundColor = K.colorTheme2.blue2.withAlphaComponent(0.1)
    searchTextField.setPadding(20)
    searchTextField.layer.cornerRadius = K.textFieldHeight / 2
    searchTextField.translatesAutoresizingMaskIntoConstraints = false
    return searchTextField
  }()
  
  private lazy var divider: UIView = {
    let divider = UIView()
    divider.backgroundColor = K.colorTheme.gray.withAlphaComponent(0.5)
    divider.translatesAutoresizingMaskIntoConstraints = false
    return divider
  }()
  
  private lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.sectionHeaderTopPadding = 0 // FInally found the weird top padding...
    tableView.delegate = self
    tableView.dataSource = self
    tableView.translatesAutoresizingMaskIntoConstraints = false
    return tableView
  }()

  private lazy var addFriendButton: UIBarButtonItem = {
    let addFriendButton = UIBarButtonItem()
    addFriendButton.target = self
    addFriendButton.image = UIImage(systemName: "person.badge.plus")
    return addFriendButton
  }()
  
  private func updateSectionsAndRows(for data: [Friend]) {
    // Extract prefix of each friend's first name
    let prefixArray: [String] = data.map{ String($0.firstName.prefix(1)) }
    // Put each friend into their own respective prefix
    let target: [String:[Friend]] = data.reduce(into: [:], { partialResult, friend in
      partialResult[String(friend.firstName.prefix(1)), default: []].append(friend)
    })
    
    sectionTitle = Array(Set(prefixArray)).sorted()
    
    if isUserEditing {
      matchedModified = target
    } else {
      friendsModified = target
    }
    tableView.reloadData()  // Reflect the updated array
  }
  
  private func setConstraints(){
    NSLayoutConstraint.activate([
      searchTextField.heightAnchor.constraint(equalToConstant: K.textFieldHeight),
      searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
      searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      searchTextField.bottomAnchor.constraint(equalTo: divider.topAnchor, constant: -dividerMargin),
      
      divider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
      divider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
      divider.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: dividerMargin),
      divider.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: 1),
      divider.heightAnchor.constraint(equalToConstant: 1),
      
      tableView.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: -1),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
  private func setSubviews() {
    view.addSubview(searchTextField)
    view.addSubview(divider)
    view.addSubview(tableView)
  }
  
  private func setTableview() {
    tableView.register(ContactCell.self, forCellReuseIdentifier: "ContactCell")
    tableView.allowsSelection = false
    tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    updateSectionsAndRows(for: friends)
  }
  
  private func setNavigationBar() {
    navigationItem.rightBarButtonItem = addFriendButton
    addFriendButton.action = #selector(addFriendButtonTapped(_:))
  }
  
  @objc
  private func addFriendButtonTapped(_ sender: UIBarButtonItem) {
    coordinator?.showNewFriendViewController()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    setTableview()
    setSubviews()
    setConstraints()
    setNavigationBar()
    // Linking up functions
    searchTextField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
  }
  
  init(
    db: FirebaseCommunicator,
    coordinator: FriendVCCoordinator,
    friends: [Friend]
  ) {
    self.db = db
    self.coordinator = coordinator
    self.friends = friends
    self.isUserEditing = false
    super.init(nibName: nil, bundle: nil)
  }
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension FriendViewController: UITextFieldDelegate {
  @objc
  func textChanged(_ sender: UITextField) {
    // If user is editing and textfield has some text, begin filtering friends list
    if let safeText = searchTextField.text, !safeText.isEmpty {
      self.matchedFriends = friends.filter { friend in
        // Matching text with user's friends' names
        return (
          friend.firstName.localizedCaseInsensitiveContains(safeText) ||
          friend.firstName.localizedCaseInsensitiveContains(safeText) ||
          friend.firstName.localizedCaseInsensitiveContains(safeText)
        )
      }
      isUserEditing = true  // Update array
    } else {
      isUserEditing = false // Update array
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    searchTextField.resignFirstResponder()
    return true
  }
}

extension FriendViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return sectionTitle.count
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let sectionHeader: UIView = SectionHeader(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: K.headerHeight), title: sectionTitle[section])
    return sectionHeader
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return K.headerHeight
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return K.contactCellHeight
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isUserEditing {
      return matchedModified[sectionTitle[section]]?.count ?? 0
    } else {
      return friendsModified[sectionTitle[section]]?.count ?? 0
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let contactCell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") as! ContactCell
    
    // TODO: - Fetch each friend's profile image URL
    // ...
    let friend: Friend
    if isUserEditing {
      friend = (matchedModified[sectionTitle[indexPath.section]]?[indexPath.row])!
    } else {
      friend = (friendsModified[sectionTitle[indexPath.section]]?[indexPath.row])!
    }
    contactCell.profileName.text = friend.firstName + " " + friend.lastName
    contactCell.username.text    = friend.username
    return contactCell
  }
  
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
  }
}
