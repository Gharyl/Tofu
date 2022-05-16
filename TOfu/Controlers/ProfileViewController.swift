import UIKit
import PhotosUI

class ProfileViewController: UIViewController {
  weak var coordinator: HomeVCCoordinator?
  var db : FirebaseCommunicator?
  var profile: Profile! {
    didSet {
      print("ProfileVC received new proifle object")
      friendRequestButton.title = "Friend Requests: \(profile.receivedRequests.count)"
    }
  }
  var focusedTextView: UITextView!
  
  private lazy var profileImageView: UIImageView = {
    let profileImage = UIImageView()
    profileImage.contentMode = .scaleAspectFill
    profileImage.layer.cornerRadius = 75
    profileImage.clipsToBounds = true
    profileImage.image = UIImage(systemName: "person.crop.circle.fill")
    profileImage.tintColor = K.colorTheme.beigeL
    profileImage.isUserInteractionEnabled = true
    profileImage.translatesAutoresizingMaskIntoConstraints = false
    return profileImage
  }()
  
  private lazy var name: UILabel = {
    let name = UILabel()
    name.text = profile.firstName + " " + profile.lastName
    name.translatesAutoresizingMaskIntoConstraints = false
    return name
  }()
  
  private lazy var status: UITextView = {
    let status = UITextView()
    let placeholder = profile.status.isEmpty ? "Tap Here to Edit/Add a Status" : profile.status
    status.text = placeholder
    status.textColor = .gray
    status.returnKeyType = .continue
    status.isScrollEnabled = false
    status.delegate = self
    status.textContainer.maximumNumberOfLines = 5
    status.textContainer.lineBreakMode = .byTruncatingTail
    status.layer.borderColor = UIColor.white.cgColor
    status.layer.borderWidth = 1
    status.layer.cornerRadius = 10
    status.textAlignment = .center
    status.inputAccessoryView = toolBar
    status.autocorrectionType = UITextAutocorrectionType.no
    status.inputAssistantItem.leadingBarButtonGroups = []
    status.inputAssistantItem.trailingBarButtonGroups = []
    status.translatesAutoresizingMaskIntoConstraints = false
    return status
  }()
  
