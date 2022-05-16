import UIKit

class MessageTextView: UIView {
  lazy var messageText: UILabel = {
    let messageText = UILabel()
    messageText.numberOfLines = 20
    messageText.textAlignment = .left
    messageText.layer.masksToBounds = true
    messageText.font = .systemFont(ofSize: 16)
    messageText.translatesAutoresizingMaskIntoConstraints = false
    
//    messageText.layer.borderWidth = 1
//    messageText.layer.borderColor = UIColor.red.cgColor
    return messageText
  }()
  
  private func setSubviews() {
    addSubview(messageText)
  }
  
  private func setConstraint() {
    NSLayoutConstraint.activate([
      messageText.topAnchor.constraint(equalTo: topAnchor, constant: 8),
      messageText.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
      messageText.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
      messageText.centerXAnchor.constraint(equalTo: centerXAnchor),
    ])
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setSubviews()
    setConstraint()
  }
  
  required init?(coder: NSCoder) { super.init(coder: coder) }
}
