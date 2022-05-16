import UIKit

class MessageCell: UITableViewCell {
  private let margin: CGFloat = 12
  var cellTopPadding: NSLayoutConstraint?
  var isSender: Bool?
  var isConsecutiveMessage: Bool?
  var shouldAnimate: Bool = false
  weak var delegate: MessageCellDelegate?
  
  private let leftSpacer:  UIView = UIView()
  private let rightSpacer: UIView = UIView()
  
  var reactions: [ReactionPopUpMenu.ReactionType] = [] {
    // Every time new reactions are received, remove all the old ones
    didSet {
      reactionIcons.forEach { $0.removeFromSuperview() }
      reactionIcons.removeAll()
    }
  }
  var reactionIcons: [UIButton] = []
  
  lazy var participantName: UILabel = {
    let participantName = UILabel()
    participantName.text = "default"
    participantName.font = .systemFont(ofSize: 10)
    participantName.translatesAutoresizingMaskIntoConstraints = false
    return participantName
  }()
  
  // Using UIStackView in UITableViewCell somehow provides dynamic cell height...?
  private lazy var hStack: UIStackView = {
    let hStack = UIStackView()
    hStack.axis = .horizontal
    hStack.alignment = .top
    //    hStack.distribution = .equalSpacing this breaks everything if uncommented, but why?
    hStack.spacing = 5
    hStack.isLayoutMarginsRelativeArrangement = true
    hStack.translatesAutoresizingMaskIntoConstraints = false
    return hStack
  }()
  
  lazy var leftImage: UIImageView = {
    let leftImage = UIImageView()
    leftImage.layer.cornerRadius = 20
    leftImage.contentMode = .scaleAspectFill
    leftImage.clipsToBounds = true
    leftImage.image = UIImage(systemName: "person.circle.fill")
    leftImage.tintColor = K.colorTheme.gray
    leftImage.translatesAutoresizingMaskIntoConstraints = false
    return leftImage
  }()
  
  lazy var rightImage: UIImageView = {
    let rightImage = UIImageView()
    rightImage.layer.cornerRadius = 20
    rightImage.contentMode = .scaleAspectFill
    rightImage.clipsToBounds = true
    rightImage.image = UIImage(systemName: "person.circle.fill")
    rightImage.tintColor = K.colorTheme.gray
    rightImage.translatesAutoresizingMaskIntoConstraints = false
    return rightImage
  }()
  
  lazy var messageTextView: MessageTextView = {
    let messageTextView = MessageTextView()
    messageTextView.layer.cornerRadius = 17
    messageTextView.isUserInteractionEnabled = true
    return messageTextView
  }()
  
  lazy var tailView: UIView = {
    let path = UIBezierPath()
    
    
    return UIView()
  }()
  
  @objc
  private func longpressed(_ sender: UILongPressGestureRecognizer) {
    switch sender.state {
      case .began:
        self.delegate?.longpressedDetected(self, self.tag)
      default:
        break
    }
  }
  
  override func prepareForReuse() {
    rightImage.image = UIImage(systemName: "person.circle.fill")
    leftImage.image = UIImage(systemName: "person.circle.fill")
    isSender = nil
    isConsecutiveMessage = nil
    for reactionIcon in reactionIcons {
      reactionIcon.removeFromSuperview()
    }
    reactions = []
    participantName.removeFromSuperview()
  }
  
  private func setSubviews() {
    hStack.addArrangedSubview(leftImage)
    hStack.addArrangedSubview(leftSpacer)
    hStack.addArrangedSubview(messageTextView)
    hStack.addArrangedSubview(rightSpacer)
    hStack.addArrangedSubview(rightImage)
    addSubview(hStack)
  }
  
