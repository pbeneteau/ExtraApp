//
//  ProfileViewController.swift
//  ExtranetApp
//
//  Created by antoine beneteau on 2017-06-06.
//  Copyright © 2017 Tastyapp. All rights reserved.
//

import UIKit
import Alamofire
import UserNotificationsUI
import UserNotifications

class ProfileViewController: UIViewController {
    
    let requestIdentifier = "SampleRequest"

    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = student.getName()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    @IBAction func logOutButtonPressed(_ sender: Any) {
        if (userDefaults.string(forKey: "isLogged") != nil) {
            userDefaults.set("notLogged", forKey: "isLogged")
            
            moveToLogin()
        }
    }
    
}

