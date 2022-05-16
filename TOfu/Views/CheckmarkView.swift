import UIKit

class CheckmarkView: UIView {
  let width: CGFloat
  let height: CGFloat
  var strokColor: UIColor! {
    didSet {
      checkmarkShape.strokeColor = strokColor.cgColor
    }
  }
  
  private lazy var checkmarkShape: CAShapeLayer = {
    let checkmarkShape = CAShapeLayer()
    checkmarkShape.path = getPath().cgPath
    checkmarkShape.fillColor = UIColor.clear.cgColor
    checkmarkShape.lineCap = .round
    checkmarkShape.strokeEnd = 0
    checkmarkShape.lineWidth = 3
    checkmarkShape.strokeColor = K.colorTheme2.gray2.cgColor
    return checkmarkShape
  }()
  
  private func getPath(newFrame: CGRect? = nil) -> UIBezierPath {
    let path = UIBezierPath()
    let width:  CGFloat
    let height: CGFloat
    if let newFrame = newFrame {
      width  = newFrame.width
      height = newFrame.height
    } else {
      width  = self.width
      height = self.height
    }
    path.move(to: CGPoint(x: width * 0.25 , y: height * 0.5))
    path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.7))
    path.addLine(to: CGPoint(x: width * 0.75, y: height * 0.3))
    return path
  }
  
  func beginAnimation(skipAnimation: Bool = false) {
    isHidden = false
    if !skipAnimation {
      CATransaction.begin()
        let strokeAnimation = CASpringAnimation(keyPath: "strokeEnd")
        strokeAnimation.stiffness = 54
        strokeAnimation.damping = 3.7
        strokeAnimation.mass = 1
        strokeAnimation.initialVelocity = 0
        strokeAnimation.duration  = 0.3
        strokeAnimation.fromValue = 0
        strokeAnimation.toValue   = 1
        checkmarkShape.add(strokeAnimation, forKey: strokeAnimation.keyPath)
        checkmarkShape.strokeEnd  = 1
      CATransaction.commit()
    } else {
      checkmarkShape.strokeEnd  = 1
    }
  }
  
  func removeAnimation() {
    checkmarkShape.removeAllAnimations()
  }
  
  override init(frame: CGRect) {
    self.width = frame.width
    self.height = frame.height
    super.init(frame: frame)
    isHidden = true
    layer.insertSublayer(checkmarkShape, at: 0)
  }
  
  required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
}
