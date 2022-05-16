import UIKit

protocol WelcomeViewDelegate: AnyObject {
  func signInTapped()
  func signUpTapped()
}

protocol WelcomeViewSubmissionDelegate {
  func firebaseSignup(
    firstName: String,
    lastName:  String,
    username:  String,
    email:     String,
    password:  String
  )
  
  func firebaseSignin(
    email:     String,
    password:  String
  )
}
