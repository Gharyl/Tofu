import UIKit

class NewChatViewController: UIViewController {
  var textfieldHeightManger: TextFieldHeightManager?
  weak var coordinator: Coordinator?
  let firebase: FirebaseCommunicator
  let friends: [Friend]
  var matchedFriends: [Friend] = []
  private var animatableHeight: NSLayoutConstraint?
  
  private lazy var newMessageLabel: UILabel = {
    let newMessageLabel = UILabel()
    newMessageLabel.text = "New Message"
    newMessageLabel.textColor = .black
    newMessageLabel.font = .systemFont(ofSize: 18)
    newMessageLabel.translatesAutoresizingMaskIntoConstraints = false
    return newMessageLabel
  }()
  
  private lazy var cancelButton: UIButton = {
    let cancelButton = UIButton()
    cancelButton.setTitle("Cancel", for: .normal)
    cancelButton.titleLabel?.font = .systemFont(ofSize: 16)
    cancelButton.addTarget(self, action: #selector(cancelButtonTapped(_:)), for: .touchUpInside)
    cancelButton.setTitleColor(K.colorTheme2.gray3, for: .normal)
    cancelButton.setTitleColor(K.colorTheme2.gray3.withAlphaComponent(0.7), for: .highlighted)
    cancelButton.translatesAutoresizingMaskIntoConstraints = false
    return cancelButton
  }()

  private lazy var hStack: UIStackView = {
    let hStack = UIStackView()
    hStack.axis = .horizontal
    hStack.distribution = .equalSpacing
    hStack.alignment = .center
    hStack.isLayoutMarginsRelativeArrangement = true
    hStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
    hStack.translatesAutoresizingMaskIntoConstraints = false
    return hStack
  }()
  
  private lazy var toLabel: UILabel = {
    let toLabel = UILabel()
    toLabel.text = "To: "
    toLabel.font = UIFont(name: K.themeFont, size: 16)
    toLabel.translatesAutoresizingMaskIntoConstraints = false
    return toLabel
  }()
  
  private lazy var participantTextField: UISearchTextField = {
    let searchField = UISearchTextField()
    searchField.font = UIFont(name: K.themeFont, size: 15)
    searchField.tintColor = .gray
    searchField.leftView = nil
    searchField.delegate = self
    searchField.allowsCopyingTokens = false
    searchField.autocorrectionType = .no
    searchField.backgroundColor = K.colorTheme.beige2.withAlphaComponent(0.2)
    searchField.translatesAutoresizingMaskIntoConstraints = false
    return searchField
  }()
  
  private lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.dataSource = self
    tableView.delegate   = self
    tableView.translatesAutoresizingMaskIntoConstraints = false
    return tableView
  }()
  
