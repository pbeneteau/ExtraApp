//
//  ProfileInfoViewController.swift
//  ExtranetApp
//
//  Created by Paul Bénéteau on 08/06/2017.
//  Copyright © 2017 Tastyapp. All rights reserved.
//

import UIKit
import Tabman
import Pageboy

class ProfileDetailsViewController: TabmanViewController, PageboyViewControllerDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        
        bar.appearance = TabmanBar.Appearance({ (appearance) in
            appearance.indicator.color = UIColor(red:0.21, green:0.95, blue:0.59, alpha:1.0)
            appearance.style.background = .clear
        })
        bar.style = .bar
        bar.location = .top
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func viewControllers(forPageboyViewController pageboyViewController: PageboyViewController) -> [UIViewController]? {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let viewController1 = storyBoard.instantiateViewController(withIdentifier: "profileInfo")
        let viewController2 = storyBoard.instantiateViewController(withIdentifier: "profileNotifications")
        
        // return array of view controllers
        let viewControllers = [viewController1, viewController2]
        
        // configure the bar
        self.bar.items = [TabmanBarItem(title: "Page 1"),
                          TabmanBarItem(title: "Page 2")]
        
        return viewControllers
    }
    
    func defaultPageIndex(forPageboyViewController pageboyViewController: PageboyViewController) -> PageboyViewController.PageIndex? {
        // use default index
        return nil
    }
    
    

}
