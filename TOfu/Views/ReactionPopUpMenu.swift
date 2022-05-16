import UIKit

protocol ReactionPopUpMenuDelegate: AnyObject {
  func reactionTapped(_: ReactionPopUpMenu.ReactionType)
}

protocol ReactionIconDelegate {
  var reactionButtonsRef: [UIButton] { get }
  var reactionButtonFrame: CGRect? { get }
  var hStackRef: UIStackView { get }
}

class ReactionPopUpMenu: UIView {
  enum ReactionType: String, Codable, CaseIterable {
    case heart       = "❤️"
    case thumbsUp    = "👍"
    case thumbsDown  = "👎"
    case lol         = "😂"
    case exclamation = "‼️"
    case question    = "❓"
    
    init(_ reactionName: String) {
      switch reactionName {
        case "❤️": self = .heart
        case "👍": self = .thumbsUp
        case "👎": self = .thumbsDown
        case "😂": self = .lol
        case "‼️": self = .exclamation
        case "❓": self = .question
        default:   self = .heart
      }
    }
  }
  
  weak var delegate: ReactionPopUpMenuDelegate?
  var originalPathRect: CGRect!
  var originalBounds: CGRect!
  var shape: CAShapeLayer = CAShapeLayer()
  var newXCoordinate: CGFloat?
  var tappedReaction: UIButton?
  
  private lazy var reactionButtons: [UIButton] = {
    var reactionButtons: [UIButton] = []
    
    for reaction in ReactionType.allCases {
      var config = UIButton.Configuration.filled()
      config.attributedTitle = AttributedString(reaction.rawValue, attributes: AttributeContainer([.font: UIFont.systemFont(ofSize: 15)]))
      config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0) // There is a default value, so override is needed
      config.baseBackgroundColor = .clear
      
      let button = UIButton(configuration: config)
      button.addTarget(self, action: #selector(reactionTapped(_:)), for: .touchUpInside)
      button.layer.cornerRadius = 15
      button.clipsToBounds = true
      button.alpha = 0
      button.transform = CGAffineTransform(scaleX: 0.2, y: 0.2).translatedBy(
        x: Double.random(in: -100...100),
        y: Double.random(in: -100...100))
      reactionButtons.append(button)
    }
    return reactionButtons
  }()
  
  private lazy var hStack: UIStackView = {
    let hStack = UIStackView()
    hStack.axis = .horizontal
    hStack.distribution = .equalSpacing
    hStack.alignment = .center
    hStack.spacing = 5
    reactionButtons.forEach(hStack.addArrangedSubview)
    hStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
    hStack.isLayoutMarginsRelativeArrangement = true
    return hStack
  }()
  
  @objc
  private func reactionTapped(_ sender: UIButton) {
    tappedReaction = sender
    
    reactionButtons.forEach{ $0.isUserInteractionEnabled = false }
    sender.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
    self.delegate?.reactionTapped(.init(sender.titleLabel!.text!))

    // Tapped reactionButton pops out effect
    UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.0, options: [.curveEaseInOut]) {
      sender.transform = .identity
      sender.backgroundColor = K.colorTheme2.blue
      self.reactionButtons.forEach { button in
        if button !== sender {
          button.alpha = 0
        }
      }
    }
    
