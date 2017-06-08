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
    var marks = [String]()
    var weights = [String]()
    
    var detailViewOpen: Bool = false
    
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var matiereLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
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
        
        self.tableview.rowHeight = 90
        backButton.alpha = 0
        courseJSON = semesterJSON[courseSelected]["children"][0]
        
        initDetailview()
        
        initCourses()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.matiereLabel.frame.origin.x += 20
            self.subjectLabel.frame.origin.x += 20
            self.backButton.alpha = 1
        })
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
        if marksNumberLabel.text == "" {
            marksNumberLabel.text = "-"
        }
        averageMarksLabel.text = "\(courseJSON["GradePoint"].stringValue)"
        if averageMarksLabel.text == "" {
            averageMarksLabel.text = "-"
        }
        subjectWeightLabel.text = "\(courseJSON["Weight"].stringValue)"
        if subjectWeightLabel.text == "" {
            subjectWeightLabel.text = "-"
        }
    }
    
    func initCourses() {
        
        let course = courseJSON["children"]
        
        print(courseJSON)
        
        for i in 0..<course.count {
            
            var exam = removeSubjectName(text: (course[i]["Title"].stringValue))
            
            exam = exam.replacingOccurrences(of: "(", with: "")
            exam = exam.replacingOccurrences(of: ")", with: "")
            
            var mark = course[i]["MarkCode"].stringValue
            var weight = course[i]["Weight"].stringValue
            
            if weight == "" {
                weight = "-"
            }
            if mark == "" {
                mark = "-"
            }
            exams.append(exam)
            marks.append(mark)
            weights.append(weight)
        }
        print(exams)
        print(marks)
        print(weights)
        
        self.tableview.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "examCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! CourseTableViewCell
        
        cell.examTitleLabel.text = exams[indexPath.row]
        
        cell.examMarkLabel.text = marks[indexPath.row]
        cell.examCoeffLabel.text = "Coeff. \(weights[indexPath.row])"
        
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
        let str = text
        let p = str.indexDistance(of: "(")
        
        let endIndex = str.index(str.startIndex, offsetBy: p!)
        let truncated = str.substring(from: endIndex)
        
        return truncated
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

