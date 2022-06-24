//
//  LoginViewController.swift
//
//
//

import UIKit
import Firebase
import GoogleSignIn
import AuthenticationServices
import CryptoKit

class LoginViewController: UIViewController{
	
	
	
	@IBOutlet weak var emailTextField: UITextField!
	
	@IBOutlet weak var passwordTextField: UITextField!
		
	@IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var googleButton: GIDSignInButton!
 
    @IBOutlet weak var appleButton: ASAuthorizationAppleIDButton!
    
	@IBOutlet weak var containerView: UIView!
	
	fileprivate var currentNonce: String?
	
	
	
	
	
	
	override func viewDidLoad() {
		
		overrideUserInterfaceStyle = .light 
		
		let tap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		view.addGestureRecognizer(tap)
		
		
		let tapGoogleButton: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(googleButtonPressed))
		
		googleButton.addGestureRecognizer(tapGoogleButton)
		
		let tapAppleButton: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(appleSignInTapped))
		
		appleButton.addGestureRecognizer(tapAppleButton)
		
		NotificationCenter.default.addObserver(self, selector: #selector(googleIn), name: .some(NSNotification.Name(rawValue: "SuccessfulSignInNotification")), object: nil)
		
		//Customizes the text fields
		let customGreen = UIColor(red: 0, green: 0.7529, blue: 0.3451, alpha: 1.0) /* #00c058 */
		
		let bottomLineUsername = CALayer()
		bottomLineUsername.frame = CGRect(x: 0.0, y: emailTextField.frame.height - 5, width: emailTextField.frame.width, height: 1.0)
		bottomLineUsername.backgroundColor = customGreen.cgColor
		emailTextField.borderStyle = UITextField.BorderStyle.none
		emailTextField.layer.addSublayer(bottomLineUsername)
		
		emailTextField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor: customGreen])
		
		let bottomLinePassword = CALayer()
		bottomLinePassword.frame = CGRect(x: 0.0, y: passwordTextField.frame.height - 5, width: passwordTextField.frame.width, height: 1.0)
		bottomLinePassword.backgroundColor = customGreen.cgColor
		passwordTextField.borderStyle = UITextField.BorderStyle.none
		passwordTextField.layer.addSublayer(bottomLinePassword)
		
		passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: customGreen])
		
		//Customizes the apple button
		appleButton.cornerRadius = 30
		
		//Customizes the google button
		googleButton.layer.cornerRadius = 30
		containerView.layer.cornerRadius = 20
		googleButton.layer.borderColor = UIColor.white.cgColor
		googleButton.layer.borderWidth = 6
		googleButton.style = .wide
		
		
		
		
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	
	@objc func dismissKeyboard(){
		view.endEditing(true)
	}
	
	@IBAction func LoginPressed(_ sender: UIButton) {
		
		animateButton(sender)
		
		if let email = emailTextField.text, let password = passwordTextField.text{
			Auth.auth().signIn(withEmail: email, password: password) {  authResult, error in
				if let e = error {
					self.errorLabel.alpha = 1
					self.errorLabel.text = e.localizedDescription
				}else {

					let vc = self.storyboard?.instantiateViewController(identifier: "verify") as! VerifyViewController
					
					
					self.navigationController?.pushViewController(vc, animated: true)
					
				}
			}
		}
	}
    
    @objc func googleButtonPressed() {
        
	
		GIDSignIn.sharedInstance()?.presentingViewController = self
		GIDSignIn.sharedInstance()?.signIn()
		
		UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
			self.googleButton.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
		}) { (_) in
			UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
				self.googleButton.transform = CGAffineTransform(scaleX: 1, y: 1)
			}, completion: nil)
		}
		
    }
	
	@objc func googleIn() {
		
		let vc = self.storyboard?.instantiateViewController(identifier: "verify") as! VerifyViewController
		
		
		self.navigationController?.pushViewController(vc, animated: true)
		
	}
	
	
	
	@objc func appleSignInTapped() {
	
		let nonce = randomNonceString()
		currentNonce = nonce
		let appleIDProvider = ASAuthorizationAppleIDProvider()
		let request = appleIDProvider.createRequest()
		request.requestedScopes = [.fullName, .email]
		request.nonce = sha256(nonce)
		
		let authorizationController = ASAuthorizationController(authorizationRequests: [request])
		authorizationController.delegate = self
		authorizationController.presentationContextProvider = self
		authorizationController.performRequests()
		
		UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
			self.googleButton.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
		}) { (_) in
			UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
				self.googleButton.transform = CGAffineTransform(scaleX: 1, y: 1)
			}, completion: nil)
		}
		
	}
	
	
	
	private func randomNonceString(length: Int = 32) -> String {
		precondition(length > 0)
		let charset: Array<Character> =
			Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
		var result = ""
		var remainingLength = length
		
		while remainingLength > 0 {
			let randoms: [UInt8] = (0 ..< 16).map { _ in
				var random: UInt8 = 0
				let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
				if errorCode != errSecSuccess {
					fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
				}
				return random
			}
			
			randoms.forEach { random in
				if remainingLength == 0 {
					return
				}
				
				if random < charset.count {
					result.append(charset[Int(random)])
					remainingLength -= 1
				}
			}
		}
		
		return result
	}
	
	private func sha256(_ input: String) -> String {
		let inputData = Data(input.utf8)
		let hashedData = SHA256.hash(data: inputData)
		let hashString = hashedData.compactMap {
			return String(format: "%02x", $0)
		}.joined()
		
		return hashString
	}
    
    @IBAction func unwindToLoginViewController(_ unwindSegue: UIStoryboardSegue) { }
	
	
	@IBAction func ForgotButton(_ sender: UIButton) {
		let vc = storyboard?.instantiateViewController(identifier: "Forgot") as! ForgotPasswordViewController
		
		present(vc, animated: true, completion: nil)
	}
	
	//Makes the button animate when it gets pressed
	public func animateButton(_ sender: UIButton) {
		UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
			sender.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
		}) { (_) in
			UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
				sender.transform = CGAffineTransform(scaleX: 1, y: 1)
			}, completion: nil)
		}
	}
	
}

extension LoginViewController : ASAuthorizationControllerDelegate {

	
	func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
		
		if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
			// Do something with the credential...
			
			UserDefaults.standard.set(appleIDCredential.user, forKey: "appleAuthorizedUserIdKey")
			
			guard let nonce = currentNonce else {
				fatalError("Invalid state: A login callback was received, but no login request was sent.")
			}
			
			// Retrieve Apple identity token
			guard let appleIDToken = appleIDCredential.identityToken else {
				print("Failed to fetch identity token")
				return
			}
			
			// Convert Apple identity token to string
			guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
				print("Failed to decode identity token")
				return
			}
			
			let credential = OAuthProvider.credential(withProviderID: "apple.com",
													  idToken: idTokenString,
													  rawNonce: nonce)
			// Sign in with Firebase.
			Auth.auth().signIn(with: credential) { (authResult, error) in
				if (error != nil) {
					// Error. If error.code == .MissingOrInvalidNonce, make sure
					// you're sending the SHA256-hashed nonce as a hex string with
					// your request to Apple.
					print(error!.localizedDescription)
					return
				} else {
					
					let vc = self.storyboard?.instantiateViewController(identifier: "verify") as! VerifyViewController
					
					
					self.navigationController?.pushViewController(vc, animated: true)
					
					
					
					
				}
				
			}
			
		}
		
		
		

		
		
	}
	
	
}

extension LoginViewController : ASAuthorizationControllerPresentationContextProviding {
	func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
		// return the current view window
		
		return self.view.window!
	}
}

