//
//  CourseTableViewCell.swift
//  ExtranetApp
//
//  Created by Paul Bénéteau on 08/06/2017.
//  Copyright © 2017 Tastyapp. All rights reserved.
//

import UIKit

class CourseTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var examTitleLabel: UILabel!
    @IBOutlet weak var examCoeffLabel: UILabel!
    @IBOutlet weak var examMarkLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 10)
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowRadius = 5
        
        examTitleLabel.font = UIFont(name: "Roboto-Bold", size: 23)
        examCoeffLabel.font = UIFont(name: "Roboto-Medium", size: 18)
        examMarkLabel.font = UIFont(name: "Roboto-Bold", size: 45)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
