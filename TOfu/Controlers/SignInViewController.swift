import UIKit

class SignInViewController: UIViewController {
  var delegate: WelcomeViewDelegate?
  var submissionDelegate: WelcomeViewSubmissionDelegate?
  
  var focusedTextField: UITextField?
  
  let blurWidth: CGFloat = UIScreen.main.bounds.width * 0.9
  let blurHeight: CGFloat = UIScreen.main.bounds.height * 0.45
  
  @objc
  private func dismissKeyboard(_ sender: UIGestureRecognizer) {
    view.endEditing(true)
  }
  
  private lazy var blurView: UIVisualEffectView = {
    let blurEffect = UIBlurEffect(style: .light)
    let blurView = UIVisualEffectView(effect: blurEffect)
    blurView.layer.cornerRadius = 30
    blurView.layer.borderColor = K.colorTheme2.gray1.cgColor
    blurView.layer.borderWidth = 1
    blurView.clipsToBounds = true
    blurView.frame = CGRect(x: 0, y: 0, width: blurWidth, height: blurHeight)
    let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
    blurView.addGestureRecognizer(gesture)
    return blurView
  }()
  
  private lazy var greeting: UILabel = {
    let greeting = UILabel()
    greeting.text = "Glad To Have You Back!"
    greeting.font = greeting.font.withSize(25)
    greeting.textColor = K.colorTheme2.blue
    greeting.translatesAutoresizingMaskIntoConstraints = false
    return greeting
  }()
  
  private lazy var email: UITextField = {
    let email = UITextField()
    email.setPadding(20)
    email.textColor = K.colorTheme2.blue
    email.autocorrectionType = .no
    email.autocapitalizationType = .none
    let placeholder = NSAttributedString(
      string: "Email",
      attributes: [
        .font: UIFont.systemFont(ofSize: 20),
        .foregroundColor: K.colorTheme2.blue.withAlphaComponent(0.5)
      ])
    email.attributedPlaceholder = placeholder
    return email
  }()
  
  private lazy var password: UITextField = {
    let password = UITextField()
    password.setPadding(20)
    password.textColor = K.colorTheme2.blue
    password.isSecureTextEntry = true
    let placeholder = NSAttributedString(
      string: "Password",
      attributes: [
        .font: UIFont.systemFont(ofSize: 20),
        .foregroundColor: K.colorTheme2.blue.withAlphaComponent(0.5)
      ])
    password.attributedPlaceholder = placeholder
    return password
  }()
  
  private lazy var signinButton: UIButton = {
    let signinButton = UIButton()
    signinButton.setTitleColor(K.colorTheme2.blue, for: .normal)
    signinButton.setTitle("Sign In", for: .normal)
    signinButton.backgroundColor = K.colorTheme2.gray1
    signinButton.layer.borderWidth = 1
    signinButton.layer.borderColor = K.colorTheme2.blue.cgColor
    signinButton.layer.cornerRadius = 20
    signinButton.translatesAutoresizingMaskIntoConstraints = false
    return signinButton
  }()
  
  private lazy var vStack: UIStackView = {
    let vStack = UIStackView()
    vStack.axis = .vertical
    vStack.alignment = .fill
    vStack.distribution = .fillEqually
    vStack.layer.borderWidth = 1
    vStack.layer.borderColor = K.colorTheme2.blue.withAlphaComponent(0.5).cgColor
    vStack.layer.cornerRadius = 20
    vStack.addArrangedSubview(email)
    vStack.addArrangedSubview(password)
    vStack.translatesAutoresizingMaskIntoConstraints = false
    return vStack
  }()
  
  private lazy var signUpLabel: UILabel = {
    let signUpLabel = UILabel()
    signUpLabel.text = "Don't have an account yet?"
    signUpLabel.textColor = K.colorTheme2.blue.withAlphaComponent(0.5)
    signUpLabel.translatesAutoresizingMaskIntoConstraints = false
    return signUpLabel
  }()
  
  private lazy var signUpButton: UIButton = {
    let signUpButton = UIButton()
    signUpButton.setTitle("Sign Up", for: .normal)
    signUpButton.setTitleColor(K.colorTheme2.blue, for: .normal)
    signUpButton.setTitleColor(.white, for: .highlighted)
    signUpButton.translatesAutoresizingMaskIntoConstraints = false
    return signUpButton
  }()
  
  private lazy var hStack: UIStackView = {
    let hStack = UIStackView()
    hStack.axis = .horizontal
    hStack.alignment = .center
    hStack.distribution = .equalSpacing
    hStack.spacing = 5
    hStack.addArrangedSubview(signUpLabel)
    hStack.addArrangedSubview(signUpButton)
    hStack.translatesAutoresizingMaskIntoConstraints = false
    return hStack
  }()
  
  private func setSubviews(){
    view.addSubview(blurView)
    view.addSubview(greeting)
    view.addSubview(vStack)
    view.addSubview(signinButton)
    view.addSubview(hStack)
  }
  
  private func setConstraints(){
    NSLayoutConstraint.activate([
      greeting.topAnchor.constraint(equalTo: blurView.topAnchor, constant: 30),
      greeting.leadingAnchor.constraint(equalTo: blurView.leadingAnchor, constant: 30),
      
      vStack.topAnchor.constraint(equalTo: greeting.bottomAnchor, constant: 30),
      vStack.leadingAnchor.constraint(equalTo: blurView.leadingAnchor, constant: 30),
      vStack.trailingAnchor.constraint(equalTo: blurView.trailingAnchor, constant: -30),
      vStack.bottomAnchor.constraint(equalTo: signinButton.topAnchor, constant: -30),
      vStack.heightAnchor.constraint(equalToConstant: 150),
      
      signinButton.topAnchor.constraint(equalTo: vStack.bottomAnchor, constant: 30),
      signinButton.leadingAnchor.constraint(equalTo: blurView.leadingAnchor, constant: 30),
      signinButton.trailingAnchor.constraint(equalTo: blurView.trailingAnchor, constant: -30),
      signinButton.bottomAnchor.constraint(equalTo: hStack.topAnchor, constant: -10),
      signinButton.heightAnchor.constraint(equalToConstant: 40),
      
      hStack.topAnchor.constraint(equalTo: signinButton.bottomAnchor, constant: 10),
      hStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
    ])
  }
  
  @objc
  private func signUpTapped(_ sender: UIButton) {
    delegate?.signUpTapped()
  }
  
  @objc
  private func signinSubmission(_ sender: UIButton) {
    guard
      var safeEmail = email.text,
      var safePassword = password.text
    else { return }
    if safeEmail.isEmpty {
      safeEmail = "gary@test.com"
      safePassword = "garypassword"
    }
    submissionDelegate?.firebaseSignin(email: safeEmail, password: safePassword)
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    setSubviews()
    setConstraints()
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:))))
    signUpButton.addTarget(self, action: #selector(signUpTapped(_:)), for: .touchUpInside)
    signinButton.addTarget(self, action: #selector(signinSubmission(_:)), for: .touchUpInside)
  }
}


// MARK: - Preparation for LoadingView() Animation
extension SignInViewController: TransitionBlurProtocol {
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
    self.signinButton.alpha  = valueChange
    self.hStack.alpha = valueChange
  }
}

extension SignInViewController: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    focusedTextField = textField
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if let focusedTextField = focusedTextField {
      signinButton.sendActions(for: .touchUpInside)
      focusedTextField.resignFirstResponder()
    }
    return true
  }
}
