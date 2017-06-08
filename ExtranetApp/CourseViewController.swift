//
//  SemesterViewController.swift
//  ExtranetApp
//
//  Created by antoine beneteau on 2017-06-07.
//  Copyright © 2017 Tastyapp. All rights reserved.
//

import UIKit
import SwiftyJSON
import DynamicButton

class CourseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var courseSelected = 0
    var semesterJSON: JSON!
    var courseJSON: JSON!
    var subjectName: String = ""
    var exams = [String]()
    
    var detailViewOpen: Bool = false
    
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var lineView: UIView!
    
    @IBOutlet weak var marksLabel: UILabel!
    @IBOutlet weak var marksNumberLabel: UILabel!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var averageMarksLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var subjectWeightLabel: UILabel!
    
    @IBOutlet weak var showDetailButton: DynamicButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        courseJSON = semesterJSON[courseSelected]["children"][0]
        
        initDetailview()
        
        initCourses()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initDetailview() {
        
        let labels = [marksLabel, marksNumberLabel, averageLabel, averageMarksLabel, weightLabel, subjectWeightLabel]
        
        for label in labels {
            label?.isHidden = true
            label?.alpha = 1
        }
        lineView.isHidden = true
        lineView.alpha = 0
        
        detailView.frame.size.height = 110
        showDetailButton.frame.origin.y = 80
        showDetailButton.setStyle(.caretDown, animated: false)
        showDetailButton.alpha = 0.7
        tableview.frame.origin.y = 110
        
        // Values
        
        subjectName = removeOptionalInfos(text: courseJSON["Title"].stringValue)
        
        subjectLabel.text = subjectName
        marksNumberLabel.text = "\(courseJSON["children"].count)"
        averageMarksLabel.text = "\(courseJSON["AverageMark"].stringValue)"
        subjectWeightLabel.text = "\(courseJSON["Weight"].stringValue)"
    }
    
    func initCourses() {
        
        let course = courseJSON["children"]
        
        print(courseJSON)
        
        for i in 0..<course.count {
            
            let exam = course[i]["Title"].stringValue
            var examString = exam.replacingOccurrences(of: subjectName, with: "")
            examString = exam.replacingOccurrences(of: "(", with: "")
            examString = exam.replacingOccurrences(of: ")", with: "")
            
            exams.append(examString)
        }
        print(exams)
        
        self.tableview.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "yearCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        
        cell.textLabel?.text = exams[indexPath.row]
        
        return cell
    }
    
    
    func removeOptionalInfos(text: String) -> String {
        var str = text
        
        if let dotRange = str.range(of: "(") {
            str.removeSubrange(dotRange.lowerBound..<str.endIndex)
        }
        return str
    }
    
    func removeSubjectName(text: String) -> String {
        var str = text
        
        if let dotRange = str.range(of: "(") {
           // str.substring(to: dotRange)
        }
        return str
    }
    @IBAction func showDetailviewAction(_ sender: Any) {
        
        let labels = [marksLabel, marksNumberLabel, averageLabel, averageMarksLabel, weightLabel, subjectWeightLabel]
        
        
        
        if detailViewOpen == true {
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                
                for label in labels {
                    label?.alpha = 0
                    
                }
                self.lineView.alpha = 0
                
                
            })
            UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
                
                
                self.detailView.frame.size.height = 110
                
                self.tableview.frame.origin.y -= 88
                self.showDetailButton.frame.origin.y -= 88
                
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                self.lineView.isHidden = true
                
                for label in labels {
                    label?.isHidden = true
                }
                self.showDetailButton.setStyle(.caretDown, animated: true)
            })
            
            detailViewOpen = false
            
        } else {
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                
                self.lineView.isHidden = false
                self.lineView.alpha = 1
                
                self.detailView.frame.size.height = 198
                
                
                self.tableview.frame.origin.y += 88
                self.showDetailButton.frame.origin.y += 88
                
            })
            UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseOut, animations: {
                
                for label in labels {
                    label?.isHidden = false
                    label?.alpha = 1
                }
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.showDetailButton.setStyle(.caretUp, animated: true)
            })
            detailViewOpen = true
        }
    }
}
