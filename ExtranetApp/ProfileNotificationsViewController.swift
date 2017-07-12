//
//  ProfileNotificationsViewController.swift
//  ExtranetApp
//
//  Created by Paul Bénéteau on 09/06/2017.
//  Copyright © 2017 Tastyapp. All rights reserved.
//

import UIKit

class ProfileNotificationsViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var notificationsArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.18
        containerView.layer.shadowRadius = 7
        containerView.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        containerView.layer.shouldRasterize = true
        containerView.layer.rasterizationScale = UIScreen.main.scale
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(initTableview), name: NSNotification.Name(rawValue: "reloadNotificationsTableView"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        initTableview()        
    }
    
    func initTableview() {
        
        notificationsArray = notificationsUtils.getNotifications()
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "notifCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        cell?.textLabel?.text = notificationsArray[indexPath.row]
        cell?.selectionStyle = .none
        
        
        return cell!
    }
}
