import UIKit

class ContactCell: UITableViewCell {
  weak var addFriendDelegate: ContactCellAddFriendDelegate?
  weak var requestDelegate: ContactCellRequestDelegate?

  var contactID: String = ""
  var animatableAddButtonWidth: NSLayoutConstraint!
  var animatableAddButtonTrailingAnchor: NSLayoutConstraint!
  var animatableAcceptButtonWidth: NSLayoutConstraint!
  var animatableAcceptButtonTrailingAnchor: NSLayoutConstraint!
  var animatableRejectButtonWidth: NSLayoutConstraint!
  
  var isRequestSent: Bool = false
  
  // adds an action button on the right side of the cell
  var addButtonVisible: Bool = false {
    didSet {
      // UITableViewCell has a contentView covering its element
      // Adding interactive element to view instead of contentView will not work
      print("addbuttonvisible? \(addButtonVisible)")
      if addButtonVisible {
        contentView.addSubview(addContactButton)
        animatableAddButtonWidth = addContactButton.widthAnchor.constraint(equalToConstant: 50)
        animatableAddButtonTrailingAnchor = addContactButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        NSLayoutConstraint.activate([
          animatableAddButtonWidth,
          addContactButton.heightAnchor.constraint(equalToConstant: 20),
          animatableAddButtonTrailingAnchor,
          addContactButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
      } else {
        print("RESETING THE CELL")
        if oldValue != addButtonVisible {
          addContactButton.removeFromSuperview()
          loadingView.removeFromSuperview()
          checkmarkView.removeFromSuperview()
          
          contentView.layoutIfNeeded()
          
          animatableAddButtonWidth.constant = 50
          animatableAddButtonTrailingAnchor.constant = -20
          
          addContactButton.alpha = 1
          addContactButton.isUserInteractionEnabled = true
          addContactButton.transform = .identity
          addContactButton.setTitle("ADD", for: .normal)
          addContactButton.removeConstraints(addContactButton.constraints)
          
          checkmarkView.removeAnimation()
          
          loadingView.removeAnimation()
          loadingView.alpha = 1
          
          flashBackgroundView.frame = .zero
          flashBackgroundView.backgroundColor = K.colorTheme2.blue2
          flashBackgroundView.alpha = 0
        }
      }
    }
  }
  
  // adds two action buttons on the right side of the cell
  var isRequest: Bool = false {
    didSet {
      contentView.addSubview(acceptContactButton)
      contentView.addSubview(rejectContactButton)
      animatableAcceptButtonWidth = acceptContactButton.widthAnchor.constraint(equalToConstant: 40)
      animatableAcceptButtonTrailingAnchor = acceptContactButton.trailingAnchor.constraint(equalTo: rejectContactButton.leadingAnchor, constant: -10)
      animatableRejectButtonWidth = rejectContactButton.widthAnchor.constraint(equalToConstant: 40)
      
      NSLayoutConstraint.activate([
        rejectContactButton.heightAnchor.constraint(equalToConstant: 25),
        animatableAcceptButtonWidth,
        rejectContactButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
        rejectContactButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        
        acceptContactButton.heightAnchor.constraint(equalToConstant: 25),
        animatableRejectButtonWidth,
        animatableAcceptButtonTrailingAnchor,
        acceptContactButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
      ])
      
      username.font = UIFont.systemFont(ofSize: 14)
      profileName.font = UIFont.systemFont(ofSize: 14)
    }
  }
  
  private lazy var hStack: UIStackView = {
    let hStack = UIStackView()
    hStack.axis = .horizontal
    hStack.alignment = .center
    hStack.spacing = 10
    hStack.isLayoutMarginsRelativeArrangement = true
    hStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 20)
    hStack.translatesAutoresizingMaskIntoConstraints = false
    return hStack
  }()
  
  lazy var profileImage: UIImageView = {
    let profileImage = UIImageView()
    profileImage.contentMode = .scaleAspectFill
    profileImage.layer.cornerRadius = 20
    profileImage.image = UIImage(systemName: "person.crop.circle.fill")
    profileImage.tintColor = K.colorTheme.blue
    profileImage.translatesAutoresizingMaskIntoConstraints = false
    return profileImage
  }()
  
  private lazy var vStack: UIStackView = {
    let vStack = UIStackView()
    vStack.axis = .vertical
    vStack.alignment = .leading
    vStack.translatesAutoresizingMaskIntoConstraints = false
    return vStack
  }()
  
  lazy var profileName: UILabel = {
    let profileName = UILabel()
    profileName.font = UIFont(name: "Arial", size: 17)
    profileName.tintColor = .purple
    profileName.translatesAutoresizingMaskIntoConstraints = false
    return profileName
  }()
  
  lazy var username: UILabel = {
    let username = UILabel()
    username.font = UIFont(name: "Arial", size: 17)
    username.tintColor = .purple
    username.translatesAutoresizingMaskIntoConstraints = false
    return username
  }()
  
  private lazy var addContactButton: UIButton = {
    let addContactButton = UIButton.makeContactAction(title: "ADD")
    addContactButton.addTarget(self, action: #selector(addButtonTapped(_:)), for: .touchUpInside)
    addContactButton.translatesAutoresizingMaskIntoConstraints = false
    return addContactButton
  }()
  
  private lazy var acceptContactButton: UIButton = {
    let imageConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: UIImage.SymbolWeight.heavy)
    let acceptContactButton = UIButton.makeContactAction(image: UIImage(systemName: "checkmark", withConfiguration: imageConfig), useConfig: true)
    acceptContactButton.layer.cornerRadius = 25/2
    acceptContactButton.addTarget(self, action: #selector(acceptButtonTapped(_:)), for: .touchUpInside)
    acceptContactButton.translatesAutoresizingMaskIntoConstraints = false
  return acceptContactButton
}()
  
  private lazy var rejectContactButton: UIButton = {
    let imageConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: UIImage.SymbolWeight.heavy)
    let rejectContactButton = UIButton.makeContactAction(image: UIImage(systemName: "xmark", withConfiguration: imageConfig))
    rejectContactButton.imageView?.tintColor = K.colorTheme2.blue2
    rejectContactButton.layer.borderColor = rejectContactButton.backgroundColor!.cgColor
    rejectContactButton.layer.borderWidth = 1
    rejectContactButton.layer.cornerRadius = 25/2
    rejectContactButton.backgroundColor = .clear
    rejectContactButton.addTarget(self, action: #selector(rejectButtonTapped(_:)), for: .touchUpInside)
    rejectContactButton.translatesAutoresizingMaskIntoConstraints = false
    return rejectContactButton
  }()
  
  private lazy var loadingView: LoadingView = {
    let loadingView = LoadingView(frame: CGRect(x: 0, y: 0, width: 12, height: 12), strokeWidth: 2)
    loadingView.translatesAutoresizingMaskIntoConstraints = false
    return loadingView
  }()
  
  private lazy var checkmarkView: CheckmarkView = {
    let checkmarkView = CheckmarkView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    checkmarkView.strokColor = K.colorTheme2.blue2
    checkmarkView.translatesAutoresizingMaskIntoConstraints = false
    return checkmarkView
  }()
  
  private lazy var flashBackgroundView: UIView = {
    let flashBackgroundView = UIView()
    flashBackgroundView.backgroundColor = K.colorTheme2.blue2
    flashBackgroundView.alpha = 0
    return flashBackgroundView
  }()
  
  @objc
  private func addButtonTapped(_ sender: UIButton) {
    beginLoadingAnimation() // Animation
    addContactButton.isUserInteractionEnabled = false
    addFriendDelegate?.addNewFriend(self) { error in
      if let error = error {
        print(error.localizedDescription)
      } else {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
          self.endingAnimation ()
        }
      }
    }
  }
  
  @objc
  private func rejectButtonTapped(_ sender: UIButton) {
    requestActionAnimation(isAccept: false)
    //TODO: - reject
  }
  
  @objc
  private func acceptButtonTapped(_ sender: UIButton) {
    requestActionAnimation(isAccept: true)
    //TODO: - accept
  }
  
  override func prepareForReuse() {
    print("PREPARING FOR REUSE BRUH")
    addButtonVisible = false
    isRequestSent = false
  }
  
  private func beginLoadingAnimation() {
    contentView.addSubview(loadingView)
    loadingView.alpha = 0
    loadingView.center = addContactButton.center
    addContactButton.setTitle("", for: .normal)
    UIView.animate(withDuration: 0.05, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveEaseIn]) {
      self.addContactButton.transform = CGAffineTransform(scaleX: 1.1, y: 1)
    } completion: { finished in
      UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.3, options: [.curveEaseOut]) {
        self.loadingView.alpha = 1
        self.animatableAddButtonWidth.constant = 20
        self.animatableAddButtonTrailingAnchor.constant = -35
        self.contentView.layoutIfNeeded()
      }
      self.loadingView.beginAnimation(direction: .counterClockwise)
    }
  }
  
  private func requestActionAnimation(isAccept: Bool) {
    UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: [.curveEaseIn]) {
      if isAccept {
        self.animatableAcceptButtonWidth.constant = 90
        self.rejectContactButton.isHidden = true
        self.animatableAcceptButtonTrailingAnchor.constant = 0
        self.animatableRejectButtonWidth.constant = 0
        self.contentView.layoutIfNeeded()
      } else {
        self.animatableRejectButtonWidth.constant = 90
        self.acceptContactButton.isHidden = true
        self.animatableAcceptButtonWidth.constant = 0
        self.contentView.layoutIfNeeded()
      }
    } completion: { [weak self] _ in
      guard let self = self else { return }
      self.requestDelegate?.requestResponded(response: isAccept, cell: self)
    }
  }
  
  private func endingAnimation() {
    checkmarkView.center = loadingView.center
    contentView.addSubview(checkmarkView)
    checkmarkView.beginAnimation()
    loadingView.endAnimation()
    
    // Background flash effect
    flashBackgroundView.frame = addContactButton.frame
    flashBackgroundView.layer.cornerRadius = addContactButton.layer.cornerRadius
    flashBackgroundView.alpha = 1
    
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3, options: [.curveLinear]) {
      self.flashBackgroundView.frame = CGRect(origin: .zero, size: self.frame.size) // the 'origin' for each cell has a weird origin offset, must be set to (0,0) manually
      self.flashBackgroundView.layer.cornerRadius = 0
      self.flashBackgroundView.backgroundColor = K.colorTheme2.blue2.withAlphaComponent(0.5)
    } completion: { finished in
      UIView.animate(withDuration: 0.3) {
        self.flashBackgroundView.backgroundColor = .clear
      }
    }
    
    UIView.animate(withDuration: 0.5, delay: 0,usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveEaseIn]) {
      self.loadingView.alpha = 0
      self.addContactButton.alpha = 0
      self.layoutIfNeeded()
    }
  }
  
  func checkRequestStatus() {
    print("Check request status: \(isRequestSent)")
    if isRequestSent {
      layoutIfNeeded()
      addContactButton.alpha = 0
      contentView.addSubview(checkmarkView)
      checkmarkView.center = addContactButton.center
      checkmarkView.beginAnimation(skipAnimation: true)
    }
  }
  
  private func setSubviews() {
    vStack.addArrangedSubview(username)
    vStack.addArrangedSubview(profileName)
    hStack.addArrangedSubview(profileImage)
    hStack.addArrangedSubview(vStack)
    addSubview(flashBackgroundView)
    addSubview(hStack)
  }
  
  private func setConstraints() {
    NSLayoutConstraint.activate([
      profileImage.widthAnchor.constraint(equalToConstant: 40),
      profileImage.heightAnchor.constraint(equalToConstant: 40),
      hStack.topAnchor.constraint(equalTo: topAnchor),
      hStack.bottomAnchor.constraint(equalTo: bottomAnchor),
      hStack.leadingAnchor.constraint(equalTo: leadingAnchor),
      hStack.trailingAnchor.constraint(equalTo: trailingAnchor)
    ])
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setSubviews()
    setConstraints()
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}


extension UIButton {
  static func makeContactAction(title: String = "", image: UIImage? = nil, useConfig: Bool = false) -> UIButton {
    let contactActionButton = UIButton()
    if useConfig {
      var config = UIButton.Configuration.filled()
      config.image = image
      config.cornerStyle = .capsule
      config.baseBackgroundColor = K.colorTheme2.blue2
      return UIButton(configuration: config)
    } else {
      if let image = image {
        contactActionButton.setImage(image, for: .normal)
      } else {
        contactActionButton.setTitle(title, for: .normal)
      }
      contactActionButton.setTitleColor(.white, for: .normal)
      contactActionButton.backgroundColor = K.colorTheme2.blue2
      contactActionButton.layer.cornerRadius = 10
      contactActionButton.clipsToBounds = true
      contactActionButton.titleLabel?.font = UIFont(name: K.themeFont, size: 15)
      contactActionButton.isUserInteractionEnabled = true
      return contactActionButton
    }
  }
}