  private lazy var messageTextField: UITextField = {
    let messageTextField = MessageTextField()
    let button: UIButton = messageTextField.rightView as! UIButton
    button.addTarget(self, action: #selector(sendMessage(_:)), for: .touchUpInside)
    messageTextField.delegate = self
    messageTextField.translatesAutoresizingMaskIntoConstraints = false
    return messageTextField
  }()
  
  // Create new Chat object with participant IDs and ChatMessage object
  @objc
  private func sendMessage(_ sender: UIButton) {
    // Disables sendButton until firebase returns a response
    messageTextField.rightView?.isUserInteractionEnabled = false
  
    guard let safeMessage = messageTextField.text else { return }
    
    // Preparing data to create Chat object and transition to ChatViewController
    let profiles: [Friend] = participantTextField.tokens.map { $0.representedObject as! Friend }
    firebase.createNewChat(with: profiles, and: safeMessage) { result in
      switch result {
        case .failure(let error):
          // TODO: - Show error to user
          //
          print(error.localizedDescription)
        case .success(_):
          // This is access from background thread
          // Need to be on the main thread
          DispatchQueue.main.async {
            self.coordinator?.returnToPreviousView()
          }
      }
    }
  }
  
  // Dismisses this view controller
  @objc
  private func cancelButtonTapped(_ sender: UIButton) {
    coordinator?.returnToPreviousView()
  }

  private func setSubViews() {
    
    hStack.addArrangedSubview(toLabel)
    hStack.addArrangedSubview(participantTextField)
    view.addSubview(newMessageLabel)
    view.addSubview(cancelButton)
    view.addSubview(hStack)
    view.addSubview(tableView)
    view.addSubview(messageTextField)
  }
  
  private func setConstraints() {
    animatableHeight = messageTextField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    NSLayoutConstraint.activate([
      newMessageLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
      newMessageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      
      cancelButton.widthAnchor.constraint(equalToConstant: 50),
      cancelButton.centerYAnchor.constraint(equalTo: newMessageLabel.centerYAnchor),
      cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      
      hStack.topAnchor.constraint(equalTo: newMessageLabel.bottomAnchor, constant: 20),
      hStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      hStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      hStack.bottomAnchor.constraint(equalTo: tableView.topAnchor),
      hStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),

      participantTextField.heightAnchor.constraint(equalToConstant: 25),
      participantTextField.leadingAnchor.constraint(equalTo: toLabel.trailingAnchor, constant: 5),
      participantTextField.trailingAnchor.constraint(equalTo: hStack.trailingAnchor, constant: -10),
            
      tableView.topAnchor.constraint(equalTo: hStack.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: messageTextField.topAnchor, constant: -10),
      
      messageTextField.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 10),
      messageTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
      messageTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
      messageTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: K.textFieldHeight),
      animatableHeight!,
    ])
  }
  
  private func setTableview() {
    tableView.register(ContactCell.self, forCellReuseIdentifier: "ContactCell")
    tableView.rowHeight = K.contactCellHeight
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    // TextField functions
    participantTextField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
    messageTextField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
    
    setSubViews()
    setConstraints()
    setTableview()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    participantTextField.becomeFirstResponder()
  }
  
  init(friends: [Friend], coordinator: Coordinator, firebase: FirebaseCommunicator) {
    self.friends     = friends
    self.coordinator = coordinator
    self.firebase    = firebase
    super.init(nibName: nil, bundle: nil)
  }
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - UITableView Delegate
extension NewChatViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return matchedFriends.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let contactCell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") as! ContactCell
    
    // TODO: - Fetch each friend's profile image URL
    // ...
    
    let friend = matchedFriends[indexPath.row]
    contactCell.profileName.text = friend.firstName + " " + friend.lastName
    contactCell.username.text    = friend.firstName
    // Making a background color when tapped
    let backgroundView = UIView()
    backgroundView.backgroundColor = K.colorTheme.beigeL.withAlphaComponent(0.5)
    contactCell.selectedBackgroundView = backgroundView
    return contactCell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // Creating UISearchToken to display selected participant(s)
    let matchedFriend = matchedFriends[indexPath.row]
    let searchToken = UISearchToken(icon: nil, text: matchedFriend.firstName)
    searchToken.representedObject = matchedFriend
    participantTextField.tokens.append(searchToken)
    // Removing textField.text when selecting a contact
    participantTextField.text?.removeAll()
    participantTextField.sendActions(for: .editingChanged) // Refresh tableview
    tableView.deselectRow(at: indexPath, animated: true)
  }
}


// MARK: - Search TextField Delegate/ Function
extension NewChatViewController: UISearchTextFieldDelegate {
  @objc
  private func textChanged(_ sender: UITextField) {
    // Check whether a participant is selected AND if there is a messaged typed
    let enable = !(messageTextField.text ?? "" ).isEmpty && !participantTextField.tokens.isEmpty
    // If both conditions are met, 'sendButton' will be enabled to allow user to send message
    messageTextField.rightView?.isUserInteractionEnabled = enable
    // Matching participantTextfield's text with the user's friends list
    guard let safeText = participantTextField.text else { return }
    matchedFriends = friends.filter { friend in
      // Checking which friend has been selected already
      let selectedUsername: [String] = self.participantTextField.tokens
        .map { $0.representedObject as! Friend }
        .map { $0.username}
      // If friend is already selected, don't show in tableview
      if selectedUsername.contains(friend.username) {
        return false
      }
      // Otherwise if the text matches first name, last name, or username, show them in tableview
      return
        friend.firstName.localizedCaseInsensitiveContains(safeText) ||
        friend.lastName.localizedCaseInsensitiveContains(safeText)  ||
        friend.username.localizedCaseInsensitiveContains(safeText)
    }
    tableView.reloadData()
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    textfieldHeightManger = TextFieldHeightManager(constraint: animatableHeight!, mainView: self)
    textfieldHeightManger?.delegate = self
    NotificationCenter.default.addObserver(textfieldHeightManger!, selector: #selector(textfieldHeightManger?.keyboardAppeared(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
  }
}
//
//// MARK: - UIButton Extention
//extension UIButton {
//  // Dims the color based on isUserInteractionEnabled
//  override open var isUserInteractionEnabled: Bool {
//    didSet {
//      if isUserInteractionEnabled {
//        alpha = 1
//      } else {
//        alpha = 0.5
//      }
//    }
//  }
//}

extension NewChatViewController: TextFieldHeightDelegate {
  var frame: CGRect { view.convert(messageTextField.frame, to: nil) }
}
