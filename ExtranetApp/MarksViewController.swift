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
import Whisper

class MarksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CZPickerViewDelegate, CZPickerViewDataSource {
    
    private var rows = [String]()
    private var indexSelected = 0
    private var sectionSelected = 0
    private var modulesArray = [String]()
    private var coursesArray: [Array<String>] = []
    private var picker: CZPickerView?
    private var semesters = [String]()
    private var selectedSemester: Int = 0
    private var averagesArray = [String]()
    private var averagesSectionArray: [Array<String>] = []
    private var coeffSesctionArray = [String]()
    private var newMarksNotifications = [[Int]]()
    
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
        
        student.loadSemestersFromUserDefaults { success in
            if success { // Bien load
                if student.getSemesters().count > 0 {
                    notificationsUtils.setLoadedmarks(json: student.getSemesters())
                }
            } else { // Pas load ou rien a Load
                
            }
        }
        
        student.loadStudentData { (success, isTimedOut) in
            if success {
                self.initFilterView()
                if student.getSemesters().count > 0 {
                    notificationsUtils.initNotifications()
                }
                self.initCourses()
            } else if isTimedOut {
                showAlert(title: "Attention", message: "Mauvaise connexion internet", color: UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0), sender: self)
            } else {
                student.loadSemestersFromUserDefaults { success in
                    if success { // Bien load
                        if (userDefaults.string(forKey: "noConnectionModeAlready") != nil) {
                            if (userDefaults.string(forKey: "noConnectionModeAlready")! != "yes") {
                                showAlert(title: "Remarque", message: "Vous n'avez pas de connexion internet \n Les notes ne sont donc pas mises à jour", color: UIColor(red:0.20, green:0.60, blue:0.86, alpha:1.0), sender: self)
                            }
                        } else {
                            userDefaults.set("yes", forKey: "noConnectionModeAlready")
                            showAlert(title: "Remarque", message: "Vous n'avez pas de connexion internet \n Les notes ne sont donc pas mises à jour", color: UIColor(red:0.20, green:0.60, blue:0.86, alpha:1.0), sender: self)
                        }
                        self.initCourses()
                        self.initFilterView()
                    } else { // Pas load ou rien a Load
                        showAlert(title: "Attention", message: "Pas de connexion \n Et aucune note chargée", color: UIColor(red:0.21, green:0.95, blue:0.59, alpha:1.0), sender: self)
                    }
                }
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
            var i = 0
            for path in newMarksNotifications {

                if path[1] == sectionSelected && path[2] == indexSelected {
                    newMarksNotifications.remove(at: i)
                    self.tableview.reloadData()
                }
                i += 1
            }
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
        (cell.viewWithTag(4) as! UILabel).text = averagesSectionArray[indexPath.section][indexPath.row]
        cell.selectionStyle = .none
        
        (cell.viewWithTag(10)! as UIView).layer.shadowColor = UIColor.black.cgColor
        (cell.viewWithTag(10)! as UIView).layer.shadowOpacity = 0.18
        (cell.viewWithTag(10)! as UIView).layer.shadowRadius = 6
        (cell.viewWithTag(10)! as UIView).layer.shadowOffset = CGSize(width: 0, height: 5.0)
        (cell.viewWithTag(6)! as UIView).layer.cornerRadius = (cell.viewWithTag(6)! as UIView).frame.height / 2
        (cell.viewWithTag(6)! as UIView).isHidden = true
        
        for i in 0..<newMarksNotifications.count {
            if newMarksNotifications[i][0] == selectedSemester{
                if newMarksNotifications[i][1] == indexPath.section {
                    if newMarksNotifications[i][2] == indexPath.row {
                        (cell.viewWithTag(6)! as UIView).isHidden = false
                    }
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = (Bundle.main.loadNibNamed("ModuleSectionView", owner: self, options: nil)?[0] as? UIView)
        
        (view?.viewWithTag(4) as! UILabel).text = modulesArray[section]
        (view?.viewWithTag(5) as! UILabel).text = "Crédits: \(coeffSesctionArray[section])"
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
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
        averagesSectionArray.removeAll()
        averagesArray.removeAll()
        tableview.reloadData()
        coeffSesctionArray.removeAll()
        newMarksNotifications.removeAll()
        
        newMarksNotifications = notificationsUtils.getNewMarksPath()
        
        let semesterP = student.getSemesters()[selectedSemester]
        
        for d in 0..<semesterP.count { // modules
            
            let module = semesterP[d]["Title"].stringValue
            modulesArray.append(removeOptionalInfos(text: module))
            
            let average = semesterP[d]["MarkCode"].stringValue
            if average == "" {
                averagesArray.append("-")
            } else {
                averagesArray.append(average)
            }
            
            let coeff = semesterP[d]["CreditsAttempt"].stringValue
            if coeff == "" {
                coeffSesctionArray.append("-")
            } else {
                coeffSesctionArray.append(coeff)
            }
            
            let courses = semesterP[d]["children"]
            
            var moduleCourses = [String]()
            var averageSection = [String]()
            
            for e in 0..<courses.count { // courses
                
                let course = courses[e]["Title"].stringValue
                moduleCourses.append(removeOptionalInfos(text: course))
                
                let average = courses[e]["MarkCode"].stringValue
                if average == "" {
                    averageSection.append("-")
                } else {
                    averageSection.append(average)
                }
            }
            
            averagesSectionArray.append(averageSection)
            coursesArray.append(moduleCourses)
            moduleCourses.removeAll()
            averageSection.removeAll()
        }
        let semesterList = student.getSemestersNamesList()
        semestreLabel.text = "\(semesterList[selectedSemester])"
        
        self.tableview.reloadData()
    }
    
    func initFilterView() {
        semesters.removeAll()
        
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
            student.refreshMarks { (success, isTimedOut) in
                if success {
                    self.initCourses()
                    
                } else if isTimedOut {
                    print("Time Out")
                }
                refreshControl.endRefreshing()
            }
        } else {
            let alert = UIAlertController(title: "Pas d'internet", message: "Verifiez votre connexion", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in refreshControl.endRefreshing()}))
            self.present(alert, animated: true, completion: nil)
        }
    }
}