    self.beginCompressAnimation()
  }
  
  override func draw(_ rect: CGRect) {
    originalBounds = bounds
    hStack.frame = bounds
    
    originalPathRect = CGRect(
      x: newXCoordinate! * bounds.width - (bounds.height * 0.2) / 2,
      y: bounds.height * 0.5 - (bounds.height * 0.2) / 2,
      width: bounds.height * 0.2,
      height: bounds.height * 0.2)
    
    let shapePath = UIBezierPath(roundedRect: originalPathRect!, cornerRadius: bounds.height * 0.5).cgPath
    shape.path = shapePath
    shape.strokeColor = K.colorTheme2.gray3.withAlphaComponent(0.2).cgColor
    shape.lineWidth = 1
    shape.fillColor = K.colorTheme2.gray1.cgColor
    hStack.layer.insertSublayer(shape, at: 0)
    hStack.layer.cornerRadius = bounds.height * 0.5
  }
  
  func beginExpandAnimation() {
    let newPath = UIBezierPath(
      roundedRect: CGRect(
        x: newXCoordinate! * originalBounds!.width - (originalBounds!.height * 0.5) / 2,
        y: 0,
        width: originalBounds!.height,
        height: originalBounds!.height), cornerRadius: originalBounds!.height * 0.5)

    CATransaction.begin()
    CATransaction.setCompletionBlock {
      self.beginAppearanceAnimation()
    }
      let newPathAnimation = CASpringAnimation(keyPath: "path")
      newPathAnimation.damping = 0.3
      newPathAnimation.initialVelocity = 0.9
      newPathAnimation.mass = 0.3
      newPathAnimation.stiffness = 12
      newPathAnimation.fromValue = shape.path
      newPathAnimation.toValue   = newPath.cgPath
      newPathAnimation.duration = 0.2
      shape.add(newPathAnimation, forKey: "path")
      shape.path = newPath.cgPath
    CATransaction.commit()
    
  }
  
  func beginCompressAnimation() {
    let newFrame = CGRect(origin: CGPoint(x: originalPathRect.origin.x - originalPathRect.width * 0.5, y: originalPathRect.origin.y + 1.5 * originalPathRect.height),
                          size: originalPathRect.size)
    var compressPath: UIBezierPath? = nil
    if let tappedReaction = tappedReaction {
      compressPath = UIBezierPath(
        roundedRect: CGRect(origin: CGPoint(x: tappedReaction.frame.origin.x - 5, y: 0), size: CGSize(width: tappedReaction.frame.width + 10, height: tappedReaction.frame.height + 10)),
        cornerRadius: tappedReaction.frame.height / 2)
    }
    
    // If no reaction is tapped
    if compressPath == nil {
      self.reactionButtons.forEach{ $0.alpha = 0 }
    }
    
    CATransaction.begin()
      let compressAnimation = CASpringAnimation(keyPath: "path")
      // Spring effect setup
      compressAnimation.damping = 0.5
      compressAnimation.initialVelocity = 0.9
      compressAnimation.mass = 0.1
      compressAnimation.stiffness = 12
      // Animation values and duration
      compressAnimation.fromValue = shape.path
      compressAnimation.toValue   = compressPath?.cgPath ?? UIBezierPath(roundedRect: newFrame, cornerRadius: originalPathRect.height * 0.5).cgPath
      compressAnimation.duration  = 0.4
      shape.add(compressAnimation, forKey: "path")
      shape.path = compressAnimation.toValue as! CGPath
    CATransaction.commit()
  }
  
  // Each reaction button onAppear animation
  private func beginAppearanceAnimation() {
    let newPath = UIBezierPath(roundedRect: originalBounds!, cornerRadius: originalBounds!.height * 0.5).cgPath

    CATransaction.begin()
    CATransaction.setCompletionBlock {
      for (index, button) in self.reactionButtons.enumerated() {
        UIView.animate(withDuration: 0.4, delay: 0.05 * Double(index), usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: [.curveEaseInOut]) {
          button.alpha = 1
          button.transform = .identity
        }
      }
    }
      let newPathAnimation = CASpringAnimation(keyPath: "path")
      newPathAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
      newPathAnimation.damping = 0.8
      newPathAnimation.initialVelocity = 1
      newPathAnimation.mass = 0.4
      newPathAnimation.stiffness = 20
    
      newPathAnimation.fromValue = shape.path
      newPathAnimation.toValue   = newPath
      newPathAnimation.duration = 0.2
      shape.path = newPath
      shape.add(newPathAnimation, forKey: "path")
    CATransaction.commit()
  }
  
  private func setSubviews(){
    addSubview(hStack)
  }
  
  private func setConstraints(){
    reactionButtons.forEach{
      NSLayoutConstraint.activate([
        $0.widthAnchor.constraint(equalToConstant: 30),
        $0.heightAnchor.constraint(equalToConstant: 30)
      ])
    }
  }
  
  init(frame: CGRect = .zero, tailFrame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = .clear
    setSubviews()
    setConstraints()
  }
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}


extension ReactionPopUpMenu: ReactionIconDelegate {
  var reactionButtonsRef: [UIButton] { reactionButtons }
  var reactionButtonFrame: CGRect? {
    guard let tappedReaction = tappedReaction else {
      return nil
    }
    return hStack.convert(tappedReaction.frame, to: nil)
  }
  var hStackRef: UIStackView { hStack }
}
