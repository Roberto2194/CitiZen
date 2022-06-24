//
//  UserChartTableViewCell.swift
//  citZen
//
//  Created by Luigi Mazzarella on 23/05/2020.
//  Copyright © 2020 Luigi Mazzarella. All rights reserved.
//

import UIKit

class UserChartTableViewCell: UITableViewCell {

	@IBOutlet weak var profileImage: UIImageView!
	@IBOutlet weak var nicknameLabel: UILabel!
	@IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var internalCellView: UIView!
	@IBOutlet weak var externalCellView: UIView!
    
    @IBOutlet weak var level1: UIImageView!
    @IBOutlet weak var level2: UIImageView!
    @IBOutlet weak var level3: UIImageView!
    @IBOutlet weak var level4: UIImageView!
    @IBOutlet weak var level5: UIImageView!
    
	
    
	override func awakeFromNib() {
        super.awakeFromNib()
        self.heightAnchor.constraint(equalToConstant: 97).isActive = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
		
    }

}