  private lazy var toolBar: UIToolbar = {
    let toolBar = UIToolbar()
    toolBar.sizeToFit()
    let doneButton = UIBarButtonItem(title: "DONE", style: .done, target: self, action: #selector(resignKeyboard(_:)))
    let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
    toolBar.setItems([space, doneButton], animated: true)
    return toolBar
  }()
  
  
  private lazy var friendRequestButton: CustomButton = {
    let friendRequestButton = CustomButton(frame: .zero, title: "Friend Requests: \(profile.receivedRequests.count)")
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showFriendRequests(_:)))
    friendRequestButton.layer.cornerRadius = 10
    friendRequestButton.backgroundColor = K.colorTheme2.blue2
    friendRequestButton.isUserInteractionEnabled = true
    friendRequestButton.addGestureRecognizer(tapGesture)
    friendRequestButton.translatesAutoresizingMaskIntoConstraints = false
    return friendRequestButton
  }()
  
  private lazy var logoutButton: UIButton = {
    var config = UIButton.Configuration.filled()
    config.title = "Log Out"
    config.baseBackgroundColor = K.colorTheme2.gray2
    config.baseForegroundColor = K.colorTheme2.gray1
    config.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 40, bottom: 5, trailing: 40)
    config.cornerStyle = .capsule
    let logoutButton = UIButton(configuration: config)
    logoutButton.layer.shadowColor = K.colorTheme2.gray3.cgColor
    logoutButton.layer.shadowOffset = CGSize(width: 0, height: 5)
    logoutButton.layer.shadowOpacity = 0.5
    logoutButton.layer.shadowRadius = 10
    logoutButton.translatesAutoresizingMaskIntoConstraints = false
    return logoutButton
  }()
  
  private func setConstraints() {
    NSLayoutConstraint.activate([
      profileImageView.widthAnchor.constraint(equalToConstant: 150),
      profileImageView.heightAnchor.constraint(equalToConstant: 150),
      profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      profileImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),

      name.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
      name.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      name.bottomAnchor.constraint(equalTo: status.topAnchor, constant: -10),
      
      status.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 10),
      status.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      status.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      status.bottomAnchor.constraint(equalTo: friendRequestButton.topAnchor, constant: -10),
      
      friendRequestButton.topAnchor.constraint(equalTo: status.bottomAnchor, constant: 10),
      friendRequestButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      friendRequestButton.widthAnchor.constraint(equalToConstant: 180),
      friendRequestButton.heightAnchor.constraint(equalToConstant: 35),
      
      logoutButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -K.Screen.height * 0.1),
      logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
    ])
  }
  
  private func setSubviews(){
    view.addSubview(profileImageView)
    view.addSubview(name)
    view.addSubview(status)
    view.addSubview(friendRequestButton)
    view.addSubview(logoutButton)
  }
  
  private func setGestures() {
    let dismissKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(resignKeyboard(_:)))
    let editProfileImageGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped(_:)))
    profileImageView.addGestureRecognizer(editProfileImageGesture)
    view.addGestureRecognizer(dismissKeyboardGesture)
  }
  
  @objc
  private func profileImageTapped(_ sender: UIImageView) {
    print("profile tapped")
    
    //TODL: - IMAGE PICKER
    coordinator?.showPickerViewController()
  }
  
  @objc
  private func resignKeyboard(_ sender: AnyObject) {
    guard let focusedTextView = focusedTextView else { return }
    focusedTextView.resignFirstResponder()
  }
  
  @objc
  private func showFriendRequests(_ sender: UITapGestureRecognizer) {
    coordinator?.showFriendRequestViewController()
  }

  
  private func setProfileImage() {
    guard let id = coordinator?.userModel.id else { return }
    ImageManager.shared.retreiveProfileImageFor(id: id) { image in
      print("got a profile image \(image.pngData()?.count)")
      DispatchQueue.main.async {
        self.profileImageView.image = image
      }
    }
  }
  
  override func viewDidLoad() {
    view.backgroundColor = K.colorTheme2.gray1
    super.viewDidLoad()
    setSubviews()
    setConstraints()
    setProfileImage()
    setGestures()
  }
  
  init(userProfile: Profile){
    self.profile = userProfile
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}


// MARK: - UITextView Delegate
extension ProfileViewController: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.text == "Tap Here to Edit/Add a Status" {
      textView.text = ""
      textView.textColor = .black
    }
  }
  
  func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
    if textView.text.isEmpty {
      textView.text = "Tap Here to Edit/Add a Status"
      textView.textColor = .gray
    }
    return true
  }
  
  func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
    focusedTextView = textView
    return true
  }
}

extension ProfileViewController: PHPickerViewControllerDelegate {
  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    let itemProviders = results.map{ $0.itemProvider }
    for item in itemProviders {
      if item.canLoadObject(ofClass: UIImage.self) {
        item.loadObject(ofClass: UIImage.self) { image, error in
          if let error = error { return print(error.localizedDescription) }
          guard let image = image as? UIImage else {
            print("data failed")
            return
          }
          
          let compressedData = image.jpegData(compressionQuality: 0.1)!
          
          LocalStorage.shared.storeProfileImage(with: compressedData, id: self.profile.id!, using: .fileSystem)
          Task {
            self.db?.uploadImage(with: compressedData)
            print("finished saving")
            self.coordinator?.returnToPreviousView()
          }
        }
      }
    }
    coordinator?.returnToPreviousView()
  }
}

extension ProfileViewController: ProfileTransitionDelegate {
  var friendRequestButtonRef: CustomButton {
    friendRequestButton
  }
  
  var friendButtonCopy: CustomButton {
    let button = CustomButton(frame: .zero, title: "Friend Requests: \(profile.receivedRequests.count)")
    button.backgroundColor = K.colorTheme2.blue2
    button.frame = friendRequestButton.frame
    button.layer.cornerRadius = 10
    button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    return button
  }
}


protocol ProfileTransitionDelegate: AnyObject {
  var friendRequestButtonRef: CustomButton { get }
  var friendButtonCopy: CustomButton { get }
}
