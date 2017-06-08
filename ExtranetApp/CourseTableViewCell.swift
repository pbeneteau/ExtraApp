//
//  CourseTableViewCell.swift
//  ExtranetApp
//
//  Created by Paul Bénéteau on 08/06/2017.
//  Copyright © 2017 Tastyapp. All rights reserved.
//

import UIKit

class CourseTableViewCell: UITableViewCell {

    @IBOutlet weak var examTitleLabel: UILabel!
    @IBOutlet weak var examCoeffLabel: UILabel!
    @IBOutlet weak var examMarkLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
