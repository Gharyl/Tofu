import UIKit

class ChatViewController: UIViewController {
  weak var coordinator: ChatVCCoordinator?
  weak var db: FirebaseCommunicator?
  
  var wasUserEditing: Bool = false
  var isKeyboardOnScreen: Bool = false
  var tableviewOffset: CGFloat?
  var selectedCellIndex: Int?
  // Pagination
  var viewDidAppear: Bool = false
  var didFinishedLoadingNewMessages: Bool = false
  var isPaginationUpdate: Bool = false
  var tableViewMessageCountLimit: Int = 25
  var tableViewPaginationNumber: Int = 1 {
    didSet {
      tableViewMessageCountLimit += 25
      isPaginationUpdate = true
      updateTableViewSource()
    }
  }
  
  weak var selectedCell: MessageCell? {
    get {
      if let selectedCellIndex = selectedCellIndex {
        return tableView.cellForRow(at: IndexPath(row: selectedCellIndex, section: 0)) as? MessageCell
      } else {
        print("selectedCellIndex is not init")
        return nil
      }
    }
  }
  
  var messagesToDisplay: ArraySlice<ChatMessage> = [] {
    didSet {
      if oldValue.isEmpty { return }
      
      let differences = messagesToDisplay.difference(from: oldValue)
      let newMessageIndex = differences.compactMap { difference -> IndexPath? in
        guard case let .insert(offset: index, element: _, associatedWith: _) = difference else { return nil }
        return IndexPath(row: index, section: 0)
      }
      
      var isSender: Bool = false
      if let newMessage = chat.messages.last {
        isSender = newMessage.messageSenderID == self.db?.userModel?.id
      }
      
      // Check if there's new messages in the array. If not, then it's a message reaction update
      let differenceCount = messagesToDisplay.count - oldValue.count
      if differenceCount > 0 {
        // If user wants to load older messages
        if isPaginationUpdate {
          tableView.reloadData()
          autoScrollToBottom(false, to: IndexPath(row: differenceCount, section: 0))
          
        // New messages from Firebase
        } else {
          tableView.performBatchUpdates {
            tableView.insertRows(at: newMessageIndex, with: (isSender && !isPaginationUpdate) ? .right : .left)
          }
          autoScrollToBottom() // If scrolling is done in completion block, the animation is jank. Must be outside.
        }

        isPaginationUpdate = false // Reset
        
      // Message Reaction update
      } else {
        // Update message reaction
        guard let newIndexToUpdate = newMessageIndex.first else { return }
        guard let cellToTrigger: MessageCell = tableView.cellForRow(at: newIndexToUpdate) as? MessageCell else { return }

        let newReactions: [ReactionPopUpMenu.ReactionType] = chat.messages[newIndexToUpdate.row].reactions
        // Adding a delay because the screen update is faster than the transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
          cellToTrigger.reactions = newReactions
          cellToTrigger.shouldAnimate = true
          cellToTrigger.updateReactionIcons()
          cellToTrigger.reactionIcons.forEach { icon in
            icon.transform = .identity
          }

          UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: [.curveEaseInOut]) {
            self.tableView.performBatchUpdates(nil)
          }
        }
      }
      
