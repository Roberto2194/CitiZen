//
//  CompleteTableViewController.swift
//  citZen
//
//  Created by Luigi Mazzarella on 27/05/2020.
//  Copyright © 2020 Luigi Mazzarella. All rights reserved.
//

import UIKit
import Firebase

class CompleteTableViewController: UITableViewController, UINavigationControllerDelegate{

	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var myChallengeImage: UIImageView!
	@IBOutlet weak var benefitsLabel: UILabel!
	@IBOutlet weak var pointsLabel: UILabel!
	
	let loginVC = LoginViewController()
	
	var challenge: Challenge!
	var nation: String?
	
	let refStorage = Storage.storage().reference()
	let refDatabase = Database.database().reference()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		overrideUserInterfaceStyle = .light 
		
		titleLabel.text = challenge.title
		benefitsLabel.text = challenge.benefit
		pointsLabel.text = challenge.points
		
		let tap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(takePhoto))
		myChallengeImage.addGestureRecognizer(tap)
		myChallengeImage.isUserInteractionEnabled = true
		
		//Customizes the challenge image
		myChallengeImage.layer.cornerRadius = 30
		myChallengeImage.clipsToBounds = true
		myChallengeImage.image = UIImage(named: "plus")
       
    }
	
	
	@objc func takePhoto() {
		let alert = UIAlertController(title: "Choose a photo", message: "Choose where to pick a photo", preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in
			
			let picker = UIImagePickerController()
			picker.sourceType = .camera
			picker.delegate = self
			self.present(picker, animated: true)
			
		}))
		alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { action in
			let picker = UIImagePickerController()
			picker.sourceType = .savedPhotosAlbum
			picker.delegate = self
			picker.allowsEditing = true
			self.present(picker, animated: true)
			
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		present(alert,animated: true)
	}

	@IBAction func confermeChallenge(_ sender: UIButton) {
		
		loginVC.animateButton(sender)
		
		if myChallengeImage.image != UIImage(named: "plus") {
			let challengeStore = refStorage.child("ChallengeComplete").child(Auth.auth().currentUser!.uid).child(challenge.challengeUid!)
			
			if let challengeImg = myChallengeImage, let imageData = challengeImg.image?.jpegData(compressionQuality: 0.1) {
				challengeStore.putData(imageData, metadata: nil ){ (metadata,error) in
					if error != nil {
						print(error as Any)
						return
					}
					guard metadata != nil else {
						return
					}
					
					self.refDatabase.child("UserProfile").child(Auth.auth().currentUser!.uid).child("Challenge").child(self.nation!).child(self.challenge.challengeUid!).updateChildValues([
						"complete": "true"
					])
					self.refDatabase.child("UserProfile").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { snap in
						
						if let dictionary = snap.value as? [String: AnyObject ] {
							
							let points = dictionary["points"] as? String
							var pointsOf: Int = Int(points!)!
							
							let topic = self.challenge.topic!
							print("Challengetopic \(topic)")
							
							var topicPoints: String!
							
							pointsOf += 5
							
							switch topic {
								case "mobility":
									topicPoints = dictionary["mobilityPoints"] as? String
									
									var topicInt: Int = Int(topicPoints!)!
									
									topicInt += 5
								
									self.refDatabase.child("UserProfile").child(Auth.auth().currentUser!.uid).updateChildValues([
										"points": String(pointsOf),
										"mobilityPoints": String(topicInt)
										
									])
								case "energy":
									topicPoints = dictionary["energyPoints"] as? String
									var topicInt: Int = Int(topicPoints!)!
									topicInt += 5
									
									self.refDatabase.child("UserProfile").child(Auth.auth().currentUser!.uid).updateChildValues([
										"points": String(pointsOf),
										"energyPoints": String(topicInt)
									])
								case "water":
									topicPoints = dictionary["waterPoints"] as? String
									var topicInt: Int = Int(topicPoints!)!
									topicInt += 5
								
									self.refDatabase.child("UserProfile").child(Auth.auth().currentUser!.uid).updateChildValues([
										"points": String(pointsOf),
										"waterPoints": String(topicInt)
									])
								case "food":
									topicPoints = dictionary["foodPoints"] as? String
									var topicInt: Int = Int(topicPoints!)!
									topicInt += 5
								
									self.refDatabase.child("UserProfile").child(Auth.auth().currentUser!.uid).updateChildValues([
										"points": String(pointsOf),
										"foodPoints": String(topicInt)
									])
								case "digital":
									topicPoints = dictionary["digitalPoints"] as? String
									var topicInt: Int = Int(topicPoints!)!
									topicInt += 5
									
									self.refDatabase.child("UserProfile").child(Auth.auth().currentUser!.uid).updateChildValues([
										"points": String(pointsOf),
										"digitalPoints": String(topicInt)
									])
								case "waste":
									topicPoints = dictionary["wastePoints"] as? String
									var topicInt: Int = Int(topicPoints!)!
									topicInt += 5
									
									self.refDatabase.child("UserProfile").child(Auth.auth().currentUser!.uid).updateChildValues([
										"points": String(pointsOf),
										"wastePoints": String(topicInt)
									])
								default:
									break
							}
							
						
							
							print("Ho sommato i punti! \(pointsOf)")
							self.refDatabase.child("UserProfile").child(Auth.auth().currentUser!.uid).updateChildValues(["points": String(pointsOf)])
							
							
							
							
						}
						
					})
					self.navigationController?.popViewController(animated: true)
					
				}
			}
		}else {
			let alert = UIAlertController(title: "Error", message: "You must add a photo", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
			present(alert, animated: true, completion: nil)
		}
		
		
	}
	
}


extension CompleteTableViewController: UIImagePickerControllerDelegate {
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		
		var image: UIImage?
		
		if let editImg = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
			image = editImg
		}else if let originalImg = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
			image = originalImg
		}
		
		
		if let selectedImage = image {
			self.myChallengeImage?.image = selectedImage
			self.myChallengeImage?.contentMode = .scaleAspectFill
		}
		
		
		dismiss(animated: true, completion: nil)
	}
	
	
}
