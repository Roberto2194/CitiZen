//
//  HomeChallengeTableViewCell.swift
//  citZen
//
//  Created by Luigi Mazzarella on 27/05/2020.
//  Copyright © 2020 Luigi Mazzarella. All rights reserved.
//

import UIKit

class HomeChallengeTableViewCell: UITableViewCell {

	@IBOutlet weak var challengeImg: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var userType: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var internalCellView: UIView!
    @IBOutlet weak var externalCellView: UIView!
    @IBOutlet weak var peopleJoinedNumber: UILabel!
    @IBOutlet weak var cardFooter: UIImageView!
    
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
