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

    
    @IBOutlet weak var semestreLabel: UILabel!
    
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initCourses(semester: 0)
        initFilterView()

        
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
        if let detailController = segue.destination as? SemesterViewController
        {
            detailController.yearChoosed = indexSelected
        }
    }
    
    func initCourses(semester: Int) {
        
        coursesArray.removeAll()
        modulesArray.removeAll()
        tableview.reloadData()
        
        let semesterP = student.getSemesters()[semester]
        
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
    
    
    func numberOfRows(in pickerView: CZPickerView!) -> Int {
        return semesters.count
    }
    
    func czpickerView(_ pickerView: CZPickerView!, titleForRow row: Int) -> String! {
        return semesters[row]
    }
    
    func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemAtRow row: Int){
        print(semesters[row])
        initCourses(semester: row)
        semestreLabel.text = "Semestre \(row+1)"
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func czpickerViewDidClickCancelButton(_ pickerView: CZPickerView!) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    
}