      didFinishedLoadingNewMessages = true // Reset
    }
  }
  
  var chat: Chat! {
    didSet {
      // oldValue is 'nil' when 'chat' is first initialized
      // If the number of messages is more than before, increase message limit
      if oldValue != nil &&
         chat.messages.count > oldValue.messages.count
      {
         tableViewMessageCountLimit += chat.messages.count - oldValue.messages.count
      }
      updateTableViewSource()
    }
  }
  
  
  
  @objc private func refresh(_ sender: UIRefreshControl) {
    print("refreshing")
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      print("end refreshing")
      self.tableView.refreshControl!.endRefreshing()
    }
  }
  
  private lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.dataSource = self
    tableView.delegate = self
    tableView.keyboardDismissMode = .onDrag
    
    tableView.refreshControl = UIRefreshControl()
    tableView.refreshControl!.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
    
    tableView.translatesAutoresizingMaskIntoConstraints = false
    return tableView
  }()
  
  
  private lazy var messageTextField: MessageTextField = {
    let messageTextField = MessageTextField()
    let button: UIButton = messageTextField.rightView as! UIButton
    button.addTarget(self, action: #selector(sendMessage(_:)), for: .touchUpInside)
    messageTextField.delegate = self
    messageTextField.translatesAutoresizingMaskIntoConstraints = false
    return messageTextField
  }()
  
  private lazy var backBarButton: UIBarButtonItem = {
    let backBarButton = UIBarButtonItem()
    backBarButton.image = UIImage(systemName: "arrow.backward")
    backBarButton.tintColor = K.colorTheme2.blue
    backBarButton.target = self
    backBarButton.action = #selector(backButtonTapped(_:))
    return backBarButton
  }()
  
  private lazy var bottomSpacer: UIView = {
    let bottomSpacer = UIView()
    bottomSpacer.backgroundColor = .red
    bottomSpacer.translatesAutoresizingMaskIntoConstraints = false
    return bottomSpacer
  }()
  
  @objc
  private func backButtonTapped(_ sender: UIBarButtonItem) {
    coordinator?.returnToPreviousView()
  }
  
  @objc
  private func sendMessage(_ sender: UIButton) {
    // Disables sendButton until firebase returns a response
    messageTextField.isButtonEnabled = false
    guard let safeMessage = messageTextField.text else { return }
    messageTextField.text = ""
    
    db?.updateChat(
      forChatID: chat.id!,
      newMessage: safeMessage
    ) { error in
      if let error = error {
        print(error.localizedDescription)
      }
    }
  }
  
  // Recording and calculating tableView bottom offset when keyboard shows up
  @objc
  private func keyboardWillAppear(_ sender: NSNotification) {
    let frame = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
    let yOffset = messageTextField.frame.height
    tableviewOffset = frame!.height - yOffset// + (UIApplication.shared.windows.first?.safeAreaInsets.bottom)!
    tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tableviewOffset!, right: 0)
    isKeyboardOnScreen = true
    autoScrollToBottom()
  }
  
  @objc
  private func keyboardDisappeared(_ sender: NSNotification) {
    if !wasUserEditing {
      tableView.contentInset = .zero
    }
    
    isKeyboardOnScreen = false
    autoScrollToBottom()
  }
  
  private func autoScrollToBottom(
    _ animated: Bool = true,
    to row: IndexPath? = nil
  ) {
    let bottomRow = IndexPath(row: tableView.numberOfRows(inSection: 0)-1, section: 0)
    DispatchQueue.main.async {
      self.tableView.scrollToRow(
        at: row == nil ? bottomRow : row!,
        at: row == nil ? .bottom : .top,
        animated: animated)
    }
  }
  
  private func setSubviews() {
    view.addSubview(tableView)
    view.addSubview(messageTextField)
  }
  
  private func setConstraints(){
    let tableViewBottomOffset = UIApplication.shared.windows.first!.safeAreaInsets.bottom
    
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20 - tableViewBottomOffset - K.textFieldHeight),
      
      messageTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
      messageTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
      messageTextField.heightAnchor.constraint(equalToConstant: K.textFieldHeight),
      messageTextField.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -10),
    ])
  }
  
  private func setNavigationBar(){
    guard let userModel = db?.userModel else { return }
    
    let participantFirstNames = chat.participants
      .map{ $0.firstName }
      .filter{ $0 != userModel.firstName }
    
    title = participantFirstNames.joined(separator: ", ")
    navigationItem.leftBarButtonItem = backBarButton
  }
  
  private func setTableview() {
    tableView.register(MessageCell.self, forCellReuseIdentifier: "MessageCell")
    tableView.separatorStyle = .none
    tableView.allowsSelection = false
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    setTableview()
    setSubviews()
    setConstraints()
    setNavigationBar()
    
    messageTextField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardDisappeared(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    autoScrollToBottom(false)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    viewDidAppear = true
    didFinishedLoadingNewMessages = true
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    coordinator?.viewDidPop()
  }
  
  init(coordinator: ChatVCCoordinator, db: FirebaseCommunicator) {
    self.coordinator = coordinator
    self.db = db
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - UITableView functionalities
extension ChatViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
  /// This function serves to check if the user has scrolled to the topmost of the UITableView, to determine loading
  /// more messages and trigger pagination functionality.
  ///
  /// This functionality should be replaced by UIRefreshControl, which is in ScrollView.
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    // If user scrolls to the top of the tableview, load more messages
    if scrollView.contentOffset.y <= 0 &&
       self.viewDidAppear &&  // Prevents prematurely calling this function
       didFinishedLoadingNewMessages // Prevents reapeatedly and excessively loading more messages
    {
      didFinishedLoadingNewMessages = false
      tableViewPaginationNumber += 1
    }
  }
  
  private func updateTableViewSource() {
    let startingPosition: Int = chat.messages.count - (tableViewPaginationNumber * tableViewMessageCountLimit)
    messagesToDisplay = chat.messages[max(startingPosition, 0)...chat.messages.count-1]
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messagesToDisplay.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let currentUserID = db?.user?.uid else {
      print("Please sign in again")
      coordinator?.restart()
      return UITableViewCell()
    }
    // ArraySlice's index starts on the parent array's index
    /* -- Example:
        let parent: [Int] = [1, 2, 3, 4, 5, 6, 7]
        let child: ArraySlice<Int> = parent[2...4]
     
        print(child.startIndex) // prints 2
        print(child[0]) // Index out of bounds error
        print(child[2]) // prints 3
    */
    let startingIndex = messagesToDisplay.startIndex + indexPath.row
    let messageCell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as! MessageCell
    let currentMessage = messagesToDisplay[startingIndex]
    
    var lastSenderID: String = ""
    if startingIndex - 1 >= messagesToDisplay.startIndex {
      lastSenderID = messagesToDisplay[startingIndex - 1].messageSenderID
    }

    var isConsecutive: Bool = false
    let isSender: Bool = currentMessage.messageSenderID == currentUserID
    if !lastSenderID.isEmpty {
      isConsecutive = lastSenderID == currentMessage.messageSenderID
    }

    let participants: [Friend] = chat.participants
    let messageSender: Friend? = participants
      .filter{ $0.id == currentMessage.messageSenderID }
      .first

    guard let messageSenderFirstName: String = messageSender?.firstName else { return UITableViewCell() }

    ImageManager.shared.retreiveProfileImageFor(id: currentMessage.messageSenderID) { profileImage in
      DispatchQueue.main.async {
        if isSender {
          messageCell.rightImage.image = profileImage
        } else {
          messageCell.leftImage.image = profileImage
        }
      }
    }

    messageCell.participantName.text = messageSenderFirstName
    messageCell.messageTextView.messageText.text = currentMessage.messageBody
    messageCell.tag = indexPath.row  // The 'tag' property is the index of this tableCell within this tableView
    messageCell.delegate = self
    messageCell.reactions = currentMessage.reactions
    messageCell.isSender = isSender
    messageCell.isConsecutiveMessage = isConsecutive

    messageCell.finalizeViewAppearance()
    return messageCell
  }
}


