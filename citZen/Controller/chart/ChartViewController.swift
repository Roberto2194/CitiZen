//
//  ChartViewController.swift
//  citZen
//
//  Created by Luigi Mazzarella on 20/05/2020.
//  Copyright © 2020 Luigi Mazzarella. All rights reserved.
//

import UIKit
import Firebase


class ChartViewController: UIViewController, UISearchResultsUpdating {
	
	
	

	@IBOutlet weak var table: UITableView!
	@IBOutlet weak var nationLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
	var vSpinner : UIView?
	
	var userCollection: [User] = []
	var userCollectionFiltred: [User] = []
	
	var refreshControl = UIRefreshControl()
	
	let refDatabase = Database.database().reference()
	let refStorage = Storage.storage().reference()
	
	var nation: String?
	var searchBar: UISearchController?
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		overrideUserInterfaceStyle = .light
		
		userCollection.removeAll()
		table.reloadData()
		
		showSpinner(onView: self.view)
		refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
		refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
		table.addSubview(refreshControl)
		
		searchBar = ({
			let controller = UISearchController(searchResultsController: nil)
			controller.searchResultsUpdater = self
			controller.obscuresBackgroundDuringPresentation = false
			controller.searchBar.sizeToFit()
			controller.searchBar.placeholder = "Search user"
			
			table.tableHeaderView = controller.searchBar
			
			return controller
		})()
		
		loadData()
		
	
    }
	
	func updateSearchResults(for searchController: UISearchController) {
		
		self.filterContent(findText: searchBar!.searchBar.text!)
		
	}
	
	func filterContent(findText: String) {
		
		userCollectionFiltred.removeAll(keepingCapacity: true)
		
		for user in userCollection{
			
			var justOne = false
			
			 if user.name!.lowercased().contains(findText.lowercased()) && justOne == false {
				
				userCollectionFiltred.append(user)
				justOne = true
				
			}
			
			
			
			self.table.reloadData()
		}
	}
	
	
	
	
	@objc func refresh(_ sender: AnyObject) {
		
		// Code to refresh table view
		userCollection.removeAll()
		table.reloadData()
		loadData()
	}

	func loadData() {
		
		refDatabase.child("UserProfile").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { snapshot in
		
			
			
			print("Sono in load Data")
			
			if let dictionary = snapshot.value as? [String:AnyObject] {
				
				
				self.nation = dictionary["Location"] as? String
				self.nationLabel.text = self.nation!

				
				
				self.loadUserInChart()
			}
		})
		
	}
	
	func loadUserInChart(){
	
		
		self.refreshControl.endRefreshing()
		

		refDatabase.child("UserProfile").queryOrdered(byChild: "Location").queryEqual(toValue: self.nation!).observeSingleEvent(of: .value, with: { snap in

			
			
			print("Number of UserCollection \(self.userCollection.count)")
			print("Number of User \(snap.childrenCount)")
			if snap.childrenCount == 0 {
				self.removeSpinner()
				return
			}
			
			for child in snap.children {
				
				guard let snap2 = child as? DataSnapshot else {return}
				
				guard let dic = snap2.value as? [String:AnyObject] else {return}
				
				
				let user = User()
				
				let name = dic["name"] as? String
				let surname = dic["surname"] as? String
				
				user.name  =  "\(name!) \(surname!)"
				user.points = dic["points"] as? String
				user.uid = snap2.key

				self.refStorage.child("ProfileImage").child(snap2.key).getData(maxSize: 1 * 1024 * 1024) { data,error in
					
					
					
					
					if error != nil {
						print("refStorege error ")
						print(error as Any)
					}else {
						
						
						var level = 0
						let points: Int = Int(user.points!)!
						
						switch  points{
							case 0 ... 9:
								level = 0
							case 10 ... 29:
								level = 1
							case 30 ... 49:
								level = 2
							case 50 ... 79:
								level = 3
							case 80 ... 119:
								level = 4
							case 120... :
								level = 5
							default:
								break
						}
						
						user.level = level
						
						user.image = UIImage(data: data!)
						self.addUser(user: user)
						self.reorderArray()
						
						DispatchQueue.main.async {

							self.removeSpinner()
							self.table.reloadData()
	
							
						}
					}
					
				}
	
			}
			
			
		})
		
	}
	
	
	func addUser(user: User){
		
		userCollection.append(user)
	}
	
	
	
	
	func reorderArray() {
		
		self.userCollection.sort {
			let a: Int = Int($0.points!)!
			let b: Int = Int($1.points!)!
			return a > b
		}
		
	}
	

	

	

}

