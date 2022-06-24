//
//  HiomeViewController.swift
//  citZen
//
//  Created by Luigi Mazzarella on 18/05/2020.
//  Copyright © 2020 Luigi Mazzarella. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class HomeViewController: UIViewController {

	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var surnameLable: UILabel!
	@IBOutlet weak var profileImage: UIImageView!
	@IBOutlet weak var nFollower: UILabel!
	@IBOutlet weak var nFollowing: UILabel!
	@IBOutlet weak var viewChallenge: UIView!
	@IBOutlet weak var viewAchieved: UIView!
	@IBOutlet weak var viewReward: UIView!
    @IBOutlet weak var userType: UILabel!
    @IBOutlet weak var followersView: UIView!
    @IBOutlet weak var followingView: UIView!
    
    
    @IBOutlet weak var level1: UIImageView!
    @IBOutlet weak var level2: UIImageView!
    @IBOutlet weak var level3: UIImageView!
    @IBOutlet weak var level4: UIImageView!
    @IBOutlet weak var level5: UIImageView!
    
	@IBOutlet weak var segmented: UISegmentedControl!
	
	let user = User()
	
	let refDatabase = Database.database().reference()
	let refStorage = Storage.storage().reference().child("ProfileImage")
	
	var image: UIImage?
	
	var authResult: AuthDataResult!
    
    let customGreen = UIColor(red: 0, green: 0.7529, blue: 0.3451, alpha: 1.0) /* #00c058 */
    let customBlue = UIColor(red: 0.2157, green: 0.2118, blue: 0.2941, alpha: 1.0) /* #37364b */
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		overrideUserInterfaceStyle = .light 

		checkLogInUser()
		viewReward.isHidden = true
		viewAchieved.isHidden = true
		viewChallenge.isHidden = false
		
		let tap: UIGestureRecognizer = UITapGestureRecognizer(target: self , action: #selector(goFollower))
		followersView.addGestureRecognizer(tap)
		followersView.isUserInteractionEnabled = true
		
		let tap2: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(goFollowed))
		followingView.addGestureRecognizer(tap2)
		followingView.isUserInteractionEnabled = true
		
		
		LoadData()
        
        
                    
            followersView.layer.borderWidth = 1
            followersView.layer.borderColor = customGreen.cgColor
            
            followingView.layer.borderWidth = 1
            followingView.layer.borderColor = customGreen.cgColor
            
            followersView.layer.cornerRadius = 10
            followersView.layer.masksToBounds = true
            
            followingView.layer.cornerRadius = 10
            followingView.layer.masksToBounds = true
            
            profileImage.layer.borderWidth = 2
        profileImage.layer.borderColor = customGreen.cgColor
		
		
		segmented.selectedSegmentTintColor = .white
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        segmented.setTitleTextAttributes(titleTextAttributes, for:.normal)
        let titleTextAttributes1 = [NSAttributedString.Key.foregroundColor: customBlue]
        segmented.setTitleTextAttributes(titleTextAttributes1, for:.selected)

    }
    
	
	@objc func goFollower() {
		
		let vc = storyboard?.instantiateViewController(identifier: "FollowVC") as! FollowViewController
		
		vc.type = "follower"
        vc.title = "Followers"
		
		navigationController?.pushViewController(vc, animated: true)
	}
	
	@objc func goFollowed() {
		
		let vc = storyboard?.instantiateViewController(identifier: "FollowVC") as! FollowViewController
		
		vc.type = "followed"
        vc.title = "Following"
		
		navigationController?.pushViewController(vc, animated: true)
	}
    

	func checkLogInUser(){
		if Auth.auth().currentUser?.uid == nil{
			perform(#selector(logOutFunciont))
		}
		user.uid = Auth.auth().currentUser?.uid
		
	}
	
	
	func LoadData() {
		
		let refUser = refDatabase.child("UserProfile").child(user.uid!)
		refUser.observe(.value, with: { snapshot in
			if let dictionary = snapshot.value as? [String:AnyObject] {
				let name = dictionary["name"] as? String
				let surname = dictionary["surname"] as? String
				
				self.user.name = "\(name!) \(surname!)"
				self.user.profileLinkImg = dictionary["ProfileUrl"] as? String
				let stringPoints = dictionary["points"] as? String
				
				
				self.nameLabel.text = self.user.name!
				
				self.userType.text = (dictionary["Type"] as? String)!
				
				let points: Int = Int(stringPoints!)!
				
				
				switch  points {
					case 0 ... 9:
						self.level1.image = UIImage(named: "level_empty")
						self.level2.image = UIImage(named: "level_empty")
						self.level3.image = UIImage(named: "level_empty")
						self.level4.image = UIImage(named: "level_empty")
						self.level5.image = UIImage(named: "level_empty")
					case 10 ... 29:
						self.level1.image = UIImage(named: "level_fill")
						self.level2.image = UIImage(named: "level_empty")
						self.level3.image = UIImage(named: "level_empty")
						self.level4.image = UIImage(named: "level_empty")
						self.level5.image = UIImage(named: "level_empty")
					
					case 30 ... 49:
						self.level1.image = UIImage(named: "level_fill")
						self.level2.image = UIImage(named: "level_fill")
						self.level3.image = UIImage(named: "level_empty")
						self.level4.image = UIImage(named: "level_empty")
						self.level5.image = UIImage(named: "level_empty")
					case 50 ... 79:
						self.level1.image = UIImage(named: "level_fill")
						self.level2.image = UIImage(named: "level_fill")
						self.level3.image = UIImage(named: "level_fill")
						self.level4.image = UIImage(named: "level_empty")
						self.level5.image = UIImage(named: "level_empty")
					case 80 ... 119:
						self.level1.image = UIImage(named: "level_fill")
						self.level2.image = UIImage(named: "level_fill")
						self.level3.image = UIImage(named: "level_fill")
						self.level4.image = UIImage(named: "level_fill")
						self.level5.image = UIImage(named: "level_empty")
					case 120... :
						self.level1.image = UIImage(named: "level_fill")
						self.level2.image = UIImage(named: "level_fill")
						self.level3.image = UIImage(named: "level_fill")
						self.level4.image = UIImage(named: "level_fill")
						self.level5.image = UIImage(named: "level_fill")
					
					default:
						break
				}
			}
			
			self.refStorage.child(self.user.uid!).getData(maxSize: 1 * 1024 * 1024) { data, error in
				if error != nil {
					print(error!)
				} else {
					self.image = UIImage(data: data!)
					self.user.image = self.image
					self.profileImage.image = self.image
					self.profileImage.contentMode = .scaleAspectFill
				}
			}
			
			refUser.child("follower").observeSingleEvent(of: .value, with: { snapshot in
				
				self.nFollower.text = String(snapshot.childrenCount)
				
				
			})
			refUser.child("followed").observeSingleEvent(of: .value, with: { snapshot in
				self.nFollowing.text = String(snapshot.childrenCount)
			})
			
			
		})
		
	}
	
	@objc func logOutFunciont(){
		try! Auth.auth().signOut()
		
		if let storyboard = self.storyboard {
			let vc = storyboard.instantiateViewController(withIdentifier: "LogIn") as! LoginViewController
			self.navigationController?.setNavigationBarHidden(true, animated: true)
			self.tabBarController?.tabBar.isHidden = true
			self.navigationController?.pushViewController(vc, animated: true)
		}
	}
	

	
	@IBAction func segnmentedControll(_ sender: UISegmentedControl) {
		
		switch sender.selectedSegmentIndex {
			case 0:
				viewReward.isHidden = true
				viewAchieved.isHidden = true
				viewChallenge.isHidden = false
			case 1:
				viewReward.isHidden = true
				viewAchieved.isHidden = false
				viewChallenge.isHidden = true
			case 2:
				viewReward.isHidden = false
				viewAchieved.isHidden = true
				viewChallenge.isHidden = false
			default:
				break
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination as? ChallengeInProfileViewController, segue.identifier == "own" {
			
			
			vc.user = user
			
		}
	}

	
	@IBAction func setting(_ sender: UIButton) {
		
		guard let vc = storyboard?.instantiateViewController(identifier: "setting") as? SettingsTableViewController else { return  }
		
		navigationController?.pushViewController(vc, animated: true)
	}
	
}
