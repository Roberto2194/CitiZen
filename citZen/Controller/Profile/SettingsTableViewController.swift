//
//  SettingsTableViewController.swift
//  citZen
//
//  Created by Luigi Mazzarella on 28/05/2020.
//  Copyright © 2020 Luigi Mazzarella. All rights reserved.
//

import UIKit
import Firebase

class SettingsTableViewController: UITableViewController, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

	
	@IBOutlet weak var nicknameLabel: UITextField!
	@IBOutlet weak var nationLabel: UITextField!
	@IBOutlet weak var profileImg: UIImageView!
	
	let customGreen = UIColor(red: 0, green: 0.7529, blue: 0.3451, alpha: 1.0)
	
	let refDatabase = Database.database().reference().child("UserProfile").child(Auth.auth().currentUser!.uid)
	let refStorage = Storage.storage().reference().child("ProfileImage").child(Auth.auth().currentUser!.uid)
	
	var picker: UIPickerView!
	
	var image: UIImage?
	
	var pickerData: [String] = ["","Italy",
								"France",
								 "USA",
								 "England",
								 "Spain",
								 "Germany",
								 "Brazil",
								 "Poland",
								 "Holland",
								 "Australia",
								 "Canada"
	]

	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		overrideUserInterfaceStyle = .light 
		
		picker = UIPickerView()
		picker.delegate = self
		picker.dataSource = self
		
		picker.backgroundColor = .white
		
		let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: picker.frame.width, height: 20))
		toolBar.barStyle = .default
		toolBar.barTintColor = .white
		toolBar.isTranslucent = false
		let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(SettingsTableViewController.putIntoField))
		doneButton.tintColor = customGreen
		let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		toolBar.setItems([space, doneButton], animated: true)
		toolBar.isUserInteractionEnabled = true
		toolBar.sizeToFit()

		nationLabel.inputAccessoryView = toolBar
		nationLabel.inputView = picker
		
		
		refDatabase.observeSingleEvent(of: .value, with: { snap in
			
			guard let dictionary = snap.value as? [String:AnyObject] else {
				return
			}
			
			self.nationLabel.placeholder = dictionary["Location"] as? String
			self.nicknameLabel.placeholder = dictionary["nickname"] as? String
			
			
		})
		
		refStorage.getData(maxSize: 1*1024*1024) { data,error in
			
			if error != nil {
				print(error!)
				return
			}
			
			self.image = UIImage(data: data!)
			self.profileImg.image = self.image
			
		}
		
		
		let tap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		view.addGestureRecognizer(tap)
		
		let tap2: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(takePhoto))
		profileImg.addGestureRecognizer(tap2)
		profileImg.isUserInteractionEnabled = true
		

		
    }
	
	@objc func putIntoField(){
		

		dismissKeyboard()
		
	}
	
	@IBAction func signOut(_ sender: UIButton) {
		
		try! Auth.auth().signOut()
		
		if let storyboard = self.storyboard {
			let vc = storyboard.instantiateViewController(withIdentifier: "LogIn") as! LoginViewController
			self.navigationController?.setNavigationBarHidden(true, animated: true)
			self.tabBarController?.tabBar.isHidden = true
			self.navigationController?.pushViewController(vc, animated: true)
		}
		
	}
	@objc func dismissKeyboard(){
		view.endEditing(true)
	}
	

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		
		return pickerData.count
		
	}
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		
		return pickerData[row]
		
	}
	
	func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		
		nationLabel.text = pickerData[row]
	
	}
	


	@IBAction func doneButton(_ sender: UIBarButtonItem) {
		
		let nickname = nicknameLabel.text
		let nation = nationLabel.text
		
		
		if nickname != "" {
			self.refDatabase.updateChildValues([
				"nickname": self.nicknameLabel.text!
			])
			
		}
		if nation != "" {
			self.refDatabase.updateChildValues([
				"Location": self.nationLabel.text!
			])
			
		}
		
		if profileImg.image != image {
			refStorage.child(Auth.auth().currentUser!.uid).delete(completion: nil)
			
			if let profileImg = profileImg, let imageData = profileImg.image?.jpegData(compressionQuality: 0.1) {
				refStorage.putData(imageData, metadata: nil
				){ (metadata,error) in
					if error != nil {
						print(error as Any)
						return
					}
					guard metadata != nil else {
						return
					}
					
					self.refStorage.downloadURL(completion: { (url,error) in
						guard let downloadURL = url else {
							print(error!)
							return
						}
						
						self.refDatabase.updateChildValues([
							"ProfileUrl": downloadURL.absoluteString
						])
						
						
					})
				}
			}
		}
		
		self.navigationController?.popViewController(animated: true)

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
	
	
	
}


extension SettingsTableViewController: UIImagePickerControllerDelegate {
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		
		var image: UIImage?
		
		if let editImg = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
			image = editImg
		}else if let originalImg = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
			image = originalImg
		}
		
		
		if let selectedImage = image {
			self.profileImg?.image = selectedImage
			self.profileImg?.contentMode = .scaleAspectFill
		}
		
		
		
		dismiss(animated: true, completion: nil)
	}
	
	
}
