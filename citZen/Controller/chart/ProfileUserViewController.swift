//
//  ProfileUserViewController.swift
//  citZen
//
//  Created by Luigi Mazzarella on 24/05/2020.
//  Copyright © 2020 Luigi Mazzarella. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class ProfileUserViewController: UIViewController {
	
	@IBOutlet weak var imageProfile: UIImageView!
	@IBOutlet weak var labelNickname: UILabel!
	@IBOutlet weak var nFollowers: UILabel!
	@IBOutlet weak var NameLabel: UILabel!
	@IBOutlet weak var nFollowing: UILabel!
	@IBOutlet weak var buttonStyle: UIButton!
	@IBOutlet weak var SurnameLabel: UILabel!
	@IBOutlet weak var segmentedControll: UISegmentedControl!
	@IBOutlet weak var joinedContainer: UIView!
	@IBOutlet weak var cretedContainer: UIView!
    @IBOutlet weak var rewardsContainer: UIView!
    @IBOutlet weak var followersView: UIView!
	@IBOutlet weak var followingView: UIView!
	@IBOutlet weak var userType: UILabel!
	
	@IBOutlet weak var level1: UIImageView!
	@IBOutlet weak var level2: UIImageView!
	@IBOutlet weak var level3: UIImageView!
	@IBOutlet weak var level4: UIImageView!
	@IBOutlet weak var level5: UIImageView!

	
	let refDatabase = Database.database().reference()
	let refStorage = Storage.storage().reference()
	
	var uid: String?
	var follow = false
	
	let customGreen = UIColor(red: 0, green: 0.7529, blue: 0.3451, alpha: 1.0) /* #00c058 */
	let cgCustomBlue = CGColor(srgbRed: 0.2157, green: 0.2118, blue: 0.2941, alpha: 1.0) /* #37364b */
	
	override func viewDidLoad() {
		super.viewDidLoad()
		overrideUserInterfaceStyle = .light 
        
        title = "Profile"
				
		followersView.layer.borderWidth = 1
		followersView.layer.borderColor = customGreen.cgColor
		
		followingView.layer.borderWidth = 1
		followingView.layer.borderColor = customGreen.cgColor
		
		followersView.layer.cornerRadius = 10
		followersView.layer.masksToBounds = true
		
		followingView.layer.cornerRadius = 10
		followingView.layer.masksToBounds = true
		
		imageProfile.layer.borderWidth = 2
        imageProfile.layer.borderColor = customGreen.cgColor
        
        segmentedControll.selectedSegmentTintColor = .white
        let customBlue = UIColor(red: 0.2157, green: 0.2118, blue: 0.2941, alpha: 1.0) /* #37364b */
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        segmentedControll.setTitleTextAttributes(titleTextAttributes, for:.normal)
        let titleTextAttributes1 = [NSAttributedString.Key.foregroundColor: customBlue]
        segmentedControll.setTitleTextAttributes(titleTextAttributes1, for:.selected)
        
	}
    
	
	@IBAction func segmentedControll(_ sender: UISegmentedControl) {
		
		switch sender.selectedSegmentIndex {
			case 0:
				self.cretedContainer.isHidden = true
				self.joinedContainer.isHidden = false
                self.rewardsContainer.isHidden = true
			case 1:
				self.cretedContainer.isHidden = false
				self.joinedContainer.isHidden = true
                self.rewardsContainer.isHidden = true
            case 2:
                self.cretedContainer.isHidden = true
                self.joinedContainer.isHidden = true
                self.rewardsContainer.isHidden = false
			default:
				break
			
		}
	}
	
	override func viewWillAppear(_ animated: Bool)  {
        super.viewWillAppear(animated)
		
		switch segmentedControll.selectedSegmentIndex {
			case 0:
				self.cretedContainer.isHidden = true
				self.joinedContainer.isHidden = false
			case 1:
				self.cretedContainer.isHidden = false
				self.joinedContainer.isHidden = true
			default:
				break
			
		}
		print("PROFILOUTENTE uid \(uid!)")
		loadData()
		
		
		refDatabase.child("UserProfile").child(Auth.auth().currentUser!.uid).child("followed").child(uid!).observeSingleEvent(of: .value, with: { snapshot in
			
			print("followerButton \(snapshot.childrenCount)")
			
			if snapshot.childrenCount == 0{
				self.follow = false
				
				self.buttonStyle.setTitle("Follow", for: .normal)
				
				
				
			}else {
				self.follow = true
				self.buttonStyle.setTitle("Unfollow", for: .normal)
			}
		})
		
		
    }
  
	func loadData(){
		
		refStorage.child("ProfileImage").child(uid!).getData(maxSize: 1*1024*1024) { data, error in
			
			if error != nil {
				print(error!)
			}else {
				
				self.imageProfile.image = UIImage(data: data!)
				self.imageProfile.contentMode = .scaleAspectFill
				self.refDatabase.child("UserProfile").child(self.uid!).observeSingleEvent(of: .value, with: { snapshot in
					
					if let dictionary = snapshot.value as? [String: AnyObject] {
						
						
						let name = dictionary["name"] as? String
						let surname = dictionary["surname"] as? String
						let stringPoints = dictionary["points"] as? String
						
						self.userType.text = dictionary["Type"] as? String

						self.NameLabel.text = "\(name!) \(surname!)"
						
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
						
						
						self.refDatabase.child("UserProfile").child(self.uid!).child("follower").observe(.value, with: { snapshot in
							
							self.nFollowers.text = String(snapshot.childrenCount)
						})
						self.refDatabase.child("UserProfile").child(self.uid!).child("followed").observe(.value, with: { snapshot in
							
							self.nFollowing.text = String(snapshot.childrenCount)
						})
					}
				})
			}
			
		}
	
		
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination as? AchieveProfileViewController, segue.identifier == "joined" {
			vc.uid = uid
		}
		if let vc2 = segue.destination as? CreatedViewController, segue.identifier == "created" {
			vc2.uid = uid
		}
		if let vc3 = segue.destination as? ChartRewardsViewController, segue.identifier == "rewards" {
			vc3.uid = uid
		}
	}
	
	@IBAction func followerButton(_ sender: UIButton) {
		
	
			if !follow {
				
				self.refDatabase.child("UserProfile").child(Auth.auth().currentUser!.uid).child("followed").child(uid!).setValue([
					"uid": uid!
				])
				
				self.refDatabase.child("UserProfile").child(uid!).child("follower").child(Auth.auth().currentUser!.uid).setValue([
					"uid": Auth.auth().currentUser?.uid
				])
				
								
				sender.setTitle("Unfollow", for: .normal)
				follow = true
				
			}else {
				
				self.refDatabase.child("UserProfile").child(Auth.auth().currentUser!.uid).child("followed").child(uid!).removeValue()
				
				self.refDatabase.child("UserProfile").child(uid!).child("follower").child(Auth.auth().currentUser!.uid).removeValue()
				
				
				sender.setTitle("Follow", for: .normal)
				follow = false
			}
		
	}
	

}
