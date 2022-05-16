import UIKit

class AnimatedBackgroundShape {
  final class TripleCircleShapes {
    var parent: AnimatedBackgroundShape?
    var color: UIColor
    private var currentCenters: [CGPoint]
    private var currentRadius:  [CGFloat]
    private var currentPaths:   CGPath = .init(rect: .zero, transform: nil)
    
    var shapeLayer: CAShapeLayer = CAShapeLayer()
    
    var radius: [CGFloat] {
      get { return currentRadius }
      set { currentRadius = newValue }
    }
    var centers: [CGPoint] {
      get { return currentCenters }
      set { currentCenters = newValue }
    }
    var paths: CGPath {
      get { return currentPaths }
      set { currentPaths = newValue }
    }
    
    func setup() {
      let newPath = UIBezierPath()
      let circlePaths: [UIBezierPath] = (0...2).map {
        if let parent = parent {
          return parent.getCircle(center: currentCenters[$0], radius: currentRadius[$0])
        } else {
          print("Parent is not initialized in 'TripleCircleShapes' class")
          return UIBezierPath()
        }
      }
      circlePaths.forEach { newPath.append($0) }
      shapeLayer.fillColor = color.cgColor
      shapeLayer.path = newPath.cgPath
      paths = newPath.cgPath
    }
    
    init(color: UIColor, radius: [CGFloat], points: [CGPoint]){
      self.color = color
      self.currentRadius = radius
      self.currentCenters = points
    }
  }
  
  let sWidth = UIScreen.main.bounds.width
  let sHeight = UIScreen.main.bounds.height
  
  enum ShapeState {
    case top
    case bottom
  }
  
  var shapeState: ShapeState = .top
  
  var color1: CGColor {
    get {
      switch shapeState {
        case .top:
          return K.colorTheme2.blue.cgColor
        case .bottom:
          return K.colorTheme2.beige.cgColor
      }
    }
  }
  var color2: CGColor {
    get {
      switch shapeState {
        case .top:
          return K.colorTheme2.beige.cgColor
        case .bottom:
          return K.colorTheme2.blue.cgColor
      }
    }
  }
  
  // DEFAULT VALUES
  lazy var centerPoints1: [CGPoint] = [
    CGPoint(x: 50, y: -10),
    CGPoint(x: sWidth * 0.3, y: sHeight * 0.7),
    CGPoint(x: sWidth * 0.7, y: sHeight * 1.1)
  ]
  
  lazy var centerPoints2: [CGPoint] = [
    CGPoint(x: UIScreen.main.bounds.width, y: 0),
    CGPoint(x: sWidth * 0.2, y: sHeight * 0.4),
    CGPoint(x: sWidth, y: sHeight * 0.7)
  ]

  lazy var centerPoints3: [CGPoint] = [
    CGPoint(x: sWidth * 0.5, y: 100),
    CGPoint(x: sWidth, y: sHeight * 0.55),
    CGPoint(x: 0, y: sHeight * 0.9)
  ]
  
  lazy var radius1: [CGFloat] = [150,30,200]
  lazy var radius2: [CGFloat] = [150,100,50]
  lazy var radius3: [CGFloat] = [150,100,150]
  
  lazy var circles1: [UIBezierPath] = [
    getCircle(center: centerPoints1[0], radius: radius1[0]),
    getCircle(center: centerPoints1[1], radius: radius1[1]),
    getCircle(center: centerPoints1[2], radius: radius1[2])
  ]
  
  lazy var circles2: [UIBezierPath] = [
    getCircle(center: centerPoints2[0], radius: radius2[0]),
    getCircle(center: centerPoints2[1], radius: radius2[1]),
    getCircle(center: centerPoints2[2], radius: radius2[2])
  ]
  
  lazy var circles3: [UIBezierPath] = [
    getCircle(center: centerPoints3[0], radius: radius3[0]),
    getCircle(center: centerPoints3[1], radius: radius3[1]),
    getCircle(center: centerPoints3[2], radius: radius3[2])
  ]
  
  lazy var pattern1: UIBezierPath = {
    var pattern1 = UIBezierPath()
    pattern1.append(circles1[0])
    pattern1.append(circles1[1])
    pattern1.append(circles1[2])
    return pattern1
  }()

  lazy var pattern2: UIBezierPath = {
    var pattern2 = UIBezierPath()
    pattern2.append(circles2[0])
    pattern2.append(circles2[1])
    pattern2.append(circles2[2])
    return pattern2
  }()

  lazy var pattern3: UIBezierPath = {
    var pattern3 = UIBezierPath()
    pattern3.append(circles3[0])
    pattern3.append(circles3[1])
    pattern3.append(circles3[2])
    return pattern3
  }()

  // END DEFAULT VALUES

  private func getCircle(center: CGPoint, radius: CGFloat) -> UIBezierPath {
    let path = UIBezierPath()
    path.addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
    return path
  }
  
  lazy var layer1: TripleCircleShapes = {
    let layer = TripleCircleShapes(
      color: K.colorTheme2.blue,
      radius: radius1,
      points: centerPoints1
    )
    layer.parent = self
    layer.setup()
    return layer
  }()
  
  lazy var layer2: TripleCircleShapes = {
    let layer = TripleCircleShapes(
      color: K.colorTheme2.beige,
      radius: radius2,
      points: centerPoints2
    )
    layer.parent = self
    layer.setup()
    return layer
  }()

