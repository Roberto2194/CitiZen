//
//  JoinChallengeViewController.swift
//  citZen
//
//  Created by Luigi Mazzarella on 26/05/2020.
//  Copyright © 2020 Luigi Mazzarella. All rights reserved.
//

import UIKit
import Firebase

class JoinChallengeViewController: UIViewController {
	
	
	@IBOutlet weak var ChallengeImg: UIImageView!
	@IBOutlet weak var profileImg: UIImageView!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var stackView: UIStackView!
	@IBOutlet weak var rewordLabel: UILabel!
	@IBOutlet weak var joinStyle: UIButton!
	@IBOutlet weak var completeButton: UIButton!
	@IBOutlet weak var joinbutton: UIButton!
	@IBOutlet weak var joinOut: UIButton!
	@IBOutlet weak var expiredLabel: UILabel!
	@IBOutlet weak var userTypeLabel: UILabel!
	@IBOutlet weak var userNameLabel: UILabel!
	@IBOutlet weak var peopleJoinedNumber: UILabel!
	@IBOutlet weak var topicImageView: UIImageView!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var benefitField: UILabel!
	@IBOutlet weak var JoinInDeleteStack: UIStackView!
	@IBOutlet weak var JoinOutCompleteStack: UIStackView!
	
	@IBOutlet weak var badge1: UIImageView!
	@IBOutlet weak var badge2: UIImageView!
	@IBOutlet weak var badge3: UIImageView!
	@IBOutlet weak var badge4: UIImageView!
	@IBOutlet weak var badge5: UIImageView!
	
	let loginVC = LoginViewController()
	
	var challengeUID: Challenge!
	var nation: String?
	var imIn = false
	var complete = false
	var join = false
	
	var completeView = false
	var isExpired = false
	
	var deletButtonOK = true
	var justComplete = false
	var fromProfile = false
	
	let refDatabase = Database.database().reference()
	
