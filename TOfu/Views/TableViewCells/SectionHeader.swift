import UIKit

class SectionHeader: UIView {
  private lazy var sectionTitle: UILabel = {
    let sectionTitle = UILabel()
    sectionTitle.translatesAutoresizingMaskIntoConstraints = false
    return sectionTitle
  }()
  
  private func setSubviews() {
    addSubview(sectionTitle)
  }
  
  private func setConstraints() {
    NSLayoutConstraint.activate([
      sectionTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
//      sectionTitle.topAnchor.constraint(equalTo: topAnchor),
//      sectionTitle.bottomAnchor.constraint(equalTo: bottomAnchor),
      sectionTitle.widthAnchor.constraint(equalToConstant: 20),
    ])
  }
  
  private func setLayer() {
    let gradient = CAGradientLayer()
    gradient.colors = K.sectionHeaderGradient
    gradient.locations = [0.0, 0.35, 1.0]
    gradient.startPoint = CGPoint(x: 0, y: 0.5)
    gradient.endPoint = CGPoint(x: 1, y: 0.5)
    gradient.frame = frame
    layer.sublayers?.insert(gradient, at: 0)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
  }
  
  init(frame: CGRect, title: String) {
    super.init(frame: frame)
    
    setSubviews()
    setConstraints()
    setLayer()
    sectionTitle.text = title
    sectionTitle.tintColor = .darkGray
  }
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