  private lazy var defaultPatterns: [TripleCircleShapes] =  {
    let patterns: [TripleCircleShapes] = [
      TripleCircleShapes(color: .black, radius: radius1, points: centerPoints1),
      TripleCircleShapes(color: .black, radius: radius2, points: centerPoints2),
      TripleCircleShapes(color: .black, radius: radius3, points: centerPoints3),
    ]
    patterns.forEach{
      $0.parent = self
      $0.setup()
    }
    return patterns
  }()
  
  private func getNextPaths(path1: CGPath, path2: CGPath) -> (CGPath, CGPath)? {
    // Creates a mutable copy of random order
    var tempPatterns: [TripleCircleShapes] = defaultPatterns.shuffled()
    // Find a new cgPath that is not the same as 'path1', store it, and remove it fromt the set
    let nextPattern1: TripleCircleShapes = tempPatterns.remove(at: tempPatterns.firstIndex { $0.paths != path1 }! )
    // Find a new cgPath that is not the same as 'path2' and store it
    let nextPattern2: TripleCircleShapes = tempPatterns.first { $0.paths != path2 }!
    layer1.centers = nextPattern1.centers
    layer2.centers = nextPattern2.centers
    
    return (nextPattern1.paths, nextPattern2.paths)
  }
  
  func beginTransitionAnimation(toState state: ShapeState) {
    shapeState = state
    self.layer1.shapeLayer.removeAllAnimations()
    self.layer2.shapeLayer.removeAllAnimations()
    

    CATransaction.begin()
    CATransaction.setCompletionBlock {
      self.beginSubtleAnimation()
    }
    let animationGroups1 = CAAnimationGroup()
    let animationGroups2 = CAAnimationGroup()
    animationGroups1.duration = 0.5
    animationGroups2.duration = 0.5

    let pathAnimation1 = CABasicAnimation(keyPath: "path")
    let pathAnimation2 = CABasicAnimation(keyPath: "path")

    let fillColor1 = CABasicAnimation(keyPath: "fillColor")
    let fillColor2 = CABasicAnimation(keyPath: "fillColor")
    
    guard let (path1, path2) = getNextPaths(path1: layer1.shapeLayer.path!, path2: layer2.shapeLayer.path!) else {
      print("Patterns array might be corrupted?")
      return
    }
    
    pathAnimation1.fromValue = layer1.shapeLayer.path
    pathAnimation1.toValue   = path1
    layer1.shapeLayer.path = path1
    
    pathAnimation2.fromValue = layer2.shapeLayer.path
    pathAnimation2.toValue   = path2
    layer2.shapeLayer.path = path2
    
    fillColor1.fromValue = layer1.shapeLayer.fillColor
    fillColor1.toValue   = color1
    layer1.shapeLayer.fillColor = color1
    fillColor2.fromValue = layer2.shapeLayer.fillColor
    fillColor2.toValue   = color2
    layer2.shapeLayer.fillColor = color2
    
    animationGroups1.animations = [fillColor1, pathAnimation1]
    animationGroups2.animations = [fillColor2, pathAnimation2]
    layer1.shapeLayer.add(animationGroups1, forKey: nil)
    layer2.shapeLayer.add(animationGroups2, forKey: nil)
    CATransaction.commit()
  }
  
  func beginSubtleAnimation() {

    CATransaction.begin()
    let subtleAnimation1 = CABasicAnimation(keyPath: "path")
    let subtleAnimation2 = CABasicAnimation(keyPath: "path")
    subtleAnimation1.duration = 15
    subtleAnimation2.duration = 5
    subtleAnimation1.repeatCount = Float.infinity
    subtleAnimation2.repeatCount = Float.infinity
    subtleAnimation1.autoreverses = true
    subtleAnimation2.autoreverses = true
    
    let randomOffset: (_:CGPoint) -> CGPoint = { center in
      var newCenter = center
      newCenter.x += CGFloat.random(in: -200...200)
      newCenter.y += CGFloat.random(in: -400...400)
      return newCenter
    }
    
    let randomRadius: (_:CGFloat) -> CGFloat = { $0 + CGFloat.random(in: -200...200) }
    
    let newCenters1: [CGPoint] = layer1.centers.map{ randomOffset($0) }
    let newCenters2: [CGPoint] = layer2.centers.map{ randomOffset($0) }
    
    let newRadius1:  [CGFloat] = layer1.radius.map{ randomRadius($0) }
    let newRadius2:  [CGFloat] = layer2.radius.map{ randomRadius($0) }
    
    let newPath1: UIBezierPath = {
      let newPath1   = UIBezierPath()
      (0...2).forEach { newPath1.append(getCircle(center: newCenters1[$0], radius: newRadius1[$0])) }
      return newPath1
    }()
    
    let newPath2: UIBezierPath = {
      let newPath2 = UIBezierPath()
      (0...2).forEach { newPath2.append(getCircle(center: newCenters2[$0], radius: newRadius2[$0])) }
      return newPath2
    }()
    
    subtleAnimation1.fromValue = layer1.shapeLayer.path
    subtleAnimation1.toValue   = newPath1.cgPath
    
    subtleAnimation2.fromValue = layer2.shapeLayer.path
    subtleAnimation2.toValue   = newPath2.cgPath
    
    layer1.shapeLayer.add(subtleAnimation1, forKey: "path")
    layer2.shapeLayer.add(subtleAnimation2, forKey: "path")
    CATransaction.commit()
  }
  
  func removeAnimation() {
    layer1.shapeLayer.removeAllAnimations()
    layer2.shapeLayer.removeAllAnimations()
  }
  
  func pauseAnimation() {
    layer1.shapeLayer.pause()
    layer2.shapeLayer.pause()
  }
}
