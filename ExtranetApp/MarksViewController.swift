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
    private var sectionSelected = 0
    private var modulesArray = [String]()
    private var coursesArray: [Array<String>] = []
    private var picker: CZPickerView?
    private var semesters = [String]()
    private var selectedSemester: Int = 0
    private var averageArray = [String]()
    private var averagesArray: [Array<String>] = []
    
    var indicatorView: UIActivityIndicatorView! = nil
    
    @IBOutlet weak var semestreLabel: UILabel!
    
    @IBOutlet weak var tableview: UITableView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MarksViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initActivityIndicatorView()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.setToolbarHidden(true, animated: false)
        
        loadData()
        
        tableview.addSubview(self.refreshControl)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        
        indicatorView.startAnimating()
        indicatorView.isHidden = false
        
        student.loadSemestersFromUserDefaults()
        
        notificationsUtils.setLoadedmarks(json: student.getSemesters())
        
        student.loadStudentData { success in
            if success {
                self.initCourses()
                self.initFilterView()
                notificationsUtils.initNotifications()
            } else {
                print("loadStudentData: No internet connexion")
                
                self.initCourses()
                self.initFilterView()
            }
            self.indicatorView.stopAnimating()
        }
    }
    
    func initActivityIndicatorView() {
        
        self.indicatorView = UIActivityIndicatorView(frame: CGRect(x: UIScreen.main.bounds.size.width / 2 - 10, y: UIScreen.main.bounds.size.height / 2 - 10, width: 20, height: 20))
        
        self.view.addSubview(indicatorView)
        indicatorView.color = UIColor.black

    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indexPath = self.tableview.indexPathForSelectedRow {
            
            sectionSelected = indexPath.section
            indexSelected = indexPath.row
            
            print("Section: \(sectionSelected), indexSelected: \(indexSelected)")
        }
        performSegue(withIdentifier: "semesterSegue", sender: nil)
    }
    
    // Sections names
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return modulesArray[section]
    }
    
    // Sections number
    func numberOfSections(in tableView: UITableView) -> Int {
        return modulesArray.count
    }
    
    // Cells per section number
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coursesArray[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "yearCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        (cell.viewWithTag(2) as! UILabel).text = coursesArray[indexPath.section][indexPath.row]
        //(cell.viewWithTag(4) as! UILabel).text = averagesArray[indexPath.section][indexPath.row]
        cell.selectionStyle = .none
        
        (cell.viewWithTag(10)! as UIView).layer.shadowColor = UIColor.black.cgColor
        (cell.viewWithTag(10)! as UIView).layer.shadowOffset = CGSize(width: 0, height: 10)
        (cell.viewWithTag(10)! as UIView).layer.shadowOpacity = 0.1
        (cell.viewWithTag(10)! as UIView).layer.shadowRadius = 5
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = (Bundle.main.loadNibNamed("ModuleSectionView", owner: self, options: nil)?[0] as? UIView)
        
        (view?.viewWithTag(4) as! UILabel).text = modulesArray[section]
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailController = segue.destination as? CourseViewController
        {
            detailController.semesterJSON = student.getSemesters()[selectedSemester]
            detailController.subjectSelected = sectionSelected
            detailController.courseSelected = indexSelected
        }
    }
    
    func initCourses() {
        
        coursesArray.removeAll()
        modulesArray.removeAll()
        tableview.reloadData()
        
        let semesterP = student.getSemesters()[selectedSemester]
        
        for d in 0..<semesterP.count { // modules
            
            print(semesterP[d])
            
            let module = semesterP[d]["Title"].stringValue
            modulesArray.append(removeOptionalInfos(text: module))
            
            let average = semesterP[d]["MarkCode"].stringValue
            averageArray.append(average)
            
            let courses = semesterP[d]["children"]
            
            var moduleCourses = [String]()
            
            for e in 0..<courses.count { // courses
                
                let course = courses[e]["Title"].stringValue
                moduleCourses.append(removeOptionalInfos(text: course))
            }
            averagesArray.append(averageArray)
            coursesArray.append(moduleCourses)
            moduleCourses.removeAll()
        }
        let semesterList = student.getSemestersNamesList()
        semestreLabel.text = "\(semesterList[selectedSemester])"
        
        self.tableview.reloadData()
    }
    
    func initFilterView() {
        
        let semesterNames = student.getSemestersNamesList()
        
        for i in 0..<semesterNames.count {
            
            var semesterName = "\(semesterNames.count - i) - \(removeOptionalInfos(text:semesterNames[i]))"
            semesterName = semesterName.replacingOccurrences(of: " Groupe Efrei", with: "")
            semesterName = semesterName.replacingOccurrences(of: " Efrei", with: "")
            
            semesters.append(semesterName)
        }
        
        picker = CZPickerView(headerTitle: "Semestres", cancelButtonTitle: "Annuler", confirmButtonTitle: "Confirmer")
        picker?.headerBackgroundColor = UIColor(red:0.21, green:0.95, blue:0.59, alpha:1.0)
        picker?.checkmarkColor = UIColor(red:0.21, green:0.95, blue:0.59, alpha:1.0)
        picker?.confirmButtonBackgroundColor = UIColor(red:0.21, green:0.95, blue:0.59, alpha:1.0)
        picker?.allowMultipleSelection = false
        picker?.needFooterView = true
        picker?.delegate = self
        picker?.dataSource = self
    }
    
    func removeOptionalInfos(text: String) -> String {
        var str = text
        
        if let dotRange = str.range(of: "(") {
            str.removeSubrange(dotRange.lowerBound..<str.endIndex)
        }
        return str
    }
    
    // Semester Pikcer View
    @IBAction func showWithFooter(_ sender: AnyObject) {
        picker?.setSelectedRows([selectedSemester])
        picker?.show()
    }
    
    func numberOfRows(in pickerView: CZPickerView!) -> Int {
        return semesters.count
    }
    
    func czpickerView(_ pickerView: CZPickerView!, titleForRow row: Int) -> String! {
        return semesters[row]
    }
    
    func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemAtRow row: Int){
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


