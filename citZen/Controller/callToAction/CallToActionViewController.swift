//
//  CallToActionViewController.swift
//  citZen
//
//  Created by Luigi Mazzarella on 20/05/2020.
//  Copyright © 2020 Luigi Mazzarella. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class CallToActionViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {
	
	
	
	@IBOutlet weak var collection: UICollectionView!
	
	let ref = Database.database().reference()
	let refStorage = Storage.storage().reference()
	
	var challengeItems: [Challenge] = []
	var challengeItemsFiltred: [Challenge] = []
	var challengeUID: [String] = []
	var nation: String?
	var linkCreatorImg: String?
	var imageProfileView: UIImageView?
	var imageProfile: UIImage?
	
	var numberOfChallenge: Int?
	
	var vSpinner : UIView?
	var refreshControl = UIRefreshControl()
	var searchBar: UISearchController?
	
	@IBOutlet weak var segmentedControll: UISegmentedControl!
	
	@IBAction func segmentedControll(_ sender: UISegmentedControl) {
		
		switch sender.selectedSegmentIndex {
			case 0:
				showSpinner(onView: self.view)
				collection.reloadData()
				challengeItems = []
				searchBar?.searchBar.placeholder = "Search new call to action"
				loadChallengeInCall()
			
			
			case 1:
				showSpinner(onView: self.view)
				collection.reloadData()
				challengeItems = []
				searchBar?.searchBar.placeholder = "Search in progress call to action "
				loadChallengeInProgress()
			default:
				break
		}
	}
		
	override func viewDidLoad() {
		super.viewDidLoad()
	
		
		searchBar = ({
			let controller = UISearchController(searchResultsController: nil)
			controller.searchResultsUpdater = self
			controller.obscuresBackgroundDuringPresentation = false
			controller.searchBar.sizeToFit()
			if segmentedControll.selectedSegmentIndex == 0 {
				controller.searchBar.placeholder = "Search new call to action"
			}else {
				controller.searchBar.placeholder = "Search in progress call to action"
			}
			
			controller.searchBar.scopeButtonTitles = ["All", "energy", "waste", "water","digital","food","mobility"]
			
			
			navigationItem.searchController = controller
			
			return controller
		})()
		
	

		
		refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
		refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
		collection.addSubview(refreshControl)
		
		
		segmentedControll.selectedSegmentTintColor = .white
		let customBlue = UIColor(red: 0.2157, green: 0.2118, blue: 0.2941, alpha: 1.0) /* #37364b */
		let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
		segmentedControll.setTitleTextAttributes(titleTextAttributes, for:.normal)
		let titleTextAttributes1 = [NSAttributedString.Key.foregroundColor: customBlue]
		segmentedControll.setTitleTextAttributes(titleTextAttributes1, for:.selected)
		
		//Customizes the tab bar controller icons
		self.tabBarController?.tabBar.items![0].image = UIImage(named: "Artboard ICON CALL TO ACTION OUTLINE")
		self.tabBarController?.tabBar.items![0].selectedImage = UIImage(named: "Artboard ICON CALL TO ACTION")
		self.tabBarController?.tabBar.items![1].image = UIImage(named: "Artboard ICON CHART OUTLINE")
		self.tabBarController?.tabBar.items![1].selectedImage = UIImage(named: "Artboard ICON CHART")
		self.tabBarController?.tabBar.items![2].image = UIImage(named: "Artboard ICON PROFILE OUTLINE")
		self.tabBarController?.tabBar.items![2].selectedImage = UIImage(named: "Artboard ICON PROFILE")
	}
	
	func updateSearchResults(for searchController: UISearchController) {
		
		
		let scopes = searchBar!.searchBar.scopeButtonTitles
		let currentScope = scopes![searchBar!.searchBar.selectedScopeButtonIndex] as String
		self.filterContent(findText: searchBar!.searchBar.text!, scope: currentScope)
		
	}
	
	func filterContent(findText: String, scope: String) {
		
		challengeItemsFiltred.removeAll(keepingCapacity: true)
		for challenge in challengeItems{
			
			var justOne = false
			
			if  challenge.topic! == scope  {
				
				if (findText == "" || challenge.title!.lowercased().contains(findText.lowercased()) || challenge.nameUser!.lowercased().contains(findText.lowercased())) && justOne == false {
					
					challengeItemsFiltred.append(challenge)
					justOne = true
				}

				
			}
			if scope == "All" {
				if (challenge.topic!.lowercased().contains(findText.lowercased()) || challenge.title!.lowercased().contains(findText.lowercased()) || challenge.nameUser!.lowercased().contains(findText.lowercased())) && justOne == false {
					
					challengeItemsFiltred.append(challenge)
					justOne = true
					
				}
			}
			
			
			
			self.collection.reloadData()
		}
		return
	}

	
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		
		challengeItems = []
		collection.reloadData()
		
		showSpinner(onView: self.view)
		
		
		switch segmentedControll.selectedSegmentIndex {
			case 0:
				
				self.ref.child("UserProfile").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { snapshot in
					
					if let dictionary = snapshot.value as? [String: Any] {
						self.nation = dictionary["Location"] as? String
						self.loadChallengeInCall()
						
						
					}
					
				})
			
			
			
			case 1:
				
				self.ref.child("UserProfile").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { snapshot in
					
					if let dictionary = snapshot.value as? [String: Any] {
						self.nation = dictionary["Location"] as? String
						self.loadChallengeInProgress()
					}
					
				})
			default:
				break
		}
		
		
		
		
		
		
		
	}
	
	
	
	
	@objc func refresh(_ sender: AnyObject) {
		// Code to refresh table view
		if segmentedControll.selectedSegmentIndex == 0{
			challengeItems = []
			collection.reloadData()
			loadChallengeInCall()
			
		}else {
			challengeItems = []
			collection.reloadData()
			loadChallengeInProgress()
		}
	}
	
	func myChallenge(){
		challengeItems = []
		
		collection.reloadData()
		loadChallengeInProgress()
	}
	
	
	func addChallengeUID(uid: String){
		
		challengeUID.append(uid)
	}
	
	func loadChallengeJoin(AllUid: [String]){
		
		self.challengeItems = []
		self.challengeUID = []
		
		for uid in AllUid {
			self.ref.child("Challenge").child(self.nation!).child(uid).observeSingleEvent(of: .value, with: { snapshot in
				
				
				if let element = snapshot.value as? [String: AnyObject]{
					
					let currentData = Date()
					let formatter  = DateFormatter()
					let challengeDateString = element["date"] as? String
					formatter.dateStyle = .short
					formatter.locale = Locale(identifier: "en_US_POSIX")
					let today = formatter.string(from: currentData)
				
					
					
					guard let date1 = formatter.date(from: challengeDateString!) else {return}
					guard let date2 = formatter.date(from: today) else {return}
					
					let calendar = Calendar.current
					let components = calendar.dateComponents([ .month, .day, .year], from: date1)
					let challengeData = calendar.date(from: components)
					
					let components2 = calendar.dateComponents([.month,.day,.year], from: date2)
					
					let todayData = calendar.date(from: components2)
					
					
					
					
					if challengeData! < todayData! {
						self.ref.child("Challenge").child(self.nation!).child(uid).updateChildValues(["isOK":"false"])
					}
					
					print("challenge element \(element)")
					let challengeItem = Challenge()
					
					challengeItem.title = element["title"] as? String
					challengeItem.descriptionAction = element["descriptionAction"] as? String
					challengeItem.benefit = element["benefit"] as? String
					challengeItem.date = element["date"] as? String
					challengeItem.points = element["points"] as? String
					challengeItem.topic = element["topic"] as? String
					challengeItem.challengeUid = uid as String
					challengeItem.dateCreate = element["createDate"] as? String
					
					self.refStorage.child("ProfileImage").child((element["uidCreator"] as? String)!).getData(maxSize: 1*1024*1024){ data, error in
						
						print("challenge sono nel profilo")
						if error != nil {
							print(error!)
						}else {
							challengeItem.profileImg = UIImage(data: data!)
							self.ref.child("UserProfile").child(element["uidCreator"] as! String).observeSingleEvent(of: .value, with: { snap in
								
								guard let dic = snap.value as? [String:AnyObject] else {return}
								
								let name = dic["name"] as? String
								let surname = dic["surname"] as? String
								
								let fullname = "\(name!)  \(surname!)"
								
								challengeItem.nameUser = fullname
								
								print("CALL \(fullname)")
								challengeItem.typeUser = dic["Type"] as? String
								
								self.ref.child("Challenge").child(self.nation!).child(uid).child("Users").observeSingleEvent(of: .value, with: {
									snap in
									
									challengeItem.challengeNumber = String(snap.childrenCount)
									
									self.refStorage.child("Challenge").child(self.nation!).child(uid).getData(maxSize: 1*1024*1024){
										data, error in
										
										if error != nil{
											self.refreshControl.endRefreshing()
											print(error!)
										}else{
											challengeItem.challengeImg = UIImage(data: data!)
											self.assignElement(challenge: challengeItem)
											self.order()
											DispatchQueue.main.async {
												
												self.removeSpinner()
												self.refreshControl.endRefreshing()
												self.collection.reloadData()
												
											}
											
										}
									}
								})
								
								
								
								
							})
							
						}
						
						
					
						
					}
					
				}
				
			})
			
		}
		
	}
	
	func loadChallengeInProgress() {
		
		ref.child("UserProfile").child(Auth.auth().currentUser!.uid).child("Challenge").child(nation!).observeSingleEvent(of: .value, with: { snap in
			
			print("MYChallenge numero \(snap.childrenCount)")
			
			if snap.childrenCount != 0 {
				var count = 0
				for child in snap.children {
					
					guard let snap2 = child as? DataSnapshot else {return}
					
					guard let dic = snap2.value as? [String:AnyObject] else {return}
					
					if dic["complete"] as? String == nil {
						
						self.addChallengeUID(uid: snap2.key)
						self.loadChallengeJoin(AllUid: self.challengeUID)
						count += 1
					}
					
					
					
				}
				if count == 0 {
					self.removeSpinner()
				}
			} else {
				self.removeSpinner()
			}
			
		})
		
	}
	
	
	
	func loadChallengeInCall(){
		
		challengeItems = []
		
		self.refreshControl.endRefreshing()

		ref.child("Challenge").child(nation!).observeSingleEvent(of: .value, with: { snap in
			
			
			if snap.childrenCount == 0 {
				self.removeSpinner()
				self.refreshControl.endRefreshing()
			} else {
				var count = 0
				for child in snap.children {
					
					guard let snap2 = child as? DataSnapshot else {return}
					
					print("IDNEW \(snap2.key)")
					var exsist = false
					
					self.ref.child("Challenge").child(self.nation!).child(snap2.key).observeSingleEvent(of: .value, with: { snaphot in
						
						
						self.ref.child("UserProfile").child(Auth.auth().currentUser!.uid).child("Challenge").child(self.nation!).child(snap2.key).observeSingleEvent(of: .value, with: { snap in
							
							
							
							print("LoadChallenge sono entrato in profile")
							if snap.childrenCount != 0 {
								exsist = true
							}
							
							print("LoadChallenge sono exist \(exsist)")
							
							if !exsist {
								
								count += 1
								if let element = snaphot.value as? [String: AnyObject] {
									
									print("challenge element \(element)")
									let challengeItem = Challenge()
									
									
									let currentData = Date()
									let formatter  = DateFormatter()
									let challengeDateString = element["date"] as? String
									
									formatter.dateStyle = .short
									formatter.locale = Locale(identifier: "en_US_POSIX")
									
									let today = formatter.string(from: currentData)
									
									
									guard let date1 = formatter.date(from: challengeDateString!) else {return}
									guard let date2 = formatter.date(from: today) else {return}
									
									print("Date in \(date1) e \(date2)")
									
									let calendar = Calendar.current
									let components = calendar.dateComponents([ .month, .day, .year], from: date1)
									let challengeData = calendar.date(from: components)
									
									let components2 = calendar.dateComponents([.month,.day,.year], from: date2)
									
									let todayData = calendar.date(from: components2)
									
									print("Date challenge \(challengeData!) oggi \(todayData!) ")
									
									if challengeData! >= todayData! {
										print("Challenge is OK")
										challengeItem.title = element["title"] as? String
										challengeItem.descriptionAction = element["descriptionAction"] as? String
										challengeItem.benefit = element["benefit"] as? String
										challengeItem.date = element["date"] as? String
										challengeItem.challengeUid = snap2.key as String
										challengeItem.points = element["points"] as? String
										challengeItem.topic = element["topic"] as? String
										challengeItem.dateCreate = element["createDate"] as? String
										challengeItem.uidCreator = element["uidCreator"] as? String
										
										self.refStorage.child("ProfileImage").child((element["uidCreator"] as? String)!).getData(maxSize: 1*1024*1024){ data, error in
											
											print("challenge sono nel profilo")
											if error != nil {
												print(error!)
												self.refreshControl.endRefreshing()
											}else {
												challengeItem.profileImg = UIImage(data: data!)
												
												self.ref.child("UserProfile").child(element["uidCreator"] as! String).observeSingleEvent(of: .value, with: { snap in
													
													guard let dic = snap.value as? [String:AnyObject] else {return}
													
													let name = dic["name"] as? String
													let surname = dic["surname"] as? String
													
													let fullname = "\(name!)  \(surname!)"
													
													challengeItem.nameUser = fullname
													challengeItem.typeUser = dic["Type"] as? String
													
													self.refStorage.child("Challenge").child(self.nation!).child(snap2.key).getData(maxSize: 1*1024*1024){
														data, error in
														
														print("challenge sono nel immagine challenge")
														if error != nil{
															self.refreshControl.endRefreshing()
															print(error!)
														}else{
															challengeItem.challengeImg = UIImage(data: data!)
															self.assignElement(challenge: challengeItem)
															
															self.order()
															
															DispatchQueue.main.async{
																
																self.removeSpinner()
																self.collection.reloadData()
																
															}
															
															
														}
														
													}
													
												})
											}
											
											
											
										}
										self.ref.child("Challenge").child(self.nation!).child(snap2.key).child("Users").observeSingleEvent(of: .value, with: {
											snap in
											
											challengeItem.challengeNumber = String(snap.childrenCount)
										})
										
										
										
										
									}
										
									else {
										self.ref.child("Challenge").child(self.nation!).child(snap2.key).updateChildValues(["isOK":"false"])
									}

								}
								
							}
						})
						
						
					})
					
				}
			}
		})
		
	
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
	
	
	func assignElement(challenge: Challenge){
		
		challengeItems.append(challenge)
		
		
	}
	
	@IBAction func addCallToAction(_ sender: UIBarButtonItem) {
		let vc  = self.storyboard?.instantiateViewController(identifier: "actionCreate") as! CreateActionTableViewController
		let vcController = vc as UIViewController
		
		navigationController?.pushViewController(vcController, animated: true)
	}
	
}

