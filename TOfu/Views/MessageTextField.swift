import UIKit

class MessageTextField: UITextField {
  
  var isButtonEnabled: Bool = false {
    didSet {
      sendButton.isUserInteractionEnabled = isButtonEnabled
  
      UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: [.curveEaseInOut]) {
        self.sendButton.tintColor = self.isButtonEnabled ? K.colorTheme2.blue : K.colorTheme2.gray3.withAlphaComponent(0.5)
      }

    }
  }
  
  private lazy var sendButton: UIButton = {
    let sendButton = UIButton(type: .system) // Send button inside textfield
    sendButton.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
    sendButton.tintColor = K.colorTheme.blue
    sendButton.isUserInteractionEnabled = false
    
    sendButton.translatesAutoresizingMaskIntoConstraints = false
    sendButton.imageView!.translatesAutoresizingMaskIntoConstraints = false
    
    sendButton.imageView?.contentMode = .scaleAspectFit
    sendButton.imageView!.widthAnchor.constraint(equalToConstant: 33).isActive = true
    sendButton.imageView!.heightAnchor.constraint(equalToConstant: 33).isActive = true
    
    sendButton.widthAnchor.constraint( equalToConstant: K.textFieldHeight).isActive = true
    return sendButton
  }()
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.autocorrectionType = .no
    self.layer.cornerRadius = K.textFieldHeight / 2
    self.setPadding(K.textFieldHeight / 2)
    self.layer.borderColor = K.colorTheme.beigeL.cgColor
    self.layer.borderWidth = 1
    self.rightView = sendButton
    self.rightViewMode = .always
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
}
