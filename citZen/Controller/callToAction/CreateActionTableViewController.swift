//
//  CreateActionTableViewController.swift
//  citZen
//
//  Created by Luigi Mazzarella on 21/05/2020.
//  Copyright © 2020 Luigi Mazzarella. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage


class CreateActionTableViewController: UITableViewController, UITextViewDelegate {
	
	@IBOutlet weak var NameField: UITextField!
	@IBOutlet weak var challengeImageView: UIImageView!
	@IBOutlet weak var endDate: UITextField!
    @IBOutlet weak var descriptionField: UITextView!
    
    @IBOutlet weak var benefitField: UITextView!
    
	
	var name: String?
	var descriptionAction: String?
	var benefits: String?
	var endDateData: String?
	var topic: String?
	var ImgUrl: String?
	var nation : String?
	var points: String?
	var isOk = false
	var buttonPressed = false
	
	var picker: UIDatePicker!
	var dataString:String?
	
	let refStorege = Storage.storage().reference()
	let refDatabase = Database.database().reference()
    
	
	func randomString(length: Int) -> String {
		let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		return String((0..<length).map{ _ in letters.randomElement()! })
	}

	
	@IBAction func doneButtone(_ sender: UIBarButtonItem) {
		
		
		self.name = self.NameField.text
		self.descriptionAction = self.descriptionField.text
		self.benefits = self.benefitField.text
		self.endDateData = self.endDate.text
		
        if name == "" || descriptionAction == "" || benefits == "" || endDateData == "" || challengeImageView.image == UIImage(named: "plus") {
			
			let alert = UIAlertController(title: "Error", message: "You must fill in all fields", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
			
			present(alert, animated: true, completion: nil)
			
			
		} else {
			if !buttonPressed {
				
				buttonPressed = true
				let refUser = self.refDatabase.child("UserProfile").child(Auth.auth().currentUser!.uid)
				
				refUser.observeSingleEvent(of: .value, with: { snapshot in
					if let dictionary = snapshot.value as? [String:Any] {
						self.nation = dictionary["Location"] as? String
						
						
						
						let cID = self.randomString(length: 20)
						
						self.refDatabase.child("Challenge").child(self.nation!).queryOrderedByKey().queryEqual(toValue: cID).observeSingleEvent(of: .value, with: {
							snap in
							
							print("ChallengeID \(snap.childrenCount)")
							
							if snap.childrenCount == 0 {
								
								let refStore = self.refStorege.child("Challenge").child(self.nation!).child(cID)
								
								if let challengeImg = self.challengeImageView, let imageData = challengeImg.image?.jpegData(compressionQuality: 0.1) {
									refStore.putData(imageData, metadata: nil
									){ (metadata,error) in
										if error != nil {
											print(error as Any)
											return
										}
										
										
										refStore.downloadURL(completion: { (url,error) in
											guard let downloadURL = url else {
												print(error!)
												return
											}
											
											self.ImgUrl = downloadURL.absoluteString
											
											let currentData = Date()
											let formatter  = DateFormatter()
											
											formatter.dateStyle = .short
											formatter.locale = Locale(identifier: "en_US_POSIX")
											
											let today = formatter.string(from: currentData)
											
											
											self.refDatabase.child("Challenge").child(self.nation!).child(cID).setValue([
												"title": self.name,
												"descriptionAction": self.descriptionAction,
												"topic": self.topic,
												"benefit": self.benefits,
												"date": self.endDateData,
												"uidCreator": Auth.auth().currentUser?.uid,
												"imgLink": self.ImgUrl,
												"points": self.points,
												"createDate": today
											])
											
											self.navigationController?.popViewController(animated: true)
										})
										
										
										
									}
								}
								
							}
							
						})
						
						
						
						
					}
				})
			}
		
		}
		
	}
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.8) {
            textView.text = nil
            textView.textColor = customBlue
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            if textView == descriptionField {
                textView.text = "Enter a Description for your Call to Action"
            } else {
                textView.text = "Enter the Benefits you get by doing this Call to Action"
            }
            
            textView.textColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.8)
        }
    }
    
	override func viewDidLoad() {
        super.viewDidLoad()
		
		overrideUserInterfaceStyle = .light
		
		let tap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		view.addGestureRecognizer(tap)
        
        descriptionField.delegate = self
        benefitField.delegate = self
        
        challengeImageView.layer.cornerRadius = 20
        challengeImageView.clipsToBounds = true
        
        self.navigationController?.navigationBar.barTintColor = .white
		
        descriptionField.layer.cornerRadius = 6
        descriptionField.layer.masksToBounds = true
        descriptionField.layer.borderWidth = 1
        descriptionField.layer.borderColor = UIColor.lightGray.cgColor
        descriptionField.text = "Enter a Description for your Call to Action"
        descriptionField.textColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.8)
        
        benefitField.layer.cornerRadius = 6
        benefitField.layer.masksToBounds = true
        benefitField.layer.borderWidth = 1
        benefitField.layer.borderColor = UIColor.lightGray.cgColor
        benefitField.text = "Enter the Benefits you get by doing this Call to Action"
        benefitField.textColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.8)
        
		
		setDatePicker()
		endDate.inputView = picker
        

		
		let tap2: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(takePhoto))
		challengeImageView.addGestureRecognizer(tap2)
		challengeImageView.isUserInteractionEnabled = true
		challengeImageView.image = UIImage(named: "plus")
    }
	
	
	
	func setDatePicker(){
		
		
		let date = NSDate()
		let calendar = NSCalendar.current
		let components = calendar.dateComponents([.month,.day,.year], from: date as Date)
		let startOfMonth = calendar.date(from: components)
        
		picker = UIDatePicker()
		picker.datePickerMode = .date
		picker.timeZone = NSTimeZone.local
		picker.minimumDate = startOfMonth!
		
        picker.backgroundColor = .white
        picker.setValue(customBlue, forKeyPath: "textColor")
		
		let toolBar = UIToolbar()
		toolBar.barStyle = .default
        toolBar.barTintColor = .white
		toolBar.isTranslucent = false
		let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(CreateActionTableViewController.putIntoField))
        doneButton.tintColor = customGreen
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		toolBar.setItems([space, doneButton], animated: true)
		toolBar.isUserInteractionEnabled = true
		toolBar.sizeToFit()

		endDate.inputAccessoryView = toolBar
		
		
		
	}
	
	
	@objc func putIntoField(){
		
		let formatter = DateFormatter()
		formatter.dateStyle = .short
		formatter.dateFormat = "MM/dd/yyy"
		formatter.locale = Locale(identifier: "en_US_POSIX")
		dataString = formatter.string(from: picker.date)

		
		endDate.text = dataString
		
		dismissKeyboard()
		
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
	
	
	
	@objc func dismissKeyboard(){
		view.endEditing(true)
	}
	
	

    
    @IBOutlet weak var waterButton: UIButton!
    @IBOutlet weak var wasteButton: UIButton!
    @IBOutlet weak var energyButton: UIButton!
    @IBOutlet weak var digitalButton: UIButton!
    @IBOutlet weak var mobilityButton: UIButton!
    @IBOutlet weak var foodButton: UIButton!
    let customGreen = UIColor(red: 0, green: 0.7529, blue: 0.3451, alpha: 1.0)
    let customBlue = UIColor(red: 0.2157, green: 0.2118, blue: 0.2941, alpha: 1.0)
    
    func resetButtons() {
        waterButton.backgroundColor = customGreen
        wasteButton.backgroundColor = customGreen
        energyButton.backgroundColor = customGreen
        digitalButton.backgroundColor = customGreen
        mobilityButton.backgroundColor = customGreen
        foodButton.backgroundColor = customGreen
        waterButton.setTitleColor(customBlue, for: .normal)
        wasteButton.setTitleColor(customBlue, for: .normal)
        energyButton.setTitleColor(customBlue, for: .normal)
        digitalButton.setTitleColor(customBlue, for: .normal)
        mobilityButton.setTitleColor(customBlue, for: .normal)
        foodButton.setTitleColor(customBlue, for: .normal)
        counterTagWater = 0
        counterTagWaste = 0
        counterTagEnergy = 0
        counterTagDigital = 0
        counterTagMobility = 0
        counterTagFood = 0
    }
	
	var counterTagMobility = 0
	var counterTagWaste = 0
	var counterTagEnergy = 0
	var counterTagWater = 0
	var counterTagFood = 0
	var counterTagDigital = 0
	
	@IBAction func mobilityButton(_ sender: UIButton) {
		
		if counterTagWaste != 0 || counterTagFood != 0 || counterTagWater != 0 || counterTagEnergy != 0 || counterTagDigital != 0 {
            resetButtons()
            counterTagMobility = 1
			topic = "mobility"
            points = "5"
            sender.backgroundColor = customBlue
            sender.setTitleColor(customGreen, for: .normal)
		}
		else {
			if sender.isTouchInside {
				if counterTagMobility == 0 {
					topic = "mobility"
                    sender.backgroundColor = customBlue
                    sender.setTitleColor(customGreen, for: .normal)
					points = "5"
					counterTagMobility = 1
				} else {
					resetButtons()
                    topic = ""
					points = "0"
				}
			}
		}
		
	}
	
	@IBAction func wasteButton(_ sender: UIButton) {
		if counterTagMobility != 0 || counterTagFood != 0 || counterTagWater != 0 || counterTagEnergy != 0 || counterTagDigital != 0 {
            resetButtons()
            counterTagWaste = 1
            topic = "waste"
            points = "5"
            sender.backgroundColor = customBlue
            sender.setTitleColor(customGreen, for: .normal)
		}
		else {
			if sender.isTouchInside {
				if counterTagWaste == 0 {
					topic = "waste"
                    sender.backgroundColor = customBlue
                    sender.setTitleColor(customGreen, for: .normal)
					counterTagWaste = 1
					points = "5"
				}else {
                    resetButtons()
                    topic = ""
                    points = "0"
				}
			}

		}
	}
	
	@IBAction func energyButton(_ sender: UIButton) {
		if counterTagMobility != 0 || counterTagFood != 0 || counterTagWater != 0 || counterTagWaste != 0 || counterTagDigital != 0 {
            resetButtons()
            counterTagEnergy = 1
            topic = "energy"
            points = "5"
            sender.backgroundColor = customBlue
            sender.setTitleColor(customGreen, for: .normal)
		}
		else {
			if sender.isTouchInside {
				if counterTagEnergy == 0 {
					topic = "energy"
                    sender.backgroundColor = customBlue
                    sender.setTitleColor(customGreen, for: .normal)
					counterTagEnergy = 1
					points = "5"
				}else {
                    resetButtons()
                    topic = ""
                    points = "0"
				}
			}
		}
		
	}
	
	
	@IBAction func waterButton(_ sender: UIButton) {
		if counterTagMobility != 0 || counterTagFood != 0 || counterTagEnergy != 0 || counterTagWaste != 0 || counterTagDigital != 0 {
            resetButtons()
            counterTagWater = 1
            topic = "water"
            points = "5"
            sender.backgroundColor = customBlue
            sender.setTitleColor(customGreen, for: .normal)
		}
		else {
			if sender.isTouchInside {
				if counterTagWater == 0 {
					topic = "water"
                    sender.backgroundColor = customBlue
                    sender.setTitleColor(customGreen, for: .normal)
					counterTagWater = 1
					points = "5"
				}else {
                    resetButtons()
                    topic = ""
                    points = "0"
				}
			}
		}
		
	}
	
	@IBAction func foodButton(_ sender: UIButton) {
		if counterTagMobility != 0 || counterTagWater != 0 || counterTagEnergy != 0 || counterTagWaste != 0 || counterTagDigital != 0 {
            resetButtons()
            counterTagFood = 1
            topic = "food"
            points = "5"
            sender.backgroundColor = customBlue
            sender.setTitleColor(customGreen, for: .normal)
		}
		else {
			if sender.isTouchInside {
				if counterTagFood == 0 {
					topic = "food"
                    sender.backgroundColor = customBlue
                    sender.setTitleColor(customGreen, for: .normal)
					counterTagFood = 1
					points = "5"
				}else {
                    resetButtons()
                    topic = ""
                    points = "0"
				}
			}
		}
		
	}
	
	@IBAction func digitalButton(_ sender: UIButton) {
		if counterTagMobility != 0 || counterTagFood != 0 || counterTagEnergy != 0 || counterTagWaste != 0 || counterTagFood != 0 {
            resetButtons()
            counterTagDigital = 1
            topic = "digital"
            points = "5"
            sender.backgroundColor = customBlue
            sender.setTitleColor(customGreen, for: .normal)
		}else {
			if sender.isTouchInside {
				if counterTagDigital == 0 {
					topic = "digital"
                    sender.backgroundColor = customBlue
                    sender.setTitleColor(customGreen, for: .normal)
					counterTagDigital = 1
					points = "5"
				}else {
                    resetButtons()
                    topic = ""
                    points = "0"
				}
			}
		}
		
	}
	
	
}


extension CreateActionTableViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		
		var image: UIImage?
		
		if let editImg = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
			image = editImg
		}else if let originalImg = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
			image = originalImg
		}
		
		
		if let selectedImage = image {
			self.challengeImageView?.image = selectedImage
			self.challengeImageView?.contentMode = .scaleAspectFill
		}
		
		
		
		dismiss(animated: true, completion: nil)
	}
	
	
}
