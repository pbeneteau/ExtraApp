//
//  CalendarViewController.swift
//  ExtranetApp
//
//  Created by antoine beneteau on 2017-06-12.
//  Copyright © 2017 Tastyapp. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController {

    @IBOutlet weak var downloadButton: UIButton!
    private var canDownload: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        student.initCalendarLink { (success,isTimedUot) in
            if success {
                self.canDownload = true
            } else {
                print("ddd")
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
