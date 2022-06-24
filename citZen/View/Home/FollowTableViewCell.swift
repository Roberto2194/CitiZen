//
//  FollowTableViewCell.swift
//  citZen
//
//  Created by Domenico Varchetta on 04/06/2020.
//  Copyright © 2020 Luigi Mazzarella. All rights reserved.
//

import UIKit

class FollowTableViewCell: UITableViewCell {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var internalCellView: UIView!
    @IBOutlet weak var externalCellView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.heightAnchor.constraint(equalToConstant: 97).isActive = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
