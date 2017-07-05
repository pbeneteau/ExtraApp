//
//  TabBarViewController.swift
//  ExtranetApp
//
//  Created by antoine beneteau on 2017-06-10.
//  Copyright © 2017 Tastyapp. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.items![0].image = UIImage(named: "cup")
        self.tabBar.items![0].selectedImage = UIImage(named: "cup")
        self.tabBar.items![0].title = "Notes"

        self.tabBar.items![1].image = UIImage(named: "user")
        self.tabBar.items![1].selectedImage = UIImage(named: "user")
    }
    
}
