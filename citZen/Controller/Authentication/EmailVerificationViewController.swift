//
//  EmailVerificationViewController.swift
//  citZen
//
//  Created by Roberto Liccardo on 05/06/2020.
//  Copyright © 2020 Luigi Mazzarella. All rights reserved.
//

import UIKit
import Firebase

class EmailVerificationViewController: UIViewController {
	
	let loginVC = LoginViewController()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		overrideUserInterfaceStyle = .light 
		//Do any additional setup when the view loads.
	}
	
	@IBAction func sendButtonPressed(_ sender: UIButton) {
		loginVC.animateButton(sender)
		
		Auth.auth().currentUser?.sendEmailVerification(completion: nil)
		
	}
	
	@IBAction func loginPressed(_ sender: UIButton) {
		if let storyboard = self.storyboard {
			let vc = storyboard.instantiateViewController(withIdentifier: "LogIn") as! LoginViewController
			self.navigationController?.pushViewController(vc, animated: true)
		}
	}
	
}
