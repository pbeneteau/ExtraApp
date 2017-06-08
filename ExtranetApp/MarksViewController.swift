//
//  MarksViewController.swift
//  ExtranetApp
//
//  Created by antoine beneteau on 2017-06-06.
//  Copyright © 2017 Tastyapp. All rights reserved.
//

import UIKit
import SwiftyJSON
import CZPicker

class MarksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CZPickerViewDelegate, CZPickerViewDataSource {
    
    
    private var rows = [String]()
    private var indexSelected = 0
    private var modulesArray = [String]()
    private var coursesArray: [Array<String>] = []
    private var picker: CZPickerView?
    private var semesters = [String]()
    private var selectedSemester: Int = 0

    
    @IBOutlet weak var semestreLabel: UILabel!
    
    @IBOutlet weak var tableview: UITableView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MarksViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.setToolbarHidden(true, animated: false)
        
        initCourses()
        initFilterView()

        tableview.addSubview(self.refreshControl)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexSelected = indexPath.row
        performSegue(withIdentifier: "semesterSegue", sender: nil)
    }
    
    // Sections names
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return modulesArray[section]
    }
    
    // Sections number
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return modulesArray.count
    }
    
    // Cells per section number
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return coursesArray[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "yearCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        cell.textLabel?.text = coursesArray[indexPath.section][indexPath.row]
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailController = segue.destination as? CourseViewController
        {
            detailController.courseSelected = indexSelected
            
            var semesterN = 0
            
            if selectedSemester == 1 {
                semesterN = 0
            } else {
                semesterN = 1
            }
            
            detailController.semesterJSON = student.getSemesters()[semesterN]
        }
    }
    
    func initCourses() {
        
        var semesterN = 0
        
        if selectedSemester == 1 {
            semesterN = 0
        } else {
            semesterN = 1
        }
        
        coursesArray.removeAll()
        modulesArray.removeAll()
        tableview.reloadData()
        
        let semesterP = student.getSemesters()[semesterN]
        
        print(student.getSemesters())
        
        for d in 0..<semesterP.count { // modules
            
            let module = semesterP[d]["Title"].stringValue
            modulesArray.append(removeOptionalInfos(text: module))
            
            let courses = semesterP[d]["children"]
            
            var moduleCourses = [String]()
            
            for e in 0..<courses.count { // courses
                
                let course = courses[e]["Title"].stringValue
                moduleCourses.append(removeOptionalInfos(text: course))
            }
            coursesArray.append(moduleCourses)
            moduleCourses.removeAll()
        }
        semestreLabel.text = "Semestre \(selectedSemester+1)"
        
        self.tableview.reloadData()
    }
    
    func initFilterView() {
        
        let semesterNames = student.getSemestersNamesList()
        
        for i in 0..<semesterNames.count {
            semesters.append("\(i+1) - \(removeOptionalInfos(text:semesterNames[i]))")
        }
    }
    
    func removeOptionalInfos(text: String) -> String {
        var str = text
        
        if let dotRange = str.range(of: "(") {
            str.removeSubrange(dotRange.lowerBound..<str.endIndex)
        }
        return str
    }
    
    @IBAction func showWithFooter(_ sender: AnyObject) {
        let picker = CZPickerView(headerTitle: "Semestres", cancelButtonTitle: "Annuler", confirmButtonTitle: "Confirmer")
        picker?.needFooterView = true
        picker?.delegate = self
        picker?.dataSource = self
        picker?.show()
    }
    
    
    // Semester Pikcer View
    
    func numberOfRows(in pickerView: CZPickerView!) -> Int {
        return semesters.count
    }
    
    func czpickerView(_ pickerView: CZPickerView!, titleForRow row: Int) -> String! {
        return semesters[row]
    }
    
    func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemAtRow row: Int){
        print(row)
        selectedSemester = row
        initCourses()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func czpickerViewDidClickCancelButton(_ pickerView: CZPickerView!) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        if Reachability.isConnectedToNetwork() == true
        {
            // Do some reloading of data and update the table view's data source
            // Fetch more objects from a web service, for example...
            
            student.refreshMarks { success in
                if success {
                    self.initCourses()
                    
                } else {
                    print("error while refreshing")
                }
                refreshControl.endRefreshing()
            }
        } else {
            let alert = UIAlertController(title: "Pas d'internet", message: "Verifiez votre connection", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in refreshControl.endRefreshing()}))
            self.present(alert, animated: true, completion: nil)
        }
    }
}


