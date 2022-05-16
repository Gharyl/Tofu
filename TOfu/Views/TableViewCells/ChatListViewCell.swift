import UIKit

class ChatListViewCell: UITableViewCell {
  lazy var hStack: UIStackView = {
    let hStack = UIStackView()
    hStack.axis = .horizontal
    hStack.distribution = .equalSpacing
    hStack.spacing = 12
    hStack.alignment = .center
    hStack.translatesAutoresizingMaskIntoConstraints = false
    return hStack
  }()
  
  lazy var hStack2: UIStackView = {
    let hStack = UIStackView()
    hStack.axis = .horizontal
    hStack.distribution = .equalSpacing
    hStack.spacing = 3
    hStack.alignment = .center
    hStack.translatesAutoresizingMaskIntoConstraints = false
    return hStack
  }()
  
  lazy var vStack: UIStackView = {
    let vStack = UIStackView()
    vStack.axis = .vertical
    vStack.distribution = .equalSpacing
//    vStack.spacing = 5
    vStack.alignment = .leading
//    vStack.layer.borderColor = UIColor.red.cgColor
//    vStack.layer.borderWidth = 1
    vStack.translatesAutoresizingMaskIntoConstraints = false
    return vStack
  }()
  
  lazy var chatImage: UIImageView = {
    let chatImage = UIImageView()
    chatImage.layer.cornerRadius = 30
    chatImage.clipsToBounds = true
    chatImage.contentMode = .scaleAspectFill
    chatImage.tintColor = K.colorTheme.beige
    chatImage.translatesAutoresizingMaskIntoConstraints = false
    return chatImage
  }()
  
  lazy var participants: UILabel = {
    let participants = UILabel()
    participants.font = UIFont(name: K.themeFont, size: 16)
//    participants.layer.borderColor = UIColor.black.cgColor
//    participants.layer.borderWidth = 1
    participants.translatesAutoresizingMaskIntoConstraints = false
    return participants
  }()
  
  lazy var previewMessage: UILabel = {
    let previewMessage = UILabel()
    previewMessage.font = UIFont(name: K.themeFont, size: 14)
    previewMessage.textColor = UIColor.gray
    previewMessage.numberOfLines = 2
//    previewMessage.layer.borderColor = UIColor.black.cgColor
//    previewMessage.layer.borderWidth = 1
    previewMessage.translatesAutoresizingMaskIntoConstraints = false
    return previewMessage
  }()
  
  lazy var lastActivity: UILabel = {
    let lastActivity = UILabel()
    lastActivity.textColor = .gray
    lastActivity.font = UIFont(name: K.themeFont, size: 14)
    lastActivity.translatesAutoresizingMaskIntoConstraints = false
    return lastActivity
  }()
  
  lazy var chevron: UIImageView = {
    let chevron = UIImageView()
    chevron.image = UIImage(systemName: "chevron.forward")
    chevron.tintColor = .gray
    chevron.contentMode = .scaleAspectFit
    chevron.translatesAutoresizingMaskIntoConstraints = false
    return chevron
  }()
  
  
  func setConstraints() {
    NSLayoutConstraint.activate([
      hStack.heightAnchor.constraint(equalToConstant: 70),
      hStack.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.95),
      hStack.centerXAnchor.constraint(equalTo: centerXAnchor),
      hStack.centerYAnchor.constraint(equalTo: centerYAnchor),
      
      chatImage.heightAnchor.constraint(equalToConstant: 60),
      chatImage.widthAnchor.constraint(equalToConstant: 60),
      
      vStack.heightAnchor.constraint(equalToConstant: 70),
      vStack.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.95 - chatImage.bounds.width),
      
      hStack2.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.95),
      hStack2.heightAnchor.constraint(equalToConstant: 20),
      
      previewMessage.topAnchor.constraint(equalTo: participants.bottomAnchor),
      lastActivity.rightAnchor.constraint(equalTo: chevron.leftAnchor),
      chevron.widthAnchor.constraint(equalToConstant: 12),
      chevron.heightAnchor.constraint(equalToConstant: 12),
    ])
  }
  
  func setSubviews() {
    hStack2.addArrangedSubview(participants)
    hStack2.addArrangedSubview(lastActivity)
    hStack2.addArrangedSubview(chevron)
    
    vStack.addArrangedSubview(hStack2)
    vStack.addArrangedSubview(previewMessage)
    
    hStack.addArrangedSubview(chatImage)
    hStack.addArrangedSubview(vStack)
    
    addSubview(hStack)
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setSubviews()
    setConstraints()
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