// MARK: - UITextfield Delegate to determine when the user can send a message
extension ChatViewController: UITextFieldDelegate {
  @objc
  func textChanged(_ sender: MessageTextField) {
    let enable = !(sender.text ?? "").isEmpty
    sender.isButtonEnabled = enable
  }
}


// MARK: - MessageCellDelegate for transitioning to ReactionPopUpMenuVC
extension ChatViewController: MessageCellDelegate {
  func longpressedDetected(_ selectedCell: MessageCell, _ index: Int) {
    self.selectedCellIndex = index
    
    let relativeIndex: Int = selectedCell.tag + messagesToDisplay.startIndex
    let selectedChatMessage: ChatMessage = messagesToDisplay[relativeIndex]
    let cellFrame = selectedCell.hStackRef.convert(selectedCell.messageTextView.frame, to: nil)
    let messageView = selectedCell.messageTextView.snapshotView(afterScreenUpdates: false)!
    
    // Instead of using snapshotView(), which omits the navigation bar, I am using Core Graphics to draw.
    // Getting the entire screen's layer, so we can create a snapshot INCLUDING the navigation bar.
    let chatVCView = UIApplication.shared.keyWindow!.layer
    // Accessing Core Graphics..
    // Must supply a CGSize, which will be the size of the returned image.
    UIGraphicsBeginImageContext(chatVCView.frame.size)
    guard let context = UIGraphicsGetCurrentContext() else {
      print("Failed to secure UIGraphicsGetCurrentContext()")
      return
    }
    // 'render(in:)' can be called by any CALayer class
    chatVCView.render(in: context)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    wasUserEditing = isKeyboardOnScreen
    print("Keyboard is on? \(isKeyboardOnScreen)")
    if isKeyboardOnScreen {
      self.messageTextField.resignFirstResponder()
    }

    coordinator?.showMessageReactionVC(messageView, image!.blurImage(), cellFrame, selectedChatMessage)
  }
}


