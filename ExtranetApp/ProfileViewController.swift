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
import Whisper

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var msgDisplayed = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = student.getName()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if Reachability.isConnectedToNetwork() == false && msgDisplayed == 0{
            
            var murmur = Murmur(title: "Pas de connexion: Mode hors ligne")
            murmur.backgroundColor = UIColor(red:0.20, green:0.29, blue:0.37, alpha:1.0)
            murmur.titleColor = UIColor.white
            
            // Show and hide a message after delay
            Whisper.show(whistle: murmur, action: .show(5))
            
            msgDisplayed = 1
        }
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

