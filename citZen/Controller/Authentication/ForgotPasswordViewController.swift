//
//  ForgotPasswordViewController.swift
//  citZen
//
//  Created by Roberto Liccardo on 04/06/2020.
//  Copyright © 2020 Luigi Mazzarella. All rights reserved.
//

import UIKit
import Firebase

class ForgotPasswordViewController: UIViewController {

	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var errorLabel: UILabel!
	@IBOutlet weak var sentLabel: UILabel!
	
	let loginVC = LoginViewController()
	
	override func viewDidLoad() {
        super.viewDidLoad()
		overrideUserInterfaceStyle = .light 
		let cgCustomBlue = CGColor(srgbRed: 0.2157, green: 0.2118, blue: 0.2941, alpha: 1.0) /* #37364b */
		
		//Customizes the text fields
		let bottomLineEmail = CALayer()
		bottomLineEmail.frame = CGRect(x: 0.0, y: textField.frame.height - 10, width: textField.frame.width, height: 1.0)
		bottomLineEmail.backgroundColor = cgCustomBlue
		textField.borderStyle = UITextField.BorderStyle.none
		textField.layer.addSublayer(bottomLineEmail)
		
		errorLabel.isHidden = true
		sentLabel.isHidden = true
    }
    
	@IBAction func buttonPressed(_ sender: UIButton) {
		
		loginVC.animateButton(sender)
		
		if textField.text != nil {
			
			Auth.auth().fetchSignInMethods(forEmail: textField.text!, completion: { list, error in
				
				if error != nil {
					return
				}
				
				
				if list == nil {
					let alert = UIAlertController(title: "Error", message: "This email did not register", preferredStyle: .alert)
					alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))


					self.present(alert, animated: true, completion: nil)
					self.errorLabel.isHidden = false
					self.sentLabel.isHidden = true
				} else {
					Auth.auth().sendPasswordReset(withEmail: self.textField.text!, completion: nil)
					let alert = UIAlertController(title: "Email", message: "We sent email with a link to change password", preferredStyle: .alert)
					alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

					self.present(alert, animated: true)
					
					self.errorLabel.isHidden = true
					self.sentLabel.isHidden = false
				}
				
				
			})
		}

	}
	
	
	
}
