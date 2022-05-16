import UIKit

class MessageReactionViewController: UIViewController {
  var db: FirebaseCommunicator?
  weak var coordinator: MessageReactionVCCoordinator?
  private var newAnchorPoint: CGPoint?
  var isSender: Bool?
  var selectedChatMessage: ChatMessage?
  var selectedChatID: String?
  // Snapshot 'MessageCell' view from ChatViewController.swift
  var selectedMessageView: UIView! {
    didSet {
      selectedMessageView.layer.shadowColor = K.colorTheme2.gray3.cgColor
      selectedMessageView.layer.shadowRadius = 3
      selectedMessageView.layer.shadowOpacity = 0.3
      selectedMessageView.layer.shadowOffset = CGSize(width: 0, height: 5)
    }
  }
  // Snapshot of ChatViewController.swift the moment the user longpresses a 'MessageCell'
  // This is the background
  var chatVCView: UIImageView! {
    didSet {
      chatVCView.isUserInteractionEnabled = true
      chatVCView.translatesAutoresizingMaskIntoConstraints = false
    }
  }
  // Adds a darkened effect
  private lazy var darkendView: UIView = {
    let darkenedView = UIView()
    darkenedView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
    darkenedView.addGestureRecognizer(tapGesture)
    darkenedView.translatesAutoresizingMaskIntoConstraints = false
    return darkenedView
  }()
  
  private lazy var reactionPopUpMenu: ReactionPopUpMenu = {
    let reactionPopUpMenu = ReactionPopUpMenu(tailFrame: selectedMessageView.frame)
    reactionPopUpMenu.delegate = self
    reactionPopUpMenu.layer.shadowColor = K.colorTheme2.gray3.cgColor
    reactionPopUpMenu.layer.shadowRadius = 3
    reactionPopUpMenu.layer.shadowOpacity = 0.3
    reactionPopUpMenu.layer.shadowOffset = CGSize(width: 0, height: 3)
    reactionPopUpMenu.translatesAutoresizingMaskIntoConstraints = false
    return reactionPopUpMenu
  }()
  
  // The small 'bubbles' that is underneath the reactionPopUpMenu view
  private lazy var bubbeShapes: UIView = {
    let bubbleShapeView = UIView()
    let shape = CAShapeLayer()
    let bigBubblePathFrame = CGRect(x: 0, y: 0, width: 10, height: 10)
    let bigBubblePath = UIBezierPath(ovalIn: bigBubblePathFrame)
    let smalBubblePath = UIBezierPath(ovalIn: CGRect(x: bigBubblePathFrame.width / 2, y: bigBubblePathFrame.height * 1.2, width: 6, height: 6))
    bigBubblePath.append(smalBubblePath)
    shape.path = bigBubblePath.cgPath
    shape.fillColor = K.colorTheme2.gray1.cgColor
    bubbleShapeView.layer.insertSublayer(shape, at: 0)
    bubbleShapeView.translatesAutoresizingMaskIntoConstraints = false
    return bubbleShapeView
  }()
  
  @objc private func tapped(_ sender: UITapGestureRecognizer) {
    coordinator?.returnToPreviousView()
  }
  
  private func setSubviews(){
    view.addSubview(chatVCView)
    view.addSubview(darkendView)
    view.addSubview(reactionPopUpMenu)
    view.addSubview(bubbeShapes)
    view.addSubview(selectedMessageView)
  }
  
