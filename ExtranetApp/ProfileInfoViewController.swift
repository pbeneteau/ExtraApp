//
//  ProfileInfoViewController.swift
//  ExtranetApp
//
//  Created by Paul Bénéteau on 09/06/2017.
//  Copyright © 2017 Tastyapp. All rights reserved.
//

import UIKit

class ProfileInfoViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var birthDateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 10)
        containerView.layer.shadowOpacity = 0.2
        containerView.layer.shadowRadius = 5
        
        if student.isUserInfosSavedinUserDefaults() == true {
            print("Using userDefaults data")
            self.initProfileLabels()
        } else {
            student.initInfos { success in
                if success {
                    self.initProfileLabels()
                } else {
                    print("initInfos: No internet connexion")
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initProfileLabels() {
        
        self.birthDateLabel.text = student.getBirthDate()
        self.addressLabel.text = student.getAddress()
        self.cityLabel.text = student.getCity()
        self.phoneLabel.text = student.getPhone()
        self.emailLabel.text = student.getEmail()
    }
}