// MARK: - UIGestureRecognizerDelegate to enable NavigationController's interactivePopGesture
extension ChatViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}


// MARK: - UIImage Extention: adding blur effect to the image
// Source: https://github.com/FlexMonkey/Blurable
// Note: I tried many other methods to create blur effect, but they have a strange/undesired effect.
//       This is the only method I found that works as I desire.
extension UIImage {
  func blurImage(_ blurRadius: CGFloat = 5) -> UIImage {
    let context = CIContext()
    let ciOriginalImage = CIImage(image: self)
    guard let gaussianBlur = CIFilter(name: "CIGaussianBlur") else { // Why are we passing String type? Why not enum? smh
      print("Maybe wrong CIFilter name?")
      return UIImage()
    }
    
    // Setting the CIFilter's target, I think?
    gaussianBlur.setValue(ciOriginalImage, forKey: kCIInputImageKey)
    // Setting the value for the filter effect, which is different for each filter.
    // For CIGaussianBlur, use 'kCIInputRadiusKey' to change the blur radius/effect.
    gaussianBlur.setValue(blurRadius, forKey: kCIInputRadiusKey)
    // Extracting the CIImage, which is just data that represents an image.
    guard let ciImage = gaussianBlur.value(forKey: kCIOutputImageKey) as? CIImage else {
      print("Failed to cast to CIImage")
      return UIImage()
    }
    // Using that CIImage, create a CGImage for that we MUST specify the frame.
    guard let cgImage = context.createCGImage(ciImage, from: UIScreen.main.bounds) else {
      print("Failed to create CGImage")
      return UIImage()
    }
    
    return UIImage(cgImage: cgImage)
    // An alternative way: UIImage(ciImage: ciImage) works as well, except the effect looks....bugged?
    // However, creating a CGImage from CIImage appears to 'fix' the bug.
  }
}


// MARK: - ChatVCTransitionHelper for UIViewControllerAnimatedTransitioning
extension ChatViewController: ChatVCTransitionHelper {
  var selectedCellFrame: CGRect {
    let frame = selectedCell!.hStackRef.convert(selectedCell!.messageTextView.frame, to: nil)
    return frame
  }
  var messageTextfieldRef: UITextField { messageTextField }
  var tableViewRef: UITableView { tableView }
}

protocol ChatVCTransitionHelper {
  var selectedCellFrame: CGRect { get }
  var messageTextfieldRef: UITextField { get }
  var tableViewRef: UITableView { get }
}