	@IBOutlet weak var deletButton: UIButton!
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		let tap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(goProfile))
		profileImg.addGestureRecognizer(tap)
		
		overrideUserInterfaceStyle = .light 
		
		
		print("CompleteView \(completeView)")
		profileImg.layer.cornerRadius = 47
		profileImg.layer.borderWidth = 3
		profileImg.layer.borderColor = UIColor.white.cgColor
		profileImg.clipsToBounds = true
		
		//Non appena abbiamo le immagini dei badges per ogni topic è da scommentare
		loadBadges()
		
		if justComplete {
			
			joinbutton.isHidden = join
			JoinInDeleteStack.isHidden = join
			JoinOutCompleteStack.isHidden = true
			completeButton.isHidden = complete
			joinOut.isHidden = complete
			self.deletButton.isHidden = true
			self.expiredLabel.isHidden = true
		}else {
			joinbutton.isHidden = join
			JoinInDeleteStack.isHidden = join
			JoinOutCompleteStack.isHidden = complete
			completeButton.isHidden = complete
			joinOut.isHidden = complete
			self.deletButton.isHidden = true
			self.expiredLabel.isHidden = true
		}
		
		
		
		
		self.refDatabase.child("Challenge").child(self.nation!).child(self.challengeUID.challengeUid!).observeSingleEvent(of: .value , with: { snapshot  in
			
			guard let values = snapshot.value as? [String:AnyObject] else {return}
			
			if values["isOK"] as? String == "false" {
				
				if self.fromProfile {
					
					self.JoinInDeleteStack.isHidden = false
					self.JoinOutCompleteStack.isHidden = true
					self.expiredLabel.isHidden = false
					self.deletButton.isHidden = true
					self.joinbutton.isHidden = true
					self.descriptionLabel.isHidden = false
					self.joinOut.isHidden = true
					self.completeButton.isHidden = true
					self.rewordLabel.isHidden = true
					self.imIn = true
				}
				else{
					self.JoinInDeleteStack.isHidden = false
					self.JoinOutCompleteStack.isHidden = true
					self.expiredLabel.isHidden = false
					self.deletButton.isHidden = false
					self.joinbutton.isHidden = true
					self.descriptionLabel.isHidden = false
					self.joinOut.isHidden = true
					self.completeButton.isHidden = true
					self.rewordLabel.isHidden = true
					self.imIn = true
				}
				
				
			}
			else {
				self.expiredLabel.isHidden = true
				self.deletButton.isHidden = true
				self.joinStyle.setTitle("Join Out", for: .normal)
				self.imIn = true
				
				self.refDatabase.child("UserProfile").child(Auth.auth().currentUser!.uid).child("Challenge").child(self.nation!).child(self.challengeUID.challengeUid!).observeSingleEvent(of: .value, with: { snapshot in
					
					if snapshot.childrenCount == 0{
						self.joinStyle.setTitle("Join In", for: .normal)
						self.imIn = false
						self.deletButton.isHidden = true
						self.expiredLabel.isHidden = true
					}else{
						
						guard let dic = snapshot.value as? [String:AnyObject] else{return}
						
						print("CompleteFrom \(String(describing: dic["complete"] as? String))")
						
						if dic["complete"] as? String == "true" {
							
							self.joinbutton.isHidden = self.join
							self.JoinInDeleteStack.isHidden = self.join
							self.JoinOutCompleteStack.isHidden = true
							self.completeButton.isHidden = self.complete
							self.joinOut.isHidden = self.complete
							self.deletButton.isHidden = true
							self.expiredLabel.isHidden = true
							
						}
					}
				})
			}
			
		})

		load()

		
	}
	
	
	
	
	func loadBadges() {
		let badges: [UIImageView] = [badge1, badge2, badge3, badge4, badge5]
		let tempTopic = challengeUID.topic
		//        let points = Int(challengeUID.points ?? "0")
		var imageName = ""
		switch tempTopic {
			case "water":
				imageName = "waterBadge"
			case "mobility":
				imageName = "mobilityBadge"
			case "waste":
				imageName = "wasteBadge"
			case "energy":
				imageName = "energyBadge"
			case "food":
				imageName = "foodBadge"
			case "digital":
				imageName = "digitalBadge"
			default:
				fatalError("Did not found topic")
		}
		//        let badgeImage = UIImage(named: imageName)
		//        var point = 0
		for badge in 0 ..< badges.count {
			//            if point < points! {
			//                badges[badge].image = badgeImage
			//                point += 1
			//            } else {
			//                return
			//            }
			badges[badge].image = UIImage(named: imageName)
		}
		
	}
	
	
	@objc func goProfile(){
		
		if challengeUID.uidCreator == Auth.auth().currentUser!.uid {
			
			guard let vc = storyboard?.instantiateViewController(identifier: "Home") as? HomeViewController else {return}
			tabBarController?.selectedIndex = 2
			print("TableView sono qui")
			navigationController?.pushViewController(vc, animated: true)
			navigationController?.popViewController(animated: true)
		} else {
			
			guard let vc = storyboard?.instantiateViewController(identifier: "follower") as? ProfileUserViewController else { return  }
			
			guard let vc2 = storyboard?.instantiateViewController(identifier: "joined") as? AchieveProfileViewController else { return  }
			
			vc.uid = challengeUID.uidCreator
			vc2.uid = challengeUID.uidCreator
			
			
			navigationController?.pushViewController(vc, animated: true)
		}
	}
	
	
	func load() {
		
		ChallengeImg.image =  challengeUID.challengeImg
		ChallengeImg.contentMode = .scaleAspectFill
		profileImg.image = challengeUID.profileImg
		profileImg.contentMode = .scaleAspectFill
		titleLabel.text = challengeUID.title
		descriptionLabel.text = challengeUID.descriptionAction
		rewordLabel.text = challengeUID.points
		dateLabel.text = challengeUID.date
		benefitField.text = challengeUID.benefit
		userNameLabel.text = challengeUID.nameUser
		userTypeLabel.text = challengeUID.typeUser
		peopleJoinedNumber.text = challengeUID.challengeNumber
	}
	
	let customGreen = UIColor(red: 0, green: 0.7529, blue: 0.3451, alpha: 1.0)
	let customBlue = UIColor(red: 0.2157, green: 0.2118, blue: 0.2941, alpha: 1.0)
	
	@IBAction func joinIn(_ sender: UIButton) {
		
		loginVC.animateButton(sender)
		
		if !imIn {
			refDatabase.child("Challenge").child(nation!).child(challengeUID.challengeUid!).child("Users").child(Auth.auth().currentUser!.uid).setValue([
				"uidUser": Auth.auth().currentUser?.uid
			])
			refDatabase.child("UserProfile").child(Auth.auth().currentUser!.uid).child("Challenge").child(nation!).child(challengeUID.challengeUid!).setValue([
				"uidChallenge": challengeUID.challengeUid
			])
			
			sender.setTitle("Join Out", for: .normal)
			sender.backgroundColor = customBlue
			self.imIn = true
			
		}else{
			refDatabase.child("Challenge").child(nation!).child(challengeUID.challengeUid!).child("Users").child(Auth.auth().currentUser!.uid).removeValue()
			refDatabase.child("UserProfile").child(Auth.auth().currentUser!.uid).child("Challenge").child(nation!).child(challengeUID.challengeUid!).removeValue()
			
			sender.setTitle("Join In", for: .normal)
			sender.backgroundColor = customGreen
			self.imIn = false
		}
	}
	
	
	
	@IBAction func completeButton(_ sender: UIButton) {
		
		loginVC.animateButton(sender)
		
		let vc = storyboard?.instantiateViewController(identifier: "complete") as! CompleteTableViewController
		vc.challenge = challengeUID
		vc.nation = self.nation
		
		navigationController?.pushViewController(vc, animated: true)
	}
	
	@IBAction func joinOut(_ sender: UIButton) {
		
		loginVC.animateButton(sender)
		
		refDatabase.child("Challenge").child(nation!).child(challengeUID.challengeUid!).child("Users").child(Auth.auth().currentUser!.uid).removeValue()
		refDatabase.child("UserProfile").child(Auth.auth().currentUser!.uid).child("Challenge").child(nation!).child(challengeUID.challengeUid!).removeValue()
		
		self.imIn = false
		
		navigationController?.popViewController(animated: true)
	}
	
	
	@IBAction func deleteButtonAction(_ sender: UIButton) {
		
		loginVC.animateButton(sender)
		
		refDatabase.child("UserProfile").child(Auth.auth().currentUser!.uid).child("Challenge").child(nation!).child(challengeUID.challengeUid!).removeValue()
		refDatabase.child("Challenge").child(nation!).child(challengeUID.challengeUid!).child("Users").child(Auth.auth().currentUser!.uid).removeValue()
		self.imIn = false
		navigationController?.popViewController(animated: true)
		
	}
	
	@IBAction func unwindToJoinChallengeViewController(_ unwindSegue: UIStoryboardSegue) { }
	
}
