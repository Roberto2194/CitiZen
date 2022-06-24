//
//  ChallengeInProfileViewController.swift
//  citZen
//
//  Created by Luigi Mazzarella on 27/05/2020.
//  Copyright © 2020 Luigi Mazzarella. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class ChallengeInProfileViewController: UIViewController {
    

    
    @IBOutlet weak var table: UITableView!
    
    let refDatabase = Database.database().reference()
    let refStorage = Storage.storage().reference()
    
    
    var challengeUID: [String] = []
    var challengeItems: [Challenge] = []
    var nation: String?
    
    var vSpinner : UIView?
    var refreshControl = UIRefreshControl()
	
	var user: User?
    
	override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		
		overrideUserInterfaceStyle = .light 
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        table.addSubview(refreshControl)
        
        showSpinner(onView: self.view)
        takeNation()
        
    }
    
    func takeNation(){
        
        refDatabase.child("UserProfile").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { snap in
            
            if let value = snap.value as? [String: AnyObject] {
                self.nation = value["Location"] as? String
                print("challenge sono nazione \(self.nation!)")
                self.loadCreatedChallenge()
                
            }
        })
    }
    
	
	func loadCreatedChallenge() {
		refDatabase.child("Challenge").child(nation!).queryOrdered(byChild: "uidCreator").queryEqual(toValue: Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { snap in
			self.challengeItems = []
			
			if snap.childrenCount == 0{
				self.refreshControl.endRefreshing()
				self.removeSpinner()
			}else {
				
				for child in snap.children {
					
				
					
					guard let snap2 = child as? DataSnapshot else {return}

					guard let dictionary = snap2.value as? [String:AnyObject] else {return}
					
					print("CreateProfile \(snap2.key)")


					let challenge = Challenge()

					challenge.title = dictionary["title"] as? String
					challenge.descriptionAction = dictionary["descriptionAction"] as? String
					challenge.challengeUid = snap2.key as String
					challenge.dateCreate = dictionary["createDate"] as? String
					challenge.date = dictionary["date"] as? String
					challenge.topic = dictionary["topic"] as? String


					self.refStorage.child("Challenge").child(self.nation!).child(snap2.key).getData(maxSize: 1*1024*1024){
						data, error in

						print("challenge sono nel immagine challenge")
						if error != nil{
							print("challenge sono in errore")
							print(error!)
						}

						print("challenge sono qui")
						challenge.challengeImg = UIImage(data: data!)
						
						self.refDatabase.child("Challenge").child(self.nation!).child(snap2.key).child("Users").observeSingleEvent(of: .value, with: { snap in
							
							challenge.challengeNumber = String(snap.childrenCount)
							
							
							
							challenge.profileImg = self.user?.image
							challenge.nameUser = self.user?.name
							self.assignElement(challenge: challenge)
							self.order()
							
							DispatchQueue.main.async {
								self.removeSpinner()
								self.refreshControl.endRefreshing()
								self.table.reloadData()
							}
							
							
						})
						
						


					}
					
				}
				
			}
			
		})
		
		
	}
    
    func assignElement(challenge : Challenge){
        self.challengeItems.append(challenge)
    }
    
	func order(){
		
		challengeItems.sort {
			
			let formatter = DateFormatter()
			formatter.dateStyle = .short
			formatter.locale = Locale(identifier: "en_US_POSIX")
			
			let date1 = formatter.date(from: $0.dateCreate!)
			let date2 = formatter.date(from: $1.dateCreate!)
			
			return date1! > date2!
		}
		
	}
    
    @objc func refresh(_ sender: AnyObject) {
        // Code to refresh table view
		challengeItems.removeAll()
		table.reloadData()
        takeNation()
		self.removeSpinner()
    }


}


extension ChallengeInProfileViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return challengeItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "challengeIn") as! HomeChallengeTableViewCell
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = backgroundView
        
        
        
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
        
        cell.profileImage.layer.cornerRadius = 47
        cell.profileImage.layer.borderWidth = 3
        cell.profileImage.layer.borderColor = UIColor.white.cgColor
        cell.profileImage.clipsToBounds = true
        
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
        cell.challengeImg.translatesAutoresizingMaskIntoConstraints = false
        cell.titleLabel.text = challengeItems[indexPath.row].title
        cell.descriptionLabel.text = challengeItems[indexPath.row].descriptionAction
        cell.challengeImg.image = challengeItems[indexPath.row].challengeImg
        cell.challengeImg.contentMode = .scaleAspectFill
		cell.profileImage.image = user?.image
		cell.userType.text = user?.type
		cell.userName.text = user?.name
		cell.peopleJoinedNumber.text = challengeItems[indexPath.row].challengeNumber
        
        return cell
    }
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
	
		
		refDatabase.child("UserProfile").child(Auth.auth().currentUser!.uid).child("Challenge").child(self.nation!).queryOrdered(byChild: "uidChallenge").queryEqual(toValue: challengeItems[indexPath.row].challengeUid).observeSingleEvent(of: .value, with: { snap in
			
			
			let vc = self.storyboard?.instantiateViewController(identifier: "join") as! JoinChallengeViewController
			
			
			vc.deletButtonOK = false
			vc.challengeUID = self.challengeItems[indexPath.row]
			vc.nation = self.nation
			vc.fromProfile = true
			
			
			
			if snap.childrenCount == 0 {
				
				vc.join = false
				vc.complete = true
				
				
				self.navigationController?.pushViewController(vc, animated: true)

			}else {
				
				for child in snap.children {
					guard let snap2 = child as? DataSnapshot else {return}
					
					guard let dic = snap2.value as? [String:AnyObject] else {return}
					
					if dic["complete"] as? String == "true" {
						vc.justComplete = true
					}
					
					
					vc.join = true
					vc.complete = false
					
					self.navigationController?.pushViewController(vc, animated: true)
				}
				
				
			}
			
		})
		

	
	}
    
    
}

extension ChallengeInProfileViewController {
    
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
