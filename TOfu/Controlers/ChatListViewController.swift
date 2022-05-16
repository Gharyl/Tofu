import UIKit

class ChatListViewController: UIViewController {
  weak var coordinator: HomeVCCoordinator?
  var db: FirebaseCommunicator?
  var chats: [Chat] {
    didSet {
      chats.sort{ $0.latestActivityDate > $1.latestActivityDate }
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
    }
  }
  var delegate: ChatListViewDelegate?
  
  private lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.delegate   = self
    tableView.dataSource = self
    tableView.translatesAutoresizingMaskIntoConstraints = false
    return tableView
  }()
  
  private lazy var invisibleView: UIView = {
    let invisibleView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(resetView(_:)))
    invisibleView.addGestureRecognizer(tapGesture)
    invisibleView.backgroundColor = .clear
    invisibleView.isUserInteractionEnabled = true
    return invisibleView
  }()
  
  func setTableView(){
    // Adding tableview onto the screen
    view.addSubview(tableView)
    tableView.rowHeight = K.cellHeight //80
    tableView.register(ChatListViewCell.self, forCellReuseIdentifier: "ChatListCell")
  }
  
  func setConstraints(){
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
  }
  
  
  private func populateTableView() {
    tableView.reloadData()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = K.colorTheme2.gray1
    setTableView()
    setConstraints()
    populateTableView()
  }
  
  init(chats: [Chat]) {
    self.chats = chats
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ChatListViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return chats.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let userModel = db?.userModel else { return UITableViewCell() }
    
    let chatCell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell") as! ChatListViewCell
    let currentChatCell = chats[indexPath.row]
    let participantFirstNames = currentChatCell.participants
      .filter{ $0.firstName != userModel.firstName }
      .map{ $0.firstName }
    
    chatCell.participants.text = participantFirstNames.joined(separator: ", ")
    chatCell.previewMessage.text = currentChatCell.previewMessage
    
    // Fetching participant's profile image
    // 1. Assign a default picture
    // 2. Check if the participant has an image on Firebase
    let isGroupMessage: Bool = participantFirstNames.count > 1
    chatCell.chatImage.image = UIImage(systemName: isGroupMessage ? "person.3.fill" : "person.crop.circle") //1
    if !isGroupMessage {
      Task {
        let participantID = currentChatCell.participants.filter{ $0.firstName != userModel.firstName }[0].id
        ImageManager.shared.retreiveProfileImageFor(id: participantID) { image in
          DispatchQueue.main.async {
            chatCell.chatImage.image = image
          }
        }
      }
    }
    
    chatCell.lastActivity.text = "\(currentChatCell.latestActivityDate.defaultFormat())"
    return chatCell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    
    //TODO: FIX THIS TRANSITION
    
    
    
    let selectedChat: Chat = chats[indexPath.row]
    coordinator?.showChatViewController(nil, selectedChat)
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

// MARK: - HomeViewController for Enable/Disable Tableview Interaction
extension ChatListViewController {
  func overlayInvisibleView() {
    view.addSubview(invisibleView)
  }
  
  @objc
  private func resetView(_ sender: UITapGestureRecognizer) {
    delegate?.reset { // Removing the insivibleView
      self.invisibleView.removeFromSuperview()
    }
  }
}

// MARK: - Date Extension
extension Date {
  func defaultFormat() -> String {
    let currentDate = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = .current
    
    let difference = Calendar.current.dateComponents(
      [
        Calendar.Component.minute,
        Calendar.Component.hour,
        Calendar.Component.day,
      ],
      from: currentDate,
      to: self
    )
    
    var formatedDate: String = ""
    if difference.day! >= 7 {
      dateFormatter.dateFormat = "MM-dd-yy"
      formatedDate = dateFormatter.string(from: self)
    } else if difference.day! > 0 {
      formatedDate = dateFormatter.weekdaySymbols[Calendar.current.component(.weekday, from: self) - 1]
    } else {
      dateFormatter.dateFormat = "HH:mm"
      formatedDate = dateFormatter.string(from: self)
    }
    
    return formatedDate
  }
}


protocol ChatListViewDelegate {
  func reset(completion: () -> Void)
}
