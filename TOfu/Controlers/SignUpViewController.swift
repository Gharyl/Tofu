import UIKit

class SignUpViewController: UIViewController {
  var delegate: WelcomeViewDelegate?
  var submissionDelegate: WelcomeViewSubmissionDelegate?
  var focusedTextField: UITextField?
  
  private lazy var blurView: UIVisualEffectView = {
    let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
    let blurView = UIVisualEffectView(effect: blurEffect)
    blurView.layer.borderColor = UIColor.white.cgColor
    blurView.layer.borderWidth = 1
    blurView.layer.cornerRadius = 30
    blurView.clipsToBounds = true
    let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
    blurView.addGestureRecognizer(gesture)
    blurView.translatesAutoresizingMaskIntoConstraints = false
    return blurView
  }()
  
  private lazy var greeting: UILabel = {
    let greeting = UILabel()
    greeting.numberOfLines = 2
    greeting.textColor = K.colorTheme2.blue
    let text = NSMutableAttributedString(string: "Welcome!\nSign Up Here To Get Started!")
    text.setAttributes([ .font : UIFont.systemFont(ofSize: 45) ], range: NSMakeRange(0, 8))
    text.setAttributes([ .font : UIFont.systemFont(ofSize: 20) ], range: NSMakeRange(9, 28))
    greeting.attributedText = text
    greeting.translatesAutoresizingMaskIntoConstraints = false
    return greeting
  }()
  
  private lazy var firstName: UITextField = {
    let firstName = UITextField()
    let placeholder = NSAttributedString(string: "First Name", attributes: [.foregroundColor: K.colorTheme2.blue])
    firstName.setPadding(20)
    firstName.attributedPlaceholder = placeholder
    firstName.autocorrectionType = .no
    firstName.delegate = self
    firstName.translatesAutoresizingMaskIntoConstraints = false
    return firstName
  }()
  
  private lazy var lastName: UITextField = {
    let lastName = UITextField()
    let placeholder = NSAttributedString(string: "Last Name", attributes: [.foregroundColor: K.colorTheme2.blue])
    lastName.setPadding(20)
    lastName.delegate = self
    lastName.autocorrectionType = .no
    lastName.attributedPlaceholder = placeholder
    lastName.placeholder = "Last Name"
    return lastName
  }()
  
  private lazy var username: UITextField = {
    let username = UITextField()
    let placeholder = NSAttributedString(string: "Username", attributes: [.foregroundColor: K.colorTheme2.blue])
    username.setPadding(20)
    username.autocorrectionType = .no
    username.autocapitalizationType = .none
    username.delegate = self
    username.attributedPlaceholder = placeholder
    username.placeholder = "Username"
    return username
  }()
  
  private lazy var email: UITextField = {
    let email = UITextField()
    let placeholder = NSAttributedString(string: "Email Address", attributes: [.foregroundColor: K.colorTheme2.blue])
    email.autocorrectionType = .no
    email.setPadding(20)
    email.delegate = self
    email.autocapitalizationType = .none
    email.attributedPlaceholder = placeholder
    email.placeholder = "Email"
    return email
  }()
  
  private lazy var password: UITextField = {
    let password = UITextField()
    let placeholder = NSAttributedString(string: "Password", attributes: [.foregroundColor: K.colorTheme2.blue])
    password.setPadding(20)
    password.delegate = self
    password.isSecureTextEntry = true
    password.autocorrectionType = .no
    password.autocapitalizationType = .none
    password.attributedPlaceholder = placeholder
    password.placeholder = "Password"
    return password
  }()

  private lazy var vStack: UIStackView = {
    let hStack = UIStackView()
    hStack.axis = .vertical
    hStack.distribution = .fillEqually
    hStack.alignment = .fill
    hStack.layer.borderWidth = 1
    hStack.layer.borderColor = K.colorTheme2.blue2.cgColor
    hStack.layer.cornerRadius = 20
    hStack.translatesAutoresizingMaskIntoConstraints = false
    return hStack
  }()
  
  private lazy var signUpButton: UIButton = {
    let submitButton = UIButton()
    submitButton.setTitle("Sign Up", for: .normal)
    submitButton.setTitleColor(K.colorTheme2.gray1, for: .normal)
    submitButton.backgroundColor = K.colorTheme2.blue
    submitButton.layer.cornerRadius = 20
    submitButton.translatesAutoresizingMaskIntoConstraints = false
    return submitButton
  }()
  
  private lazy var signInLabel: UILabel = {
    let signInLabel = UILabel()
    signInLabel.text = "Already have an account?"
    signInLabel.textColor = K.colorTheme2.blue.withAlphaComponent(0.5)
    signInLabel.translatesAutoresizingMaskIntoConstraints = false
    return signInLabel
  }()
  
  private lazy var signInButton: UIButton = {
    let signInButton = UIButton()
    signInButton.setTitle("Sign In", for: .normal)
    signInButton.setTitleColor(K.colorTheme2.blue, for: .normal)
    signInButton.setTitleColor(K.colorTheme2.blue.withAlphaComponent(0.5), for: .highlighted)
    signInButton.translatesAutoresizingMaskIntoConstraints = false
    return signInButton
  }()
  
  private lazy var hStack: UIStackView = {
    let hStack = UIStackView()
    hStack.axis = .horizontal
    hStack.alignment = .center
    hStack.distribution = .equalSpacing
    hStack.spacing = 5
    hStack.translatesAutoresizingMaskIntoConstraints = false
    return hStack
  }()
  
