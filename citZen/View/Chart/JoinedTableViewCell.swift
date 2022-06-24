//
//  JoinedTableViewCell.swift
//  citZen
//
//  Created by Luigi Mazzarella on 28/05/2020.
//  Copyright © 2020 Luigi Mazzarella. All rights reserved.
//

import UIKit

class JoinedTableViewCell: UITableViewCell {

	@IBOutlet weak var challengeImg: UIImageView!
	@IBOutlet weak var progileImg: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var cardFooter: UIImageView!
    @IBOutlet weak var internalCellView: UIView!
    @IBOutlet weak var externalCellView: UIView!
    
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
