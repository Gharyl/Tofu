import UIKit

class WelcomeVC: UIViewController {
  weak var coordinator: MainCoordinator?
  var firebase: FirebaseCommunicator?
  
  var bubbleBackground: BubbleBackground
  
  let signupVC: SignUpViewController!
  let signinVC: SignInViewController!
  
  lazy var animatedBackground: UIView = {
    let animatedBackground = UIView()
    animatedBackground.layer.insertSublayer(bubbleBackground.gradientBackground, at: 0)
    // Adding individual bubble
    for (num, bubble) in bubbleBackground.bubbles.enumerated() {
      animatedBackground.layer.insertSublayer(bubble, at: UInt32(num))
    }
    animatedBackground.translatesAutoresizingMaskIntoConstraints = false
    return animatedBackground
  }()
  
  var loadingView: LoadingView = {
    let loadingView = LoadingView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
    return loadingView
  }()

  var checkmarkView: CheckmarkView = {
    let checkmarkView = CheckmarkView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
    return checkmarkView
  }()
  
  private func setBackground() {
    bubbleBackground.beginAnimation()
    animatedBackground.frame = CGRect(
      x: -K.Screen.width * 0.9,
      y: 0,
      width: view.frame.width * 3,
      height: view.frame.height
    )
  }
  
  private func setSubviews() {
    signupVC.view.frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.7))
    signupVC.view.center = view.center
    signinVC.view.frame.size = CGSize(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.45)
    signinVC.view.center = view.center
    
    signinVC.view.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width, y: 0)
    
    view.addSubview(animatedBackground)
    addSubVC(signupVC)
    addSubVC(signinVC)
  }
  
  private func setConstraints() {
    NSLayoutConstraint.activate([
      
    ])
  }
  
  @objc
  private func dismissKeyboard(_ sender: UITapGestureRecognizer) {
    print("welcomevc dismising")
    view.subviews.forEach{ $0.endEditing(true) }
  }
  
  
  func reset() {
    loadingView.removeFromSuperview()
    checkmarkView.removeFromSuperview()
    signinVC.prepare(for: .reset)
    signupVC.prepare(for: .reset)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    reset()
    navigationController?.navigationBar.isHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.navigationBar.isHidden = false
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    children.forEach { vc in
      let gradient = CAGradientLayer()
      gradient.type = .axial
      gradient.startPoint = CGPoint(x: -1, y: -1)
      gradient.endPoint   = CGPoint(x: 1, y: 1)
      gradient.frame = view.bounds
      gradient.colors = [UIColor.clear.cgColor, UIColor.white.withAlphaComponent(0.3).cgColor, UIColor.clear.cgColor]
      gradient.locations = [-1, -0.5, 0]
      
      let shimmerAnimation = CABasicAnimation(keyPath: "locations")
      shimmerAnimation.fromValue = gradient.locations
      shimmerAnimation.toValue   = [1, 1.5, 2]
      shimmerAnimation.duration  = 2
      shimmerAnimation.repeatCount = .infinity
      
      if let child = vc as? TransitionBlurProtocol {
        child.blurViewRef.layer.insertSublayer(gradient, at: 0)
        gradient.add(shimmerAnimation, forKey: nil)
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bubbleBackground.gradientFrame = view.frame
    setBackground()
    setSubviews()
  }

  init(signinVC: SignInViewController, signupVC: SignUpViewController) {
    self.signinVC = signinVC
    self.signupVC = signupVC
    self.bubbleBackground = BubbleBackground()
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - WelcomeViewDelegate
extension WelcomeVC: WelcomeViewDelegate {
  func signInTapped() {
    addSubVC(signinVC)
    
    // BubbleBackground animation
    UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: [.curveEaseInOut]) {
      self.animatedBackground.transform = CGAffineTransform(translationX: K.Screen.width * 0.8, y: 0)
    }

    // Animate signupVC/signinVC out/in of the screen
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: [.curveEaseOut]) {
      self.signupVC.view.transform = CGAffineTransform(translationX: -UIScreen.main.bounds.width, y: 0)
      self.signinVC.view.transform = .identity
    } completion: { _ in
      self.removeSubVC(self.signupVC)
    }
  }
  
  func signUpTapped() {
    addSubVC(signupVC)
    // BubbleBackground animation
    UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: [.curveEaseInOut]) {
      self.animatedBackground.transform = .identity
    }
    
    // Animate signupVC/signinVC in/out of the screen
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: [.curveEaseOut]) {
      self.signinVC.view.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width, y: 0)
      self.signupVC.view.transform = .identity
    } completion: { _ in
      self.removeSubVC(self.signinVC)
    }
  }
}

// MARK: - UIViewController Extention
extension UIViewController {
  func addSubVC(_ childVC: UIViewController) {
    addChild(childVC)
    childVC.didMove(toParent: self)
    view.addSubview(childVC.view)
  }
  
  func removeSubVC(_ childVC: UIViewController) {
    childVC.willMove(toParent: nil)
    childVC.removeFromParent()
    childVC.view.removeFromSuperview()
  }
}


// MARK: - Animation + Firebase
extension WelcomeVC: WelcomeViewSubmissionDelegate {
  enum Preparation {
    case loading
    case reset
  }
  
  // Loading animation
  func beginLoading() {
    UIView.animate(withDuration: 0.3) {
      self.signupVC.prepare(for: .loading)
      self.signinVC.prepare(for: .loading)
    } completion: { finished in
      if finished {
        self.loadingView.center = self.view.center
        self.view.addSubview(self.loadingView)
        self.loadingView.beginAnimation()
      }
    }
  }
  
  // Success animation
  func loadingSuccess() {
    loadingView.endAnimation()
    checkmarkView.center = view.center
    view.addSubview(checkmarkView)
    checkmarkView.beginAnimation()
  }
  
  func firebaseSignin(email: String, password: String) {
    beginLoading()
    Task {
      let error = await firebase?.signinUser( withEmail: email, andPassword: password)
      if let error = error {
        print("Log in error \(error.localizedDescription)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
          UIView.animate(withDuration: 0.3) {
            self.reset()
          }
        }
      } else {
        self.loadingSuccess()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
          self.coordinator?.showHomeViewController()
        }
      }
    }
  }
  
  func firebaseSignup(firstName: String, lastName: String, username: String, email: String, password: String) {
    beginLoading()
    firebase?.createUser(
      withEmail: email,
      andPassword: password,
      firstName: firstName,
      lastName: lastName,
      imageData: nil,
      username: username
    ) { error in
      if let error = error {
        print("error occured: \(error.localizedDescription)")
        DispatchQueue.main.async {
          self.reset()
        }
      } else {
        DispatchQueue.main.async { // Why does it crash if I don't do this? Screen animation needs to be performed on the main thread..?
          self.loadingSuccess()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
          self.coordinator?.showHomeViewController()
        }
      }
    }
  }
}

// MARK: - Used in TransitionAnimator.swift for custom transitions
// SignupViewController and SigninViewController both conform to this protocol
protocol TransitionBlurProtocol {
  var blurViewRef: UIVisualEffectView { get }
}


// MARK: - UITextField Extension
// Adding padding to the left side of a UITextField
extension UITextField {
  func setPadding(_ amount: CGFloat){
    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
    self.leftView = paddingView
    self.leftViewMode = .always
    self.rightView = paddingView
    self.rightViewMode = .always
  }
}
