import UIKit

class NewFriendViewController: UIViewController {
  weak var coordinator: NewFriendVCCoordinator?
  var delegate: ContactCellAddFriendDelegate?
  var db: FirebaseCommunicator?
  var matchedUsers: [Friend] = []
  var friends: [Friend] = []
  
  private lazy var titleLabel: UILabel = {
    let titleLabel = UILabel()
    titleLabel.text = "Search New Users"
    titleLabel.font = .systemFont(ofSize: 20)
    titleLabel.textColor = K.colorTheme2.blue2
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    return titleLabel
  }()
  
  private lazy var searchTextField: UITextField = {
    let searchTextField = UITextField()
    searchTextField.delegate = self
    searchTextField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
    searchTextField.backgroundColor = K.colorTheme2.gray1
    searchTextField.layer.cornerRadius = K.textFieldHeight / 2
    searchTextField.setPadding(20)
    let placegolder = NSAttributedString(
      string: "Username, first name, last name..",
      attributes: [.font : UIFont.systemFont(ofSize: 15)])
    searchTextField.attributedPlaceholder = placegolder
    searchTextField.rightView = searchButton
    searchTextField.translatesAutoresizingMaskIntoConstraints = false
    return searchTextField
  }()
  
  private lazy var searchButton: UIButton = {
    let searchButton = UIButton()
    searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
    searchButton.tintColor = .black.withAlphaComponent(0.8)
    searchButton.addTarget(self, action: #selector(searchButtonTapped(_:)), for: .touchUpInside)
    searchButton.isUserInteractionEnabled = false
    searchButton.translatesAutoresizingMaskIntoConstraints = false
    return searchButton
  }()
  
  private var hStack: UIStackView = {
    let hStack = UIStackView()
    hStack.axis = .horizontal
    hStack.alignment = .center
    hStack.distribution = .fill
    hStack.spacing = 10
    hStack.isLayoutMarginsRelativeArrangement = true
    hStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
    hStack.translatesAutoresizingMaskIntoConstraints = false
    return hStack
  }()
  
  private lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.allowsSelection = false
    tableView.sectionHeaderTopPadding = 0
    tableView.dataSource = self
    tableView.delegate = self
    tableView.register(ContactCell.self, forCellReuseIdentifier: "ContactCell")
    tableView.translatesAutoresizingMaskIntoConstraints = false
    return tableView
  }()
  
  private lazy var cancelButton: UIButton = {
    let cancelButton = UIButton()
    cancelButton.tintColor = .black
    cancelButton.setImage(UIImage(systemName: "xmark"), for: .normal)
    cancelButton.addTarget(self, action: #selector(cancelButtonTapped(_:)), for: .touchUpInside)
    cancelButton.tintColor = K.colorTheme2.gray3
    cancelButton.translatesAutoresizingMaskIntoConstraints = false
    return cancelButton
  }()
  
  private func setConstraints(){
    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
      titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      
      cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
      cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
      
      searchButton.widthAnchor.constraint(equalToConstant: 40),
      searchTextField.heightAnchor.constraint(equalToConstant: K.textFieldHeight),
      
      hStack.heightAnchor.constraint(equalToConstant: 40),
      hStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
      hStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      hStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      hStack.bottomAnchor.constraint(equalTo: tableView.topAnchor),
      
      tableView.topAnchor.constraint(equalTo: hStack.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -10)
    ])
  }
  
  private func setSubviews(){
    hStack.addArrangedSubview(searchTextField)
    hStack.addArrangedSubview(searchButton)
    view.addSubview(titleLabel)
    view.addSubview(cancelButton)
    view.addSubview(hStack)
    view.addSubview(tableView)
  }
  
  @objc
  private func searchButtonTapped(_ sender: UIBarButtonItem) {
    searchButton.isUserInteractionEnabled = false
    guard let currentProfile = db?.userModel else { return print("Please log in again") }
    
    let friends = currentProfile.friends
    
    db?.fetchUsers(for: searchTextField.text!, completed: { result in
      switch result {
        case .success(let users):
          // Remove friends
          self.matchedUsers = users.filter { user in
            return !friends.contains(user)
          }
          
          self.tableView.reloadData()
        case .failure(let error):
          print(error.localizedDescription)
      }
      self.searchButton.isUserInteractionEnabled = true
    })
  }
  
  @objc
  private func cancelButtonTapped(_ sender: UIBarButtonItem) {
    coordinator?.dismissByButton()
    print("dismiss by button")
  }
  
  override func viewDidLoad() {
    view.backgroundColor = .white
    super.viewDidLoad()
    setSubviews()
    setConstraints()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    searchTextField.becomeFirstResponder()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    print("view did disappear")
    coordinator?.returnToPreviousView()
    super.viewDidDisappear(animated)
  }
}


// MARK: - UITextField Delegate
extension NewFriendViewController: UITextFieldDelegate {
  @objc
  private func textChanged(_ sender: UITextField) {
    let enable = !(searchTextField.text ?? "").isEmpty
    searchButton.isUserInteractionEnabled = enable
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    searchButton.sendActions(for: .touchUpInside)
    return true
  }
}


// MARK: - UITalbleView Delegate, DataSource
extension NewFriendViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int { 1 }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { matchedUsers.count }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let currentProfile = db?.userModel else {
      print("Please log in again")
      return UITableViewCell()
    }

    let contactCell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") as! ContactCell
    let user = matchedUsers[indexPath.row]
    contactCell.addFriendDelegate = self
    contactCell.addButtonVisible = true
    contactCell.profileName.text = user.firstName + " " + user.lastName
    contactCell.username.text = user.username
    contactCell.contactID = user.id
    
    for request in currentProfile.allRequests {
      if request.fromUser.id == currentProfile.id &&    // If a friend request is from the current user
         request.toUser.id   == contactCell.contactID   // If the matched user has already been sent a request
      {
        contactCell.isRequestSent = true
        break
      }
    }
    
    return contactCell
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if let cell = cell as? ContactCell {
      cell.checkRequestStatus()
    }
  }
}

extension NewFriendViewController: ContactCellAddFriendDelegate {
  func addNewFriend(_ contactCell: ContactCell, completion: @escaping (Error?) -> Void) {
    let fullName = contactCell.profileName.text?.components(separatedBy: " ")

    db?.sendFriendRequest(
      participantID: contactCell.contactID,
      firstName: fullName![0],
      lastName: fullName![1],
      username: contactCell.username.text!
    ) { error in
      if let error = error {
        completion(error)
      } else {
        completion(nil)
      }
    }
  }
  
  func animationComplete(_ finished: Bool) {
    
  }
}

