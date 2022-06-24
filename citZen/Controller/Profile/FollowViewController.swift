//
//  FollowViewController.swift
//  citZen
//
//  Created by Domenico Varchetta on 04/06/2020.
//  Copyright © 2020 Luigi Mazzarella. All rights reserved.
//

import UIKit
import Firebase

class FollowViewController: UIViewController {
	
	@IBOutlet weak var table: UITableView!
	let refDatabase = Database.database().reference().child("UserProfile")
	let refStorage = Storage.storage().reference().child("ProfileImage")
	
	var type: String?
	
	var userCollection: [User] = []
	var userCollectionUID: [String] = []

    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		overrideUserInterfaceStyle = .light 
		
		loadData()
	}
	
	func loadData(){
		
		userCollection = []
		userCollectionUID = []
		
		refDatabase.child(Auth.auth().currentUser!.uid).child(type!).observeSingleEvent(of: .value, with: { snap in
			
			print("FollowLoad \(snap.childrenCount)")
			
			guard let dic = snap.value as? [String:AnyObject] else {return}
			
			dic.forEach({ key, value in
				
				print("FollowLoad \(key) \(value)")
				
				self.addIdUser(uid: key)
				
			})
			self.loadUser()
			
		})
	}
	
	func addIdUser(uid: String){
		
		userCollectionUID.append(uid)
	}
	
	func loadUser(){
		
		for id in userCollectionUID {
			refDatabase.child(id).observeSingleEvent(of: .value, with: { snap in
				
				guard let dic = snap.value as? [String:AnyObject] else {return}
				
				let user = User()
				
				let name = dic["name"] as? String
				let surname = dic["surname"] as? String
				
				user.name = "\(name!) \(surname!)"
				user.uid = id
				
				self.refStorage.child(id).getData(maxSize: 1*1024*1024) { data, error in
					
					if error != nil {
						print(error!)
						return
					}
					
					user.image = UIImage(data: data!)
					self.addUserCollect(user: user)
					self.order()
					DispatchQueue.main.async {
						self.table.reloadData()
					}
					
					
				}
				
			})
			
		}
		
		
		
	}
	
	func addUserCollect(user : User){
		
		userCollection.append(user)
	}
	
	func order(){
		userCollection.sorted {
			return $0.name! < $1.name!
			
		}
	}
	
	
    

}

extension FollowViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return userCollection.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowCellID", for: indexPath) as! FollowTableViewCell
        
        // cell rounded section
        cell.layer.borderWidth = 5.0
        cell.layer.borderColor = UIColor.clear.cgColor
        
        // cell shadow section
        cell.internalCellView.layer.cornerRadius = 20.0
        cell.internalCellView.layer.borderWidth = 4.0
        cell.internalCellView.layer.borderColor = UIColor.clear.cgColor
        cell.internalCellView.layer.masksToBounds = true
        cell.externalCellView.layer.shadowColor = UIColor.gray.cgColor
        cell.externalCellView.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        cell.externalCellView.layer.shadowRadius = 6.0
        cell.externalCellView.layer.shadowOpacity = 0.5
        cell.externalCellView.layer.cornerRadius = 20.0
        cell.externalCellView.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.internalCellView.layer.bounds, cornerRadius: cell.externalCellView.layer.cornerRadius).cgPath
		
		cell.userImageView.image = userCollection[indexPath.row].image
		cell.userName.text = userCollection[indexPath.row].name
		
        return cell
    }
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let vc = storyboard?.instantiateViewController(identifier: "follower") as! ProfileUserViewController
		
		vc.uid = userCollection[indexPath.row].uid
		
		navigationController?.pushViewController(vc, animated: true)
	}
    
    
}
