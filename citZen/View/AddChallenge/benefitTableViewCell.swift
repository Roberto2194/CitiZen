//
//  benefitTableViewCell.swift
//  citZen
//
//  Created by Luigi Mazzarella on 20/05/2020.
//  Copyright © 2020 Luigi Mazzarella. All rights reserved.
//

import UIKit

class benefitTableViewCell: UITableViewCell {

	@IBOutlet weak var benefitField: UITextField!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
