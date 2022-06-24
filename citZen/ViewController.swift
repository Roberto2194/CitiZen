//
//  ViewController.swift
//  citZen
//
//  Created by Luigi Mazzarella on 13/05/2020.
//  Copyright © 2020 Luigi Mazzarella. All rights reserved.
//

import UIKit
import Firebase

class ProfileCreateViewController: UIViewController, UINavigationControllerDelegate {

	@IBOutlet weak var profileImage: UIImageView!
	@IBOutlet weak var nameFileld: UITextField!
	@IBOutlet weak var surnameField: UITextField!
	@IBOutlet weak var ageField: UITextField!
	@IBOutlet weak var typeField: UITextField!
	@IBOutlet weak var locationField: UITextField!
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		let storage = Storage.storage()
		// Get a non-default Storage bucket
		storage = Storage.storage(url:"gs://my-custom-bucket")
		
	}

	
	func uploadImmage(){
		
		
		
	
	}
	
	func createProfileData(){
		
	}

	@IBAction func takePhoto(_ sender: UIButton) {
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
			self.present(picker, animated: true)
			
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		present(alert,animated: true)
	}
}


extension ProfileCreateViewController: UIImagePickerControllerDelegate {
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		picker.dismiss(animated: true)
		
		guard let image = info[.originalImage] as? UIImage else {
			return
		}
		
		self.profileImage?.image = image
		self.profileImage?.contentMode = .scaleToFill
	}
}
