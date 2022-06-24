//
//  TopicTableViewCell.swift
//  citZen
//
//  Created by Luigi Mazzarella on 20/05/2020.
//  Copyright © 2020 Luigi Mazzarella. All rights reserved.
//

import UIKit

class TopicTableViewCell: UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topic", for: indexPath)
		
		return cell
	}
	

	@IBOutlet weak var collectionView: UICollectionView!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