extension ChartViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		guard self.searchBar != nil else {
			return 0
		}
		if searchBar!.isActive {
			return userCollectionFiltred.count
		}else {
			return userCollection.count
		}
		
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "user", for: indexPath) as! UserChartTableViewCell
        

		if searchBar!.isActive {
			cell.profileImage.image = userCollectionFiltred[indexPath.row].image
			cell.profileImage.contentMode = .scaleAspectFill
			cell.nicknameLabel.text = "\(indexPath.row + 1). \(userCollectionFiltred[indexPath.row].name ?? "Name")"
			cell.pointsLabel.text = "+\(userCollectionFiltred[indexPath.row].points ?? "0")"
            cell.positionLabel.isHidden = true
			cell.positionLabel.text = "\(indexPath.row + 1)."
			
			
			
			switch  userCollectionFiltred[indexPath.row].level {
				case 0:
					cell.level1.image = UIImage(named: "level_empty")
					cell.level2.image = UIImage(named: "level_empty")
					cell.level3.image = UIImage(named: "level_empty")
					cell.level4.image = UIImage(named: "level_empty")
					cell.level5.image = UIImage(named: "level_empty")
				case 1:
					cell.level1.image = UIImage(named: "level_fill")
					cell.level2.image = UIImage(named: "level_empty")
					cell.level3.image = UIImage(named: "level_empty")
					cell.level4.image = UIImage(named: "level_empty")
					cell.level5.image = UIImage(named: "level_empty")
				
				case 2:
					cell.level1.image = UIImage(named: "level_fill")
					cell.level2.image = UIImage(named: "level_fill")
					cell.level3.image = UIImage(named: "level_empty")
					cell.level4.image = UIImage(named: "level_empty")
					cell.level5.image = UIImage(named: "level_empty")
				case 3:
					cell.level1.image = UIImage(named: "level_fill")
					cell.level2.image = UIImage(named: "level_fill")
					cell.level3.image = UIImage(named: "level_fill")
					cell.level4.image = UIImage(named: "level_empty")
					cell.level5.image = UIImage(named: "level_empty")
				case 4:
					cell.level1.image = UIImage(named: "level_fill")
					cell.level2.image = UIImage(named: "level_fill")
					cell.level3.image = UIImage(named: "level_fill")
					cell.level4.image = UIImage(named: "level_fill")
					cell.level5.image = UIImage(named: "level_empty")
				case 5:
					cell.level1.image = UIImage(named: "level_fill")
					cell.level2.image = UIImage(named: "level_fill")
					cell.level3.image = UIImage(named: "level_fill")
					cell.level4.image = UIImage(named: "level_fill")
					cell.level5.image = UIImage(named: "level_fill")
				
				default:
					break
			}
			
		}else {
			cell.profileImage.image = userCollection[indexPath.row].image
			cell.profileImage.contentMode = .scaleAspectFill
            cell.nicknameLabel.text = "\(indexPath.row + 1). \(userCollection[indexPath.row].name ?? "Name")"
			cell.pointsLabel.text = "+\(userCollection[indexPath.row].points ?? "0")"
            cell.positionLabel.isHidden = true
			cell.positionLabel.text = "\(indexPath.row + 1)."
			
			
			
			switch  userCollection[indexPath.row].level {
				case 0:
                    cell.level1.image = UIImage(named: "level_empty")
                    cell.level2.image = UIImage(named: "level_empty")
                    cell.level3.image = UIImage(named: "level_empty")
                    cell.level4.image = UIImage(named: "level_empty")
                    cell.level5.image = UIImage(named: "level_empty")
                case 1:
                    cell.level1.image = UIImage(named: "level_fill")
                    cell.level2.image = UIImage(named: "level_empty")
                    cell.level3.image = UIImage(named: "level_empty")
                    cell.level4.image = UIImage(named: "level_empty")
                    cell.level5.image = UIImage(named: "level_empty")
                
                case 2:
                    cell.level1.image = UIImage(named: "level_fill")
                    cell.level2.image = UIImage(named: "level_fill")
                    cell.level3.image = UIImage(named: "level_empty")
                    cell.level4.image = UIImage(named: "level_empty")
                    cell.level5.image = UIImage(named: "level_empty")
                case 3:
                    cell.level1.image = UIImage(named: "level_fill")
                    cell.level2.image = UIImage(named: "level_fill")
                    cell.level3.image = UIImage(named: "level_fill")
                    cell.level4.image = UIImage(named: "level_empty")
                    cell.level5.image = UIImage(named: "level_empty")
                case 4:
                    cell.level1.image = UIImage(named: "level_fill")
                    cell.level2.image = UIImage(named: "level_fill")
                    cell.level3.image = UIImage(named: "level_fill")
                    cell.level4.image = UIImage(named: "level_fill")
                    cell.level5.image = UIImage(named: "level_empty")
                case 5:
                    cell.level1.image = UIImage(named: "level_fill")
                    cell.level2.image = UIImage(named: "level_fill")
                    cell.level3.image = UIImage(named: "level_fill")
                    cell.level4.image = UIImage(named: "level_fill")
                    cell.level5.image = UIImage(named: "level_fill")
				
				default:
					break
			}
		}
		
		
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
	
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if userCollection[indexPath.row].uid == Auth.auth().currentUser?.uid{
			
		
			guard let vc = storyboard?.instantiateViewController(identifier: "Home") as? HomeViewController else {return}
			tabBarController?.selectedIndex = 2
			print("TableView sono qui")
			navigationController?.pushViewController(vc, animated: true)
			navigationController?.popViewController(animated: true)
			
	
			
		} else {
			guard let vc = storyboard?.instantiateViewController(identifier: "follower") as? ProfileUserViewController else { return  }
			
			guard let vc2 = storyboard?.instantiateViewController(identifier: "joined") as? AchieveProfileViewController else { return  }
			
		
			
			if searchBar!.isActive {
				vc.uid = userCollectionFiltred[indexPath.row].uid
				vc2.uid = userCollectionFiltred[indexPath.row].uid
				
			} else{
				
				vc.uid = userCollection[indexPath.row].uid
				vc2.uid = userCollection[indexPath.row].uid
			}
			

			navigationController?.pushViewController(vc, animated: true)
		}
	
		
	}
	
	func switchToDataTab() {
		Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(switchToDataTabCont), userInfo: nil, repeats: false)
	}
	
	@objc func switchToDataTabCont(){
		
		
	}
	
	
}




extension ChartViewController {
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
