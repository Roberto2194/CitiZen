//
//  JoinedViewController.swift
//  citZen
//
//  Created by Luigi Mazzarella on 28/05/2020.
//  Copyright © 2020 Luigi Mazzarella. All rights reserved.
//

import UIKit
import Firebase

//This is Achieved then we have to change this name
class AchieveProfileViewController: UIViewController {

	let refUser = Database.database().reference().child("UserProfile")
	let refChallenge = Database.database().reference().child("Challenge")
	let refStorage = Storage.storage().reference()
	
	var uid: String?
	var challengeID: [String] = []
	var nation: String?
	var challengeItems: [Challenge] = []
	
	var vSpinner : UIView?
	var refreshControl = UIRefreshControl()
	
	@IBOutlet weak var table: UITableView!
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		 
		overrideUserInterfaceStyle = .light 
		showSpinner(onView: self.view)
		refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
		refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
		table.addSubview(refreshControl)
		
		print("Joined uid \(uid!)")
		loadUserInfo()
		
	}
	@objc func refresh(_ sender: AnyObject) {
		// Code to refresh table view
		self.challengeItems.removeAll()
		table.reloadData()
		loadUserInfo()
		self.removeSpinner()
	}
    
	func loadUserInfo(){
		refUser.child(uid!).observeSingleEvent(of: .value, with: { snapshot in
			
			guard let dictionary = snapshot.value as? [String: AnyObject] else {
				return
			}
			
			
			self.nation = dictionary["Location"] as? String
			self.achievedChallenge()
		})
		
	}
	
	func achievedChallenge() {
		
		refUser.child(uid!).child("Challenge").child(self.nation!).queryOrdered(byChild: "complete").queryEqual(toValue: "true").observeSingleEvent(of: .value, with: { snapshot in
			
			
			print("ACHIEVE CONTENGO \(snapshot.childrenCount)")
			
			if snapshot.childrenCount == 0{
				self.refreshControl.endRefreshing()
				self.removeSpinner()
			}
			
			for child in snapshot.children {
				
				guard let snap2 = child as? DataSnapshot else {return}
				
				self.refChallenge.child(self.nation!).child(snap2.key).observeSingleEvent(of: .value, with: {
					snap in
					
					guard let dictionary  = snap.value as? [String:AnyObject] else {return}
					
					let challenge = Challenge()
					
					
					challenge.title = dictionary["title"] as? String
					challenge.topic = dictionary["topic"] as? String
					
					self.refStorage.child("ChallengeComplete").child(self.uid!).child(snap2.key).getData(maxSize: 1*1024*1024) { data, error in
						
						if error != nil {
							print(error!)
							return
						}
						
						challenge.challengeImgComplete = UIImage(data: data!)
						self.addChallenge(challenge: challenge)
						
						DispatchQueue.main.async {
							self.refreshControl.endRefreshing()
							self.removeSpinner()
							self.table.reloadData()
							
							
						}
						
						
						
					}

				})
				
			}
			
		})
		
		
	}
	
	func takeChallengeID(nation: String) {
		
		refUser.child(uid!).child("Challenge").child(nation).observeSingleEvent(of: .value, with: { snap in
			
			
			print("Joined snap \(snap)")
			for child in snap.children {
				print("Joined \(child)")
				
				let snapshot2 = child as? DataSnapshot
				guard let element = snapshot2?.value as? [String: AnyObject] else {return}
				element.forEach({ key, value in
					
					print("Achieve in child key \(key) e value \(value)")
					if key == "uidChallenge" {
						self.addID(id: (value as? String)!)
						
					}
					
				})
			}
			
			self.loadChallenge(idChallenge: self.challengeID)
		})
		
	}
	
	func addID(id: String){
		challengeID.append(id)
	}
	
	func loadChallenge(idChallenge: [String]){
		
		
		if idChallenge.count == 0 {
			
			removeSpinner()
		}
		for id in idChallenge {
			refChallenge.child(self.nation!).child(id).observeSingleEvent(of: .value, with: { snapshot in
				
				guard let dictionary = snapshot.value as? [String: AnyObject] else {return}
				
				let challege = Challenge()
				challege.title = dictionary["title"] as? String
				challege.descriptionAction = dictionary["descriptioAction"] as? String
				self.refStorage.child("Challenge").child(self.nation!).child(id).getData(maxSize: 1*1024*1024) { data,error in
					
					if error != nil {
						return
					}
					print("Joined sono qui")
					challege.challengeImg = UIImage(data: data!)
					self.refStorage.child("ProfileImage").child(self.uid!).getData(maxSize: 1*1024*1024) { data, error in
						
						if error != nil {
							return
						}
						challege.profileImg = UIImage(data: data!)
						self.addChallenge(challenge: challege)
						self.removeSpinner()
						self.refreshControl.endRefreshing()
						self.table.reloadData()
					}
				}
				
				
				
			})
		}
		
	}
	
	func addChallenge(challenge: Challenge){
		
		challengeItems.append(challenge)
	}
	


}


extension AchieveProfileViewController: UITableViewDelegate,UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return challengeItems.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "joined") as! JoinedTableViewCell
        
        cell.layer.borderWidth = 5.0
        cell.layer.borderColor = UIColor.clear.cgColor
        cell.internalCellView.layer.cornerRadius = 35.0
        cell.internalCellView.layer.borderWidth = 4.0
        cell.internalCellView.layer.borderColor = UIColor.clear.cgColor
        cell.internalCellView.layer.masksToBounds = true
        cell.externalCellView.layer.shadowColor = UIColor.gray.cgColor
        cell.externalCellView.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        cell.externalCellView.layer.shadowRadius = 6.0
        cell.externalCellView.layer.shadowOpacity = 0.5
        cell.externalCellView.layer.cornerRadius = 35.0
        cell.externalCellView.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.internalCellView.layer.bounds, cornerRadius: cell.externalCellView.layer.cornerRadius).cgPath
        
        
		
		let challengeTopic = challengeItems[indexPath.row].topic
        var topicImage = ""
        switch challengeTopic {
            case "water":
                topicImage = "cardWater2"
            case "waste":
                topicImage = "cardWaste2"
            case "energy":
                topicImage = "cardEnergy2"
            case "mobility":
                topicImage = "cardMobility2"
            case "digital":
                topicImage = "cardDigital2"
            case "food":
                topicImage = "cardFood2"
            default:
                topicImage = "cardDefault2"
        }
        cell.cardFooter.image = UIImage(named: topicImage)
        
		cell.layer.borderWidth = 0.3
		cell.challengeImg.image = challengeItems[indexPath.row].challengeImgComplete
		cell.challengeImg.contentMode = .scaleAspectFill
		cell.progileImg.image = challengeItems[indexPath.row].profileImg
		cell.progileImg.contentMode = .scaleAspectFill
		cell.titleLabel.text = challengeItems[indexPath.row].title
		cell.descriptionLabel.text = challengeItems[indexPath.row].descriptionAction
	
		return cell
	}
	
}



extension AchieveProfileViewController {
	
	func showSpinner(onView : UIView) {
		let spinnerView = UIView.init(frame: onView.bounds)
		spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
		let ai = UIActivityIndicatorView.init(style: .large)
		ai.startAnimating()
		ai.center = spinnerView.center
		
		DispatchQueue.main.async {
			spinnerView.addSubview(ai)
			onView.addSubview(spinnerView)
		}
		
		vSpinner = spinnerView
	}
	
	func removeSpinner() {
		DispatchQueue.main.async {
			self.vSpinner?.removeFromSuperview()
			self.vSpinner = nil
		}
	}
}
