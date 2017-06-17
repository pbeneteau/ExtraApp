//
//  ProfileInfoViewController.swift
//  ExtranetApp
//
//  Created by Paul Bénéteau on 09/06/2017.
//  Copyright © 2017 Tastyapp. All rights reserved.
//

import UIKit

class ProfileInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var birthDateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var labels = [String]()
    var images = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.18
        containerView.layer.shadowRadius = 10
        containerView.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        
        self.initProfileLabels()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initProfileLabels() {
        
        
        labels.append(student.getEmail())
        labels.append(student.getPhone())
        labels.append(student.getBirthDate())
        labels.append(student.getCity())
        labels.append(student.getAddress())
        
        images = ["close-envelope", "phone-receiver", "calendar", "home"]
        
        tableView.reloadData()

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "infoCell")
        
        (cell.viewWithTag(6) as? UILabel)?.text = labels[indexPath.row]
                
        if indexPath.row != 4 {
            
            let image: UIImage = UIImage(named: images[indexPath.row])!
            
            (cell.viewWithTag(7) as? UIImageView)?.image = image
        }
        
        return cell
    }
}
