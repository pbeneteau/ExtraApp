//
//  ProfileViewController.swift
//  ExtranetApp
//
//  Created by antoine beneteau on 2017-06-06.
//  Copyright © 2017 Tastyapp. All rights reserved.
//

import UIKit
import Alamofire

class ProfileViewController: UIViewController {
    

    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 10)
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowRadius = 5
        
        nameLabel.text = student.getName()
        //picture.image = student.studentPicture


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
}
