//
//  SignUpViewController.swift
//  
//
//  Created by Antonio Lettieri on 16/05/2020.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

   
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var errorLable: UILabel!
        
	let loginVC = LoginViewController()
	
    let ref = Database.database().reference()
    
	
	override func viewDidLoad() {
		overrideUserInterfaceStyle = .light 
		let tap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		view.addGestureRecognizer(tap)
        
        let cgCustomBlue = CGColor(srgbRed: 0.2157, green: 0.2118, blue: 0.2941, alpha: 1.0) /* #37364b */
        
        //Customizes the text fields
        let bottomLineEmail = CALayer()
        bottomLineEmail.frame = CGRect(x: 0.0, y: emailTextField.frame.height - 5, width: emailTextField.frame.width, height: 1.0)
        bottomLineEmail.backgroundColor = cgCustomBlue
        emailTextField.borderStyle = UITextField.BorderStyle.none
        emailTextField.layer.addSublayer(bottomLineEmail)
        
        let bottomLinePassword = CALayer()
        bottomLinePassword.frame = CGRect(x: 0.0, y: passwordTextField.frame.height - 5, width: passwordTextField.frame.width, height: 1.0)
        bottomLinePassword.backgroundColor = cgCustomBlue
        passwordTextField.borderStyle = UITextField.BorderStyle.none
        passwordTextField.layer.addSublayer(bottomLinePassword)
                
	}
	
	@objc func dismissKeyboard(){
		view.endEditing(true)
	}
	
    @IBAction func RegisterPressed(_ sender: UIButton) {
		
		loginVC.animateButton(sender)
                
        if let email = emailTextField.text, let password = passwordTextField.text{
        
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    self.errorLable.alpha = 1
                    self.errorLable.text = e.localizedDescription
                } else {
					
					authResult?.user.sendEmailVerification(completion: nil)
                    // go to the homepage
					let vc = self.storyboard?.instantiateViewController(identifier: "verify") as! VerifyViewController
					
					
					self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    @IBAction func unwindToSignUpViewCotnroller(_ unwindSegue: UIStoryboardSegue) { }
}