  private func setSubviews(){
    view.addSubview(blurView)
    view.addSubview(greeting)
    vStack.addArrangedSubview(firstName)
    vStack.addArrangedSubview(lastName)
    vStack.addArrangedSubview(username)
    vStack.addArrangedSubview(email)
    vStack.addArrangedSubview(password)
    view.addSubview(vStack)
    view.addSubview(signUpButton)
    hStack.addArrangedSubview(signInLabel)
    hStack.addArrangedSubview(signInButton)
    view.addSubview(hStack)
  }
  
  private func setConstraints(){
    NSLayoutConstraint.activate([
      blurView.topAnchor.constraint(equalTo: view.topAnchor),
      blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      
      greeting.topAnchor.constraint(equalTo: blurView.topAnchor, constant: 30),
      greeting.leadingAnchor.constraint(equalTo: blurView.leadingAnchor, constant: 30),
      greeting.bottomAnchor.constraint(equalTo: vStack.topAnchor, constant: -40),
      
      vStack.topAnchor.constraint(equalTo: greeting.bottomAnchor, constant: 40),
      vStack.leadingAnchor.constraint(equalTo: blurView.leadingAnchor, constant: 30),
      vStack.trailingAnchor.constraint(equalTo: blurView.trailingAnchor, constant: -30),
      vStack.heightAnchor.constraint(equalToConstant: 300),
      vStack.bottomAnchor.constraint(equalTo: signUpButton.topAnchor, constant: -20),
      
      signUpButton.topAnchor.constraint(equalTo: vStack.bottomAnchor, constant: 20),
      signUpButton.leadingAnchor.constraint(equalTo: blurView.leadingAnchor, constant: 30),
      signUpButton.trailingAnchor.constraint(equalTo: blurView.trailingAnchor, constant: -30),
      signUpButton.heightAnchor.constraint(equalToConstant: 40),
    
      hStack.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 10),
      hStack.centerXAnchor.constraint(equalTo: signUpButton.centerXAnchor),
      hStack.heightAnchor.constraint(equalToConstant: 30)
    ])
  }

  @objc
  private func signInTapped(_ sender: UIButton) {
    delegate?.signInTapped()
  }
  
  @objc
  private func dismissKeyboard(_ sender: UIGestureRecognizer) {
    view.endEditing(true)
  }
  
  @objc
  private func keyboardWillShow(_ sender: NSNotification) {
    guard let keyboardHeightNSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
    let keyboardHeight = keyboardHeightNSValue.cgRectValue.origin.y
    if let focusedTextField = focusedTextField {
      let textFieldHeight = vStack.convert(focusedTextField.frame, to: nil).maxY
      if textFieldHeight > keyboardHeight {
        print("\(view.bounds.origin.y)")
        view.bounds.origin.y += textFieldHeight - keyboardHeight
      }
    }
  }
  
  @objc
  private func keyboardWillHide(_ sender: NSNotification) {
    view.bounds.origin.y = 0
  }
  
  @objc
  private func signupSubmission(_ sender: UIButton) {
    guard
      let safeFirstName = firstName.text,
      let safeLastName  = lastName.text,
      let safeUsername  = username.text,
      let safeEmail     = email.text,
      let safePassword  = password.text
    else { return }
    
    submissionDelegate?.firebaseSignup(
      firstName: safeFirstName,
      lastName: safeLastName,
      username: safeUsername,
      email: safeEmail,
      password: safePassword)
  }
  
  private func setShimmerEffect() {
    let testcolors = [UIColor.red.cgColor, UIColor.green.cgColor, UIColor.blue.cgColor]
    let gradient = CAGradientLayer()
    gradient.type = .axial
    gradient.startPoint = CGPoint(x: -1, y: -1)
    gradient.endPoint   = CGPoint(x: 1, y: 1)
    gradient.frame = blurView.frame
    gradient.colors = [UIColor.clear.cgColor, UIColor.white.withAlphaComponent(0.5).cgColor, UIColor.clear.cgColor]
    gradient.locations = [-1, -0.5, 0]
    blurView.layer.insertSublayer(gradient, at: 0)
    
    let shimmerAnimation = CABasicAnimation(keyPath: "locations")
    shimmerAnimation.fromValue = gradient.locations
    shimmerAnimation.toValue   = [1, 1.5, 2]
    shimmerAnimation.duration  = 2
    shimmerAnimation.repeatCount = .infinity
    gradient.add(shimmerAnimation, forKey: nil)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
//    setShimmerEffect()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setSubviews()
    setConstraints()
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:))))
    signInButton.addTarget(self, action: #selector(signInTapped(_:)), for: .touchUpInside)
    signUpButton.addTarget(self, action: #selector(signupSubmission(_:)), for: .touchUpInside)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
}


// MARK: - UITextfieldDelegate
extension SignUpViewController: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    focusedTextField = textField
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    focusedTextField = nil
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if let focusedTextField = focusedTextField {
      signUpButton.sendActions(for: .touchUpInside)
      focusedTextField.resignFirstResponder()
    }
    return true
  }
}


// MARK: - Prepare for Animation
extension SignUpViewController: TransitionBlurProtocol {
  var blurViewRef: UIVisualEffectView { blurView }
  
  func prepare(for action: WelcomeVC.Preparation) {
    let valueChange: CGFloat
    switch action {
      case .loading:
        valueChange = 0
      case .reset:
        valueChange = 1
    }
    self.greeting.alpha = valueChange
    self.vStack.alpha = valueChange
    self.signUpButton.alpha  = valueChange
    self.hStack.alpha = valueChange
  }
}