extension CallToActionViewController: UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard self.searchBar != nil else {
			return 0
		}
		
		if  searchBar!.isActive {
			segmentedControll.isHidden = true
			return challengeItemsFiltred.count
		} else {
			segmentedControll.isHidden = false
			return challengeItems.count
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: collection.frame.width - 40, height: collection.frame.width - 40)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return .init(top: 15, left: 0, bottom: 15, right: 0)
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Challenge", for: indexPath) as! ChallengeCollectionViewCell
		
		// profile image rounded
		cell.profileCreator.layer.cornerRadius = 47
		cell.profileCreator.layer.borderWidth = 3
		cell.profileCreator.layer.borderColor = UIColor.white.cgColor
		cell.profileCreator.clipsToBounds = true
		
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
        
        
		if searchBar!.isActive {
			
			let challengeTopic = challengeItemsFiltred[indexPath.row].topic
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
			cell.topicCardImageView.image = UIImage(named: topicImage)
			cell.profileCreator.translatesAutoresizingMaskIntoConstraints = false
			cell.challengeImage.translatesAutoresizingMaskIntoConstraints = false
			cell.titleChallenge.text = challengeItemsFiltred[indexPath.row].title
			cell.Descripription.text = challengeItemsFiltred[indexPath.row].descriptionAction
			cell.topicLabel.text = challengeItemsFiltred[indexPath.row].topic
			cell.profileCreator.image = challengeItemsFiltred[indexPath.row].profileImg
			cell.profileCreator.contentMode = .scaleAspectFill
			cell.challengeImage.image = challengeItemsFiltred[indexPath.row].challengeImg
			cell.challengeImage.contentMode = .scaleAspectFill
			cell.userName.text = challengeItemsFiltred[indexPath.row].nameUser
			cell.userType.text = challengeItemsFiltred[indexPath.row].typeUser
			cell.peopleJoinedNumber.text = challengeItemsFiltred[indexPath.row].challengeNumber
			
			
			return cell
			
		}else {
			
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
			
			cell.topicCardImageView.image = UIImage(named: topicImage)
			cell.profileCreator.translatesAutoresizingMaskIntoConstraints = false
			cell.challengeImage.translatesAutoresizingMaskIntoConstraints = false
			cell.titleChallenge.text = challengeItems[indexPath.row].title
			cell.Descripription.text = challengeItems[indexPath.row].descriptionAction
			cell.topicLabel.text = challengeItems[indexPath.row].topic
			cell.profileCreator.image = challengeItems[indexPath.row].profileImg
			cell.profileCreator.contentMode = .scaleAspectFill
			cell.challengeImage.image = challengeItems[indexPath.row].challengeImg
			cell.challengeImage.contentMode = .scaleAspectFill
			cell.userName.text = challengeItems[indexPath.row].nameUser
			cell.userType.text = challengeItems[indexPath.row].typeUser
			cell.peopleJoinedNumber.text = challengeItems[indexPath.row].challengeNumber
			
			
			return cell
			
		}
		
		
		
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
	
		let vc = self.storyboard?.instantiateViewController(identifier: "join") as! JoinChallengeViewController
		
		if searchBar!.isActive {
			vc.challengeUID = challengeItemsFiltred[indexPath.row]
			
		} else{
			
			vc.challengeUID = challengeItems[indexPath.row]
		}
			
		vc.nation = self.nation
		if segmentedControll.selectedSegmentIndex == 0 {
			vc.join = false
			vc.complete = true
		}else {
			vc.join = true
			vc.complete = false
		}
		navigationController?.pushViewController(vc, animated: true)
	}
	
	
}



extension CallToActionViewController {
	
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
