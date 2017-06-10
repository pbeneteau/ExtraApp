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

        self.tabBar.items![0].image = UIImage(named: "user")
        self.tabBar.items![0].selectedImage = UIImage(named: "user")
        
        self.tabBar.items![1].image = UIImage(named: "cup")
        self.tabBar.items![1].selectedImage = UIImage(named: "cup")
        self.tabBar.items![1].title = "Notes"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
