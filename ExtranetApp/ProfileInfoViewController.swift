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
    @IBOutlet weak var informationsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var labels = [String]()
    var images = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.18
        containerView.layer.shadowRadius = 10
        containerView.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        
        
        let border = CALayer()
        let width = CGFloat(0.5)
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: informationsLabel.frame.size.height - width, width:  informationsLabel.frame.size.width, height: informationsLabel.frame.size.height)
        
        border.borderWidth = width
        informationsLabel.layer.addSublayer(border)
        informationsLabel.layer.masksToBounds = true
        
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath) as UITableViewCell
        
        (cell.viewWithTag(6) as? UILabel)?.text = labels[indexPath.row]
        
        if indexPath.row != 4 {
            
            let image: UIImage = UIImage(named: images[indexPath.row])!
            
            (cell.viewWithTag(7) as? UIImageView)?.image = image
        }
        
        return cell
    }
}
