//
//  ViewController.swift
//  citZen
//
//  Created by Luigi Mazzarella on 13/05/2020.
//  Copyright © 2020 Luigi Mazzarella. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class ProfileCreateViewController: UIViewController, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
	

	@IBOutlet weak var profileImage: UIImageView!
	@IBOutlet weak var nameField: UITextField!
	@IBOutlet weak var surnameField: UITextField!
	@IBOutlet weak var nickField: UITextField!
	@IBOutlet weak var ageFiel: UITextField!
	@IBOutlet weak var locaField: UITextField!
	@IBOutlet weak var typeField: UITextField!
	@IBOutlet weak var errorLabel: UILabel!
	
	let loginVC = LoginViewController()
	
	var ref: DatabaseReference!
	var storage: StorageReference!
	
	var name: String!
	var surname: String!
	var nickname: String!
	var profileUrl: String!
	
	var pickerData:  [String] = ["","13-20","21-30","31-50","51+"]
	var pickerData2: [String] = ["","Italy",
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
	var pickerData3: [String] = ["","Citizen","Association","Company"]
	
	var picker: UIPickerView!
	var picker2: UIPickerView!
	var picker3:UIPickerView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		overrideUserInterfaceStyle = .light 
		
		errorLabel.isHidden = true
		
		profileImage.translatesAutoresizingMaskIntoConstraints = false
		
		picker = UIPickerView()
		picker2 = UIPickerView()
		picker3 = UIPickerView()
		
		picker3.delegate = self
		picker3.dataSource = self
		
		picker2.delegate = self
		picker2.dataSource = self
		
		picker.delegate = self
		picker.dataSource = self
		
		locaField.inputView = picker2
		ageFiel.inputView = picker
		typeField.inputView = picker3
		
		
		let tap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		view.addGestureRecognizer(tap)
		
		let tap2: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(takePhoto))
		profileImage.addGestureRecognizer(tap2)
		profileImage.isUserInteractionEnabled = true
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
		
		ref = Database.database().reference()
		storage = Storage.storage().reference(forURL: "gs://citizen-7734d.appspot.com")
        
        let cgCustomBlue = CGColor(srgbRed: 0.2157, green: 0.2118, blue: 0.2941, alpha: 1.0) /* #37364b */
        
        //Customizes the text fields
        let bottomLineName = CALayer()
        bottomLineName.frame = CGRect(x: 0.0, y: nameField.frame.height - 5, width: nameField.frame.width, height: 1.0)
        bottomLineName.backgroundColor = cgCustomBlue
        nameField.borderStyle = UITextField.BorderStyle.none
        nameField.layer.addSublayer(bottomLineName)
        
        let bottomLineSurname = CALayer()
        bottomLineSurname.frame = CGRect(x: 0.0, y: surnameField.frame.height - 5, width: surnameField.frame.width, height: 1.0)
        bottomLineSurname.backgroundColor = cgCustomBlue
        surnameField.borderStyle = UITextField.BorderStyle.none
        surnameField.layer.addSublayer(bottomLineSurname)

        let bottomLineNickname = CALayer()
        bottomLineNickname.frame = CGRect(x: 0.0, y: nickField.frame.height - 5, width: nickField.frame.width, height: 1.0)
        bottomLineNickname.backgroundColor = cgCustomBlue
        nickField.borderStyle = UITextField.BorderStyle.none
        nickField.layer.addSublayer(bottomLineNickname)
        
        let bottomLineAge = CALayer()
        bottomLineAge.frame = CGRect(x: 0.0, y: ageFiel.frame.height - 5, width: ageFiel.frame.width, height: 1.0)
        bottomLineAge.backgroundColor = cgCustomBlue
        ageFiel.borderStyle = UITextField.BorderStyle.none
        ageFiel.layer.addSublayer(bottomLineAge)

        let bottomLineLocation = CALayer()
        bottomLineLocation.frame = CGRect(x: 0.0, y: locaField.frame.height - 5, width: locaField.frame.width, height: 1.0)
        bottomLineLocation.backgroundColor = cgCustomBlue
        locaField.borderStyle = UITextField.BorderStyle.none
        locaField.layer.addSublayer(bottomLineLocation)
        
        let bottomLineType = CALayer()
        bottomLineType.frame = CGRect(x: 0.0, y: typeField.frame.height - 5, width: typeField.frame.width, height: 1.0)
        bottomLineType.backgroundColor = cgCustomBlue
        typeField.borderStyle = UITextField.BorderStyle.none
        typeField.layer.addSublayer(bottomLineType)
        
        //Make the profile image rounded
        profileImage.layer.cornerRadius = 40
        profileImage.clipsToBounds = true
        profileImage.layer.borderWidth = 2
        profileImage.layer.borderColor = UIColor.white.cgColor
        
        //Custom Pickers
        let customGreen = UIColor(red: 0, green: 0.7529, blue: 0.3451, alpha: 1.0)
        let customBlue = UIColor(red: 0.2157, green: 0.2118, blue: 0.2941, alpha: 1.0)
        
        picker2.backgroundColor = .white
        picker2.setValue(customBlue, forKeyPath: "textColor")
        picker3.backgroundColor = .white
        picker3.setValue(customBlue, forKeyPath: "textColor")
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.backgroundColor = .white
        toolBar.tintColor = .white
        toolBar.isTranslucent = false
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ProfileCreateViewController.putIntoField))
        doneButton.tintColor = customGreen
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([space, doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        locaField.inputAccessoryView = toolBar
        typeField.inputAccessoryView = toolBar
	}
    
    @objc func putIntoField(){
        dismissKeyboard()
    }

	
	
	@objc func dismissKeyboard(){
		view.endEditing(true)
	}
		

	@objc func keyboardWillShow(sender: NSNotification) {
		self.view.frame.origin.y -= 100
	}
	
	@objc func keyboardWillHide(sender: NSNotification) {
		self.view.frame.origin.y = 0
	}
	
	
	
	@IBAction func done(_ sender: UIButton) {
		
		loginVC.animateButton(sender)
		
		name = nameField.text
		surname = surnameField.text
		nickname = nickField.text
		let type = typeField.text
		let nation = locaField.text
		
		if name == "" || surname == "" || type == "" || nation == "" {
			
			errorLabel.isHidden = false
			errorLabel.text = "All fields with * are mandatory"
			
		} else {
			errorLabel.isHidden = true
			
			
			
			createProfileData()
		}
		
	
	}
	
	func push(){
		let vc = self.storyboard?.instantiateViewController(identifier: "verify") as! VerifyViewController
		
		
		self.navigationController?.pushViewController(vc, animated: true)
	}
	
	func createProfileData(){
	
		
		let refStore = storage.child("ProfileImage").child(Auth.auth().currentUser!.uid)
		if let profileImg = profileImage, let imageData = profileImg.image?.jpegData(compressionQuality: 0.1) {
			refStore.putData(imageData, metadata: nil
			){ (metadata,error) in
				if error != nil {
					print(error as Any)
					return
				}
				guard metadata != nil else {
					return
				}
			
				refStore.downloadURL(completion: { (url,error) in
					guard let downloadURL = url else {
						print(error!)
						return
					}
					self.profileUrl = downloadURL.absoluteString
					
					self.ref.child("UserProfile").child(Auth.auth().currentUser!.uid).setValue([
						"name": self.name,
						"surname": self.surname,
						"nickname": self.nickname,
						"Age": self.ageFiel.text!,
						"Location": self.locaField.text!,
						"Type": self.typeField.text!,
						"ProfileUrl": self.profileUrl,
						"points": "0",
						"mobilityPoints": "0",
						"digitalPoints": "0",
						"energyPoints": "0",
						"wastePoints": "0",
						"waterPoints": "0",
						"foodPoints": "0"
					])
					self.push()
				})
				
				
				
			}
		}
		
		
		
	}
	
	
	

	@objc func takePhoto() {
		let alert = UIAlertController(title: "Choose a photo", message: "choose where do you want to take a photo", preferredStyle: .actionSheet)
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
	
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		
		if pickerView == picker {
			return pickerData.count
		} else if pickerView == picker2 {
			return pickerData2.count
		} else {
			return pickerData3.count
		}
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		
		if pickerView == picker {
			return pickerData[row]
		} else if pickerView == picker2 {
			return pickerData2[row]
		} else {
			return pickerData3[row]
		}
	}
	
	func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		
		if pickerView == picker {
			ageFiel.text = pickerData[row]
		} else if pickerView == picker2 {
			locaField.text = pickerData2[row]
		} else {
			typeField.text = pickerData3[row]
		}
	}
	
	@IBAction func signOut(_ sender: Any) {
		
		try! Auth.auth().signOut()
		
		if let storyboard = self.storyboard {
			let vc = storyboard.instantiateViewController(withIdentifier: "LogIn") as! LoginViewController
			self.navigationController?.pushViewController(vc, animated: true)
		}
	}
}


extension ProfileCreateViewController: UIImagePickerControllerDelegate {
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		
		var image: UIImage?

		if let editImg = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
			image = editImg
		}else if let originalImg = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
			image = originalImg
		}

		
		if let selectedImage = image {
			self.profileImage?.image = selectedImage
			self.profileImage?.contentMode = .scaleAspectFill
		}
		
		
		
		dismiss(animated: true, completion: nil)
	}
	
	
}
