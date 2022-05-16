import UIKit

class CustomButton: UIView {
  var title: String {
    didSet {
      updateTitle()
    }
  }
  
  private lazy var titleLabel: UILabel = {
    let titleLabel = UILabel()
    titleLabel.text = title
    titleLabel.textColor = K.colorTheme2.gray1
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    return titleLabel
  }()
  
  private func setup() {
    addSubview(titleLabel)
    NSLayoutConstraint.activate([
      titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
      titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
    ])
    clipsToBounds = true
  }
  
  private func updateTitle() {
    titleLabel.text = title
  }
  
  init(frame: CGRect, title: String) {
    self.title = title
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