  private func setConstraints(){
    NSLayoutConstraint.activate([
      chatVCView.topAnchor.constraint(equalTo: view.topAnchor),
      chatVCView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      chatVCView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      chatVCView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      darkendView.topAnchor.constraint(equalTo: view.topAnchor),
      darkendView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      darkendView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      darkendView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      reactionPopUpMenu.widthAnchor.constraint(equalToConstant: K.Screen.width * 0.7),
      reactionPopUpMenu.heightAnchor.constraint(equalToConstant: 40),
      reactionPopUpMenu.bottomAnchor.constraint(equalTo: selectedMessageView.topAnchor, constant: -6),
      
      bubbeShapes.widthAnchor.constraint(equalToConstant: 10),
      bubbeShapes.heightAnchor.constraint(equalToConstant: 10),
      bubbeShapes.topAnchor.constraint(equalTo: reactionPopUpMenu.bottomAnchor, constant: -4),
    ])
    
    // Need to calculate width of 'selectedMessageView' to determine the position of 'reactionPopUpMenu'
    guard let isSender = isSender else {
      print("Sender of the message is not specified")
      return
    }
    
    let selectedCellWidth: Double = selectedMessageView.frame.width
    
    if selectedCellWidth > UIScreen.main.bounds.width * 0.6  {
      if isSender {
        reactionPopUpMenu.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
      } else {
        reactionPopUpMenu.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
      }
    } else {
      if isSender {
        reactionPopUpMenu.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
      } else {
        reactionPopUpMenu.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
      }
    }

    if isSender {
      bubbeShapes.trailingAnchor.constraint(equalTo: selectedMessageView.leadingAnchor, constant: -3).isActive = true
    } else {
      bubbeShapes.leadingAnchor.constraint(equalTo: selectedMessageView.trailingAnchor, constant: 3).isActive = true
    }
    
    // Update 'reactionPopUpMenu' to calcualte 'newAnchorPoint'
    view.layoutIfNeeded()
    // Create new AnchorPoint for animation starting position for ReactionPupMenu
    let x: CGFloat = bubbeShapes.frame.width * 0.5 + bubbeShapes.frame.origin.x
    let x_1: CGFloat = reactionPopUpMenu.frame.width + reactionPopUpMenu.frame.origin.x
    let difference: CGFloat = x - x_1
    var xRatio: CGFloat = difference / reactionPopUpMenu.frame.width
    
    if xRatio < 0 {
      xRatio = 1 - (xRatio * -1)
    }
    reactionPopUpMenu.newXCoordinate = xRatio
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .clear
    
    setSubviews()
    setConstraints()
  }
}


// MARK: - MessageReactionTransitionHelper for MessageReactionAnimator
extension MessageReactionViewController: MessageReactionTransitionHelper {
  var background: UIImageView { chatVCView }
  var darkenedViewRef: UIView { darkendView }
  var selectedCellViewRef: UIView { selectedMessageView }
  var reactionPopUpMenuRef: ReactionPopUpMenu { reactionPopUpMenu }
  var bubbleShapeRef: UIView { bubbeShapes }
}


// MARK: - ReactionPopUpMenuDelegate to hangle a tap event on 1 of the 6 reaction buttons
extension MessageReactionViewController: ReactionPopUpMenuDelegate {
  func reactionTapped(_ reactionType: ReactionPopUpMenu.ReactionType) {
    guard let selectedChatMessage = selectedChatMessage else { return }
    guard let selectedChatID = selectedChatID else { return }
    // Hides small bubble shapes
    UIView.animate(withDuration: 0.4, delay: 0) {
      self.bubbeShapes.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
      self.bubbeShapes.alpha = 0
    }
    
    // Here is where the ChatMessage gets updated
    let selectedChatMessageCopy = selectedChatMessage.copy() as! ChatMessage
    selectedChatMessageCopy.reactions.append(reactionType)
    self.coordinator?.returnToPreviousView()
    db?.updateChatMessageReaction(selectedChatID, selectedChatMessageCopy) { erorr in
      if let error = erorr {
        print("error in mesasge raection vc \(error.localizedDescription)")
        return
      }
    }
  }
}

protocol MessageReactionTransitionHelper {
  var background: UIImageView { get }
  var darkenedViewRef: UIView { get }
  var selectedCellViewRef: UIView { get }
  var reactionPopUpMenuRef: ReactionPopUpMenu { get }
  var bubbleShapeRef: UIView { get }
}
