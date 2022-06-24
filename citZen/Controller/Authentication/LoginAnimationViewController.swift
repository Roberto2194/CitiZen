//
//  LoginAnimationViewController.swift
//  citZen
//
//  Created by Roberto Liccardo on 09/06/2020.
//  Copyright © 2020 Luigi Mazzarella. All rights reserved.
//

import UIKit
import Firebase

class LoginAnimationViewController: UIViewController {
	
	@IBOutlet weak var leaf: UIImageView!
    @IBOutlet weak var omino: UIImageView!
    
    var firstTime: Bool = false
	var login: Bool = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		animateLeaf()
		
		if Auth.auth().currentUser?.uid != nil{
			perform(#selector(goForward))
		}
		
        firstTime = UserDefaults.standard.bool(forKey: "firstTime")
	
	}
	
	
	
	@objc func goForward(){
		let vc = self.storyboard?.instantiateViewController(identifier: "verify") as! VerifyViewController
		
		
		self.navigationController?.pushViewController(vc, animated: true)
	}
	
	func animateLeaf() {
        UIView.animate(withDuration: 5, delay: 0, options: .curveEaseIn, animations: {
			let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotateAnimation.speed = 0.5
            rotateAnimation.fromValue = 0.0
            rotateAnimation.toValue = CGFloat(Double.pi * 2)
            rotateAnimation.isRemovedOnCompletion = false
            rotateAnimation.repeatCount = Float.infinity
			self.leaf.layer.add(rotateAnimation, forKey: nil)
        }, completion: nil)
	}
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // "+2" are the seconds it waits to execute the code
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if self.firstTime == true {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LogIn") as! LoginViewController
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                UserDefaults.standard.set(true, forKey: "firstTime")
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "OnBoarding") as! OnBoardingViewController
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

	
	
}
