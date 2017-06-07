//
//  SemesterViewController.swift
//  ExtranetApp
//
//  Created by antoine beneteau on 2017-06-07.
//  Copyright © 2017 Tastyapp. All rights reserved.
//

import UIKit
import SwiftyJSON

class SemesterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var yearChoosed = 0
    var semesterJSON: JSON!
    
    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        semesterJSON = student.getMarks()[yearChoosed]["children"]
        
        self.tableview.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return semesterJSON.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "yearCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        
        (cell.viewWithTag(1) as! UILabel).text = semesterJSON[0]["Title"].stringValue
        
        return cell
    }
    


}
