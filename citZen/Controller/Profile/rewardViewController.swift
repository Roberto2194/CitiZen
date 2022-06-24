//
//  rewardViewController.swift
//  citZen
//
//  Created by Muigi Lazzarella on 28/05/2020.
//  Copyright © 2020 Luigi Mazzarella. All rights reserved.
//

import UIKit
import Firebase

class rewardViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var energyPoints: UILabel!
    @IBOutlet weak var digitalPoints: UILabel!
    @IBOutlet weak var foodPoints: UILabel!
    @IBOutlet weak var mobilityPoints: UILabel!
    @IBOutlet weak var waterPoints: UILabel!
    @IBOutlet weak var wastePoints: UILabel!
    @IBOutlet weak var totalPoints: UILabel!
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var level1: UIImageView!
    @IBOutlet weak var level2: UIImageView!
    @IBOutlet weak var level3: UIImageView!
    @IBOutlet weak var level4: UIImageView!
    @IBOutlet weak var level5: UIImageView!
    
    let badges = ["energyBadge", "mobilityBadge", "waterBadge", "wasteBadge", "digitalBadge", "foodBadge"]
    var badgesPoint: [String] = []
	
	let refDatabase = Database.database().reference().child("UserProfile").child(Auth.auth().currentUser!.uid)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.myCollectionView.dataSource = self
        self.myCollectionView.delegate = self
    }
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		overrideUserInterfaceStyle = .light
        loadPoints()
	}
    

	func loadPoints(){
		
		refDatabase.observeSingleEvent(of: .value, with: { snap in
			
			guard let dic = snap.value as? [String:AnyObject] else {return}
			
            self.badgesPoint = []
            
			self.total.text = "+\(dic["points"] as? String ?? "0")"
            
            let points: Int = Int(dic["points"] as? String ?? "0") ?? 0
            switch points {
                case 0 ... 9:
                    self.level1.image = UIImage(systemName: "1.circle")
                    self.level2.image = UIImage(systemName: "2.circle")
                    self.level3.image = UIImage(systemName: "3.circle")
                    self.level4.image = UIImage(systemName: "4.circle")
                    self.level5.image = UIImage(systemName: "5.circle")
                    self.level1.tintColor = .lightGray
                    self.level2.tintColor = .lightGray
                    self.level3.tintColor = .lightGray
                    self.level4.tintColor = .lightGray
                    self.level5.tintColor = .lightGray
                case 10 ... 29:
                    self.level1.image = UIImage(systemName: "1.circle.fill")
                    self.level2.image = UIImage(systemName: "2.circle")
                    self.level3.image = UIImage(systemName: "3.circle")
                    self.level4.image = UIImage(systemName: "4.circle")
                    self.level5.image = UIImage(systemName: "5.circle")
                    self.level2.tintColor = .lightGray
                    self.level3.tintColor = .lightGray
                    self.level4.tintColor = .lightGray
                    self.level5.tintColor = .lightGray
                case 30 ... 49:
                    self.level1.image = UIImage(systemName: "1.circle.fill")
                    self.level2.image = UIImage(systemName: "2.circle.fill")
                    self.level3.image = UIImage(systemName: "3.circle")
                    self.level4.image = UIImage(systemName: "4.circle")
                    self.level5.image = UIImage(systemName: "5.circle")
                    self.level3.tintColor = .lightGray
                    self.level4.tintColor = .lightGray
                    self.level5.tintColor = .lightGray
                case 50 ... 79:
                    self.level1.image = UIImage(systemName: "1.circle.fill")
                    self.level2.image = UIImage(systemName: "2.circle.fill")
                    self.level3.image = UIImage(systemName: "3.circle.fill")
                    self.level4.image = UIImage(systemName: "4.circle")
                    self.level5.image = UIImage(systemName: "5.circle")
                    self.level4.tintColor = .lightGray
                    self.level5.tintColor = .lightGray
                case 80 ... 119:
                    self.level1.image = UIImage(systemName: "1.circle.fill")
                    self.level2.image = UIImage(systemName: "2.circle.fill")
                    self.level3.image = UIImage(systemName: "3.circle.fill")
                    self.level4.image = UIImage(systemName: "4.circle.fill")
                    self.level5.image = UIImage(systemName: "5.circle")
                    self.level5.tintColor = .lightGray
                case 120... :
                    self.level1.image = UIImage(systemName: "1.circle.fill")
                    self.level2.image = UIImage(systemName: "2.circle.fill")
                    self.level3.image = UIImage(systemName: "3.circle.fill")
                    self.level4.image = UIImage(systemName: "4.circle.fill")
                    self.level5.image = UIImage(systemName: "5.circle.fill")
                
                default:
                    break
            }
            
            self.badgesPoint.append("+\(dic["energyPoints"] as? String ?? "0")")
            self.badgesPoint.append("+\(dic["mobilityPoints"] as? String ?? "0")")
            self.badgesPoint.append("+\(dic["waterPoints"] as? String ?? "0")")
            self.badgesPoint.append("+\(dic["wastePoints"] as? String ?? "0")")
            self.badgesPoint.append("+\(dic["digitalPoints"] as? String ?? "0")")
            self.badgesPoint.append("+\(dic["foodPoints"] as? String ?? "0")")
            self.myCollectionView.reloadData()
			
		})
		
	}
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return badgesPoint.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "personalProfileBadgesCell", for: indexPath) as! ProfileCollectionCell
        
        // cell rounded section
        cell.layer.borderWidth = 5.0
        cell.layer.borderColor = UIColor.clear.cgColor
        
        // cell shadow section
        cell.contentView.layer.cornerRadius = 18.0
        cell.contentView.layer.borderWidth = 30.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        cell.layer.shadowRadius = 6.0
        cell.layer.shadowOpacity = 0.6
        cell.layer.cornerRadius = 18.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        
        cell.badgeImage.image = UIImage(named: badges[indexPath.item])
        cell.badgePoints.text = badgesPoint[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width/3) - 20, height: 140)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 55, left: 15, bottom: 15, right: 15)
    }

}
