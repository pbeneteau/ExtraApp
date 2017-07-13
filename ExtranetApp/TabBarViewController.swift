//
//  TabBarViewController.swift
//  ExtranetApp
//
//  Created by antoine beneteau on 2017-06-10.
//  Copyright © 2017 Tastyapp. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    let kBarHeight: CGFloat = 50

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.items![0].image = UIImage(named: "Marks")?.withRenderingMode(.alwaysOriginal)
        self.tabBar.items![0].selectedImage = UIImage(named: "Marks")
        self.tabBar.items![0].title = "Notes"

        self.tabBar.items![1].image = UIImage(named: "avatar-1")?.withRenderingMode(.alwaysOriginal)
        self.tabBar.items![1].selectedImage = UIImage(named: "avatar-1")
        self.tabBar.items![1].title = "Profile"
        
        self.tabBar.items![2].image = UIImage(named: "computers")?.withRenderingMode(.alwaysOriginal)
        self.tabBar.items![2].selectedImage = UIImage(named: "computers")
        self.tabBar.items![2].title = "Oridnateurs"
        
        self.tabBar.items![3].image = UIImage(named: "settings")?.withRenderingMode(.alwaysOriginal)
        self.tabBar.items![3].selectedImage = UIImage(named: "settings")
        self.tabBar.items![3].title = "Paramètres"
    }
    
    override func viewWillLayoutSubviews() {
        var tabFrame: CGRect = tabBar.frame
        //self.TabBar is IBOutlet of your TabBar
        tabFrame.size.height = kBarHeight
        tabFrame.origin.y = view.frame.size.height - kBarHeight
        tabBar.frame = tabFrame
    }
    
}
