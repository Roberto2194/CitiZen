//
//  AchieveViewController.swift
//  citZen
//
//  Created by Luigi Mazzarella on 28/05/2020.
//  Copyright © 2020 Luigi Mazzarella. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class AchieveViewController: UIViewController {
	
	@IBOutlet weak var collection: UICollectionView!
	
	let refDatabase = Database.database().reference()
	let refStorage = Storage.storage().reference()
	let refUser = Database.database().reference().child("UserProfile").child(Auth.auth().currentUser!.uid)
	var challengeIdComplete: [String] = []
	var challengeItems: [Challenge] = []
	var myImg: UIImage?
	var nation: String?
	
	var refreshControl = UIRefreshControl()
	var vSpinner : UIView?
	
	
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		overrideUserInterfaceStyle = .light 
		
		showSpinner(onView: self.view)
		refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
		refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
		collection.addSubview(refreshControl)
		challengeItems = []
		challengeIdComplete = []
		
		collection.reloadData()
		loadNation()
	}
	
	
	@objc func refresh(_ sender: AnyObject) {
		challengeItems.removeAll()
		challengeIdComplete.removeAll()
		self.removeSpinner()
		loadNation()
		collection.reloadData()
	}
	
	
	func loadChallengeComplete(nation: String){
		
		
		refUser.child("Challenge").child(nation).queryOrdered(byChild: "complete").queryEqual(toValue: "true").observeSingleEvent(of: .value, with: { snap in
			
			self.challengeItems.removeAll()
			print("AchieveLoad \(snap.childrenCount)")
			
			if snap.childrenCount == 0 {
				self.removeSpinner()
			}
			else {
				
				for child in snap.children{
					
					guard let snap2 = child as? DataSnapshot else {return}
					
					guard let id = snap2.value as? [String:AnyObject] else {return}
					
                    self.addIdComplete(Id: (id["uidChallenge"] as? String)!)
					
				}
				
				print("AchieveLoad \(self.challengeIdComplete)")
				self.loadChallenge(Allid: self.challengeIdComplete)
			}
			
			
			
		}, withCancel: nil)
		
	}
	
	
	func loadNation(){
		refUser.observeSingleEvent(of: .value, with: { snapshot in
			
			
			self.challengeItems = []
			if let dictionary = snapshot.value as? [String: AnyObject] {
				self.nation = dictionary["Location"] as? String
				self.loadChallengeComplete(nation: self.nation!)
			}
		})
	}
	
	
	
	func addIdComplete(Id: String){
		
		challengeIdComplete.append(Id)
		
	}
	
	func loadChallenge(Allid: [String]){
		
		
		if Allid.count == 0 {
			self.refreshControl.endRefreshing()
			self.removeSpinner()
			return
		}
		
		for id in Allid {
			
			self.refDatabase.child("Challenge").child(self.nation!).child(id).observeSingleEvent(of: .value, with: { snapshot in
				
				
				
				if let dictionary = snapshot.value as? [String: AnyObject]{
					let challenge = Challenge()
					
					challenge.title = dictionary["title"] as? String
					challenge.descriptionAction = dictionary["descriptionAction"] as? String
					challenge.topic = dictionary["topic"] as? String
					
					self.refStorage.child("ChallengeComplete").child(Auth.auth().currentUser!.uid).child(id).getData(maxSize: 1*1024*1024){ data, error in
						
						if error != nil{
							print(error!)
							return
						}
                        
                        
						
						challenge.challengeImgComplete = UIImage(data: data!)
						self.addChallenge(challenge: challenge)
						DispatchQueue.main.async {
							
							self.removeSpinner()
							self.refreshControl.endRefreshing()
							self.collection.reloadData()
						}
						

						
						
					}
					
				}
			})
		}
		
	}
	
	func addChallenge(challenge: Challenge){
		
		challengeItems.append(challenge)
	}
	
	
}

extension AchieveViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return challengeItems.count
	}
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 40, height: collectionView.frame.width - 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 15, left: 0, bottom: 15, right: 0)
    }
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "achieve", for: indexPath) as! AchieveCollectionViewCell
		
        // cell rounded section
        cell.layer.borderWidth = 5.0
        cell.layer.borderColor = UIColor.clear.cgColor
        
        // cell shadow section
        cell.contentView.layer.cornerRadius = 35.0
        cell.contentView.layer.borderWidth = 30.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        cell.layer.shadowRadius = 6.0
        cell.layer.shadowOpacity = 0.6
        cell.layer.cornerRadius = 35.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        
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
        
		cell.ImageComplete.image = challengeItems[indexPath.row].challengeImgComplete
		cell.titleLabel.text = challengeItems[indexPath.row].title
		cell.topicLabel.text = challengeItems[indexPath.row].topic
		
		return cell
	}
	
	
}


extension AchieveViewController {
	
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
