//
//  CalendarViewController.swift
//  ExtranetApp
//
//  Created by antoine beneteau on 2017-06-12.
//  Copyright © 2017 Tastyapp. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var calendarLabel: UILabel!
    
    private var canDownload: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.18
        containerView.layer.shadowRadius = 10
        containerView.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        
        let border = CALayer()
        let width = CGFloat(0.5)
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: calendarLabel.frame.size.height - width, width:  calendarLabel.frame.size.width, height: calendarLabel.frame.size.height)
        
        border.borderWidth = width
        calendarLabel.layer.addSublayer(border)
        calendarLabel.layer.masksToBounds = true
        
        student.initCalendarLink { (success,isTimedUot) in
            if success {
                self.canDownload = true
            } else {
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func downloadButtonPressed(_ sender: Any) {
        if canDownload {
            let url = NSURL(string: student.getCalendarLink())
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url! as URL)
            } else {
                UIApplication.shared.openURL(url! as URL)
            }
        }
    }

}
