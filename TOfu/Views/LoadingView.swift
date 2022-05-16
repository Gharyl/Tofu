import UIKit

class LoadingView: UIView {
  private let height: CGFloat
  private let width:  CGFloat
  private let duration: CGFloat = 1
  private let strokeWidth: CGFloat
  private let strokeColor: UIColor
//  var loadingCirclePath: UIBezierPath
  
  enum Direction {
    case clockwise
    case counterClockwise
  }
  var direction: Direction!
  
  lazy var loadingCircle: CAShapeLayer  = {
    let path: UIBezierPath
    let shape = CAShapeLayer()
    path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: width, height: height))
    shape.path = path.cgPath
    shape.strokeColor = strokeColor.cgColor
    shape.fillColor = UIColor.clear.cgColor
    shape.strokeEnd = 0.7
    shape.lineWidth = strokeWidth
    shape.lineCap = .round
    return shape
  }()
  
  func beginAnimation(direction: Direction = .clockwise) {
    self.direction = direction
    
    let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
    rotationAnimation.fromValue = 0
    rotationAnimation.toValue   = direction == .clockwise ? Double.pi * 2 : Double.pi * -2
    rotationAnimation.duration  = duration
    rotationAnimation.repeatCount = .infinity
    layer.add(rotationAnimation, forKey: rotationAnimation.keyPath)
  }
  
  func endAnimation(newFrame: CGRect? = nil) {
    layer.removeAllAnimations()
    loadingCircle.strokeEnd = 1

    guard let newFrame = newFrame else { return }
    let newPath = UIBezierPath(ovalIn: CGRect(origin: CGPoint(x: newFrame.width / -4, y: newFrame.height / -4), size: newFrame.size)).cgPath
    CATransaction.begin()
    let frameAnimation = CABasicAnimation(keyPath: "path")
    frameAnimation.fromValue = loadingCircle.path
    frameAnimation.toValue   = newPath
    frameAnimation.duration = 0.2
    loadingCircle.path = newPath
    loadingCircle.add(frameAnimation, forKey: "path")
    CATransaction.commit()
  }
  
  func removeAnimation() {
    layer.removeAllAnimations()
    loadingCircle.removeAllAnimations()
  }
  
  init(frame: CGRect, strokeWidth: CGFloat = 1, strokeColor: UIColor = K.colorTheme2.gray2) {
    self.height = frame.height
    self.width  = frame.width
    self.strokeWidth = strokeWidth
    self.strokeColor = strokeColor
    super.init(frame: frame)
    
    layer.insertSublayer(loadingCircle, at: 0)
  }
  required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
}
