import UIKit

class BubbleBackground {
  let bubbleAmount: Int = 20
  var shift:  Double  = 10
  var gradientFrame: CGRect?
  var gradientColors = [
    K.colorTheme2.purple.withAlphaComponent(0.5).cgColor,
    K.colorTheme2.beige.withAlphaComponent(0.5).cgColor,
    K.colorTheme2.blue.withAlphaComponent(0.5).cgColor,
    K.colorTheme2.hotpink.withAlphaComponent(0.3).cgColor,
    K.colorTheme2.purple.withAlphaComponent(0.5).cgColor,
  ]
  
  var bubbles: [CAShapeLayer] { bubbleGroup1 + bubbleGroup2 + bubbleGroup3 + bubbleGroup4 }
  
  private lazy var bubbleGroup1: [CAShapeLayer] = {
    var bubbleGroup1: [CAShapeLayer] = []
    for num in 0...bubbleAmount {
      let bubble = CAShapeLayer()
      bubble.path = getCirclepath().cgPath
      bubble.fillColor = K.colorTheme2.beige.withAlphaComponent(CGFloat.random(in: 0.2...0.8)).cgColor
      bubbleGroup1.append(bubble)
    }
    return bubbleGroup1
  }()
  
  private lazy var bubbleGroup2: [CAShapeLayer] = {
    var bubbleGroup2: [CAShapeLayer] = []
    for num in 0...bubbleAmount {
      let bubble = CAShapeLayer()
      bubble.path = getCirclepath().cgPath
      bubble.fillColor = K.colorTheme2.blue.withAlphaComponent(CGFloat.random(in: 0.2...0.8)).cgColor
      bubbleGroup2.append(bubble)
    }
    return bubbleGroup2
  }()
  
  private lazy var bubbleGroup3: [CAShapeLayer] = {
    var bubbleGroup3: [CAShapeLayer] = []
    for num in 0...bubbleAmount {
      let bubble = CAShapeLayer()
      bubble.path = getCirclepath().cgPath
      bubble.fillColor = K.colorTheme2.hotpink.withAlphaComponent(CGFloat.random(in: 0.2...0.8)).cgColor
      bubbleGroup3.append(bubble)
    }
    return bubbleGroup3
  }()
  
  private lazy var bubbleGroup4: [CAShapeLayer] = {
    var bubbleGroup4: [CAShapeLayer] = []
    for num in 0...bubbleAmount {
      let bubble = CAShapeLayer()
      bubble.path = getCirclepath().cgPath
      bubble.fillColor = K.colorTheme2.purple.withAlphaComponent(CGFloat.random(in: 0.2...0.8)).cgColor
      bubbleGroup3.append(bubble)
    }
    return bubbleGroup4
  }()
  
  lazy private(set) var gradientBackground: CAGradientLayer = {
    guard let gradientFrame = gradientFrame else { return CAGradientLayer() }

    let gradient = CAGradientLayer()
//    gradient.type = .conic
    
    gradient.colors = gradientColors
    gradient.locations = [0,0.25,0.5,0.75]
    gradient.startPoint = CGPoint(x: 0, y: 0)
    gradient.endPoint   = CGPoint(x: 1, y: 1)
    gradient.frame = CGRect(
      origin: CGPoint(x: 0 , y: 0),
      size:   CGSize(width: gradientFrame.width * 2, height: gradientFrame.height))

    return gradient
  }()
  
  private func getCirclepath() -> UIBezierPath {
    let randomRadius = CGFloat.random(in: 20...150)
    let path = UIBezierPath(ovalIn: CGRect(x: -randomRadius, y: -randomRadius, width: randomRadius, height: randomRadius))
    return path
  }
  
  private func wavePath(
    amplitude: Int,
    frequency: Int,
    startingPoint: CGPoint,
    rotation: CGFloat = 0
  ) -> UIBezierPath {
    
    let path = UIBezierPath()
    path.move(to: startingPoint)
    
    let randomFrequency = Double(Int.random(in: frequency...(frequency*2)))
    let randomAmplitude = Double(Int.random(in: amplitude...(amplitude*2)))
    
    for x in stride(from: K.Screen.height * 1.2, to: 0 - (K.Screen.height * 0.2), by: -1) {
      let y = randomAmplitude * sin(x / randomFrequency)
      path.addLine(to: CGPoint(x: y + startingPoint.x, y: x))
    }
    
    // Rotating by some degree
    var transform = CGAffineTransform.identity
    transform = transform.translatedBy(x: startingPoint.x, y: startingPoint.y)
    transform = transform.rotated(by: rotation * .pi / 180)
    transform = transform.translatedBy(x: -startingPoint.x, y: -startingPoint.y)
    path.apply(transform)
    
    return path
  }
  
  func beginAnimation() {
    guard let gradientFrame = gradientFrame else { return }

    let startingX = gradientFrame.origin.x
    
    for bubble in bubbles {
      let bubbleAnimation = CAKeyframeAnimation(keyPath: "position")
      bubbleAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
      bubbleAnimation.path = wavePath(
        amplitude: 20,
        frequency: 40,
        startingPoint: CGPoint(x: CGFloat.random(in:  startingX...(gradientFrame.width * 3)), y: K.Screen.height * 1.2),
        rotation: CGFloat.random(in: -20...20)
      ).cgPath
      
      let fadeAnimation = CAKeyframeAnimation(keyPath: "opacity")
      fadeAnimation.keyTimes  = [0, 0.6, 1]
      fadeAnimation.values    = [1, 0.3, 0]
      
      let animationGroup = CAAnimationGroup()
      animationGroup.animations = [bubbleAnimation, fadeAnimation]
      animationGroup.duration = Double.random(in: 10...40)
      animationGroup.beginTime = CACurrentMediaTime() + Double.random(in: -3...0)
      animationGroup.repeatCount = Float.infinity
      animationGroup.timeOffset = animationGroup.duration * Double.random(in: -0.5...0.5)
      
      bubble.add(animationGroup, forKey: nil)
    }
  }
  
  func pauseAnimation() {
    bubbles.forEach {
      $0.pause()
      $0.removeAllAnimations()
    }
  }
}

extension CALayer {
  func pause() {
    let pauseTime = self.convertTime(CACurrentMediaTime(), from: nil)
    speed = 0.0
    timeOffset = pauseTime
  }
}