  private func setConstraints(){
    cellTopPadding = hStack.topAnchor.constraint(equalTo: topAnchor, constant: margin)
    NSLayoutConstraint.activate([
      messageTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 38),
      messageTextView.widthAnchor.constraint(greaterThanOrEqualToConstant: 40),
      
      cellTopPadding!,
      
      hStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 30),
      hStack.bottomAnchor.constraint(equalTo: bottomAnchor),
      hStack.leadingAnchor.constraint(equalTo: leadingAnchor),
      hStack.trailingAnchor.constraint(equalTo: trailingAnchor),
      
      leftImage.heightAnchor.constraint(equalToConstant: 40),
      leftImage.widthAnchor.constraint(equalToConstant: 40),
      
      rightImage.heightAnchor.constraint(equalToConstant: 40),
      rightImage.widthAnchor.constraint(equalToConstant: 40),
    ])
  }
  
  private func setActions() {
    let longpressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longpressed(_:)))
    longpressGesture.minimumPressDuration = 0.1
    messageTextView.addGestureRecognizer(longpressGesture)
  }
  
  func finalizeViewAppearance() {
    guard let isSender = isSender,
          let isConsecutiveMessage = isConsecutiveMessage
    else {
      print("'isSender' and 'isConsecutiveMessage' have not been initialized")
      return
    }
    
    leftImage.isHidden  = isSender
    rightImage.isHidden = !isSender
    
    leftSpacer.isHidden = !isSender
    rightSpacer.isHidden = isSender
    
    messageTextView.backgroundColor = isSender ? K.colorTheme2.blue : K.colorTheme2.gray2
    messageTextView.messageText.textColor = isSender ? .white : .black
    
    hStack.directionalLayoutMargins = NSDirectionalEdgeInsets(
      top:    0, leading:  isSender ? 50 : 10,
      bottom: 0, trailing: isSender ? 10 : 50)
    
    updateReactionIcons()
    
    // Placing participantName on top of messageTextView
    if !isSender && !isConsecutiveMessage {
      addSubview(participantName)
      NSLayoutConstraint.activate([
        participantName.bottomAnchor.constraint(equalTo: messageTextView.topAnchor, constant: -2),
        participantName.leadingAnchor.constraint(equalTo: messageTextView.leadingAnchor),
      ])
    }
  }
  
  func updateReactionIcons() {
    guard let isSender = isSender,
          let isConsecutiveMessage = isConsecutiveMessage
    else {
      print("'isSender' and 'isConsecutiveMessage' have not been initialized")
      return
    }
    
    if !reactions.isEmpty {
      for reaction in reactions {
        let reactionIcon: UIButton = UIButton()
        reactionIcon.isUserInteractionEnabled = false
        reactionIcon.setTitle(reaction.rawValue, for: .normal)
        reactionIcon.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        reactionIcon.backgroundColor = isSender ? K.colorTheme2.gray2 : K.colorTheme2.blue
        reactionIcon.layer.cornerRadius = 15
        reactionIcon.translatesAutoresizingMaskIntoConstraints = false
        
        reactionIcons.append(reactionIcon)
        addSubview(reactionIcon)
  
        NSLayoutConstraint.activate([
          reactionIcon.widthAnchor.constraint(equalToConstant: 30),
          reactionIcon.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        if isSender {
          reactionIcon.trailingAnchor.constraint(equalTo: self.messageTextView.leadingAnchor, constant: 13).isActive = true
        } else {
          reactionIcon.leadingAnchor.constraint(equalTo: self.messageTextView.trailingAnchor, constant: -13).isActive = true
        }
        reactionIcon.bottomAnchor.constraint(equalTo: self.messageTextView.topAnchor, constant: 13).isActive = true
        layoutIfNeeded()
      }
      
      // If ChatVC is currently displayed when a new reaction is received, perform animation
      if shouldAnimate {
        reactionIcons.forEach{ $0.transform = CGAffineTransform(scaleX: 0.01, y: 0.01) }
        UIView.animate(
          withDuration: 0.5, delay: 0.1,
          usingSpringWithDamping: 0.4,
          initialSpringVelocity: 0.1, options: [.curveEaseInOut]
        ) {
          self.reactionIcons.forEach{ $0.transform = .identity }
        }
        shouldAnimate = false
      }
      // Extra spacing to accomodate reactionIcon or participantName
      self.cellTopPadding?.constant = 25
    } else {
      self.cellTopPadding?.constant = isConsecutiveMessage ? 2 : self.margin
    }
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.isUserInteractionEnabled = true
    setSubviews()
    setConstraints()
    setActions()
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension MessageCell: MessageCellTransitionHelper {
  var hStackRef: UIStackView { hStack }
  var reactionIconFrame: CGRect {
    guard let reactionIcon = reactionIcons.first else {
      print("ReactionIcon has not been init")
      return .zero
    }
    return convert(reactionIcon.frame, to: nil)
  }
}

protocol MessageCellTransitionHelper {
  var hStackRef: UIStackView { get }
  var reactionIconFrame: CGRect { get }
}

protocol MessageCellDelegate: AnyObject {
  func longpressedDetected(_: MessageCell, _: Int)
}
