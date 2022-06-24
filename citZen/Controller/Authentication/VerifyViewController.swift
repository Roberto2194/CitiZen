//
//  VerifyViewController.swift
//  citZen
//
//  Created by Luigi Mazzarella on 30/05/2020.
//  Copyright © 2020 Luigi Mazzarella. All rights reserved.
//

import UIKit
import Firebase

class VerifyViewController: UIViewController {
    
    var vSpinner : UIView?
    let refDatabase = Database.database().reference().child("UserProfile")
    
    var found: Bool!
    var count = 0
    
	@IBOutlet weak var leaf: UIImageView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		overrideUserInterfaceStyle = .light 
		
		if Auth.auth().currentUser!.isEmailVerified {
			checkData()
		}else {

			let vc = storyboard?.instantiateViewController(identifier: "email") as! EmailVerificationViewController
			
			navigationController?.pushViewController(vc, animated: true)
			

		}
		animateLeaf()
		
    }

	
    func checkData() {
        refDatabase.queryOrderedByKey().queryEqual(toValue: Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { snapshot in



            if snapshot.childrenCount == 0 {
                let vc = self.storyboard?.instantiateViewController(identifier: "Profile") as? ProfileCreateViewController
                self.navigationController?.pushViewController(vc!, animated: true)
            }else {
                let tab = self.storyboard?.instantiateViewController(withIdentifier: "TabBar") as? UITabBarController


                self.navigationController?.pushViewController(tab!, animated: true)
        }


        }, withCancel: nil)
    }
    
    
    
}

extension VerifyViewController {
    

	
	func animateLeaf() {
		UIView.animate(withDuration: 5, delay: 0, usingSpringWithDamping: 0, initialSpringVelocity: 0, options: .curveLinear, animations: {
			let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
			rotateAnimation.speed = 0.5
			rotateAnimation.fromValue = 0.0
			rotateAnimation.toValue = CGFloat(Double.pi * 2)
			rotateAnimation.isRemovedOnCompletion = false
			rotateAnimation.repeatCount = Float.infinity
			self.leaf.layer.add(rotateAnimation, forKey: nil)
		})
	}
    
    

}

