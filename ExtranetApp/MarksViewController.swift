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
import NVActivityIndicatorView
import MarqueeLabel

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
    private var moduleAverages = [String]()
    private var calculatedAverageArray = [[Float]]()
    
    var indicatorView: NVActivityIndicatorView! = nil
    
    @IBOutlet weak var semestreLabel: MarqueeLabel!
    
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
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true

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
        
        self.indicatorView = NVActivityIndicatorView(frame: CGRect(x: UIScreen.main.bounds.size.width / 2 - 15, y: UIScreen.main.bounds.size.height / 2 - 15, width: 30, height: 30))
        
        self.indicatorView.type = .ballScaleMultiple
        self.indicatorView.color = UIColor(red:0.21, green:0.95, blue:0.59, alpha:1.0)
        
        self.view.addSubview(indicatorView)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indexPath = self.tableview.indexPathForSelectedRow {
            
            sectionSelected = indexPath.section
            indexSelected = indexPath.row
            
            removeNotifications()
            
            self.tableview.reloadData()
        }
        performSegue(withIdentifier: "semesterSegue", sender: nil)
    }
    
    func removeNotifications() {
        
        var temp = [[Int]]()
        
        for path in newMarksNotifications {
            
            if path[1] == selectedSemester && path[2] == indexSelected {
            } else {
                temp.append(path)
            }
        }
        newMarksNotifications.removeAll()
        newMarksNotifications = temp
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
        
        
        
        if averagesSectionArray[indexPath.section][indexPath.row] != "-" || userDefaults.bool(forKey: "averagesCalculation") == false {
            (cell.viewWithTag(4) as! UILabel).text = averagesSectionArray[indexPath.section][indexPath.row]
            (cell.viewWithTag(4) as! UILabel).textColor = UIColor(red:0.21, green:0.95, blue:0.59, alpha:1.0)
        } else {
            if calculatedAverageArray[indexPath.section][indexPath.row] != 9999 {
                if calculatedAverageArray[indexPath.section][indexPath.row].isNaN == false {
                    (cell.viewWithTag(4) as! UILabel).text = String(format: "%.01f", calculatedAverageArray[indexPath.section][indexPath.row])
                    (cell.viewWithTag(4) as! UILabel).textColor = UIColor.lightGray
                } else {
                    (cell.viewWithTag(4) as! UILabel).text = averagesSectionArray[indexPath.section][indexPath.row]
                    (cell.viewWithTag(4) as! UILabel).textColor = UIColor(red:0.21, green:0.95, blue:0.59, alpha:1.0)
                }
            } else {
                (cell.viewWithTag(4) as! UILabel).text = averagesSectionArray[indexPath.section][indexPath.row]
                (cell.viewWithTag(4) as! UILabel).textColor = UIColor(red:0.21, green:0.95, blue:0.59, alpha:1.0)
            }
        }
        
        cell.selectionStyle = .none
        
        (cell.viewWithTag(10)! as UIView).layer.shadowColor = UIColor.black.cgColor
        (cell.viewWithTag(10)! as UIView).layer.shadowOpacity = 0.18
        (cell.viewWithTag(10)! as UIView).layer.shadowRadius = 7
        (cell.viewWithTag(10)! as UIView).layer.shadowOffset = CGSize(width: 0, height: 10.0)
        (cell.viewWithTag(10)! as UIView).layer.shouldRasterize = true
        (cell.viewWithTag(10)! as UIView).layer.rasterizationScale = UIScreen.main.scale
        
        (cell.viewWithTag(6)! as UIView).layer.cornerRadius = (cell.viewWithTag(6)! as UIView).frame.height / 2
        
        (cell.viewWithTag(6)! as UIView).isHidden = true
        
        for path in newMarksNotifications {
            if path[0] == selectedSemester && path[1] == indexPath.section && path[2] == indexPath.row {
                (cell.viewWithTag(6)! as UIView).isHidden = false
                print("show")
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = (Bundle.main.loadNibNamed("ModuleSectionView", owner: self, options: nil)?[0] as? UIView)
        
        (view?.viewWithTag(4) as! UILabel).text = modulesArray[section]
        (view?.viewWithTag(5) as! UILabel).text = "Crédits: \(coeffSesctionArray[section]) | Moyenne: \(moduleAverages[section])"
        
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
        moduleAverages.removeAll()
        calculatedAverageArray.removeAll()
        
        newMarksNotifications = notificationsUtils.getNewMarksPath()
        
        let semesterP = student.getSemesters()[selectedSemester]
        
        for d in 0..<semesterP.count { // modules
            
            let cdazd = semesterP[d]["children"]
            
            var averages = [Float]()
            
            for e in 0..<cdazd.count {
                
                let subject = cdazd[e]["children"]
                
                var marks = [Float]()
                var coeffs = [Float]()
                
                for f in 0..<subject.count {
                    
                    var mark = subject[f]["MarkCode"].stringValue
                    var coeff = subject[f]["Weight"].stringValue
                    
                    mark = mark.replacingOccurrences(of: ",", with: ".")
                    coeff = coeff.replacingOccurrences(of: ",", with: ".")
                                        
                    if mark != "" && coeff != "" && mark != "ABS" {
                        if let doubleMark = Float(mark), let doubleCoeff = Float(coeff) {
                            marks.append(doubleMark)
                            coeffs.append(doubleCoeff)
                        }
                    }
                }
                averages.append(arrayAverage(marks: marks, coeffs: coeffs))
            }
            calculatedAverageArray.append(averages)
            
            let module = semesterP[d]["Title"].stringValue
            modulesArray.append(removeOptionalInfos(text: module))
            
            let average = semesterP[d]["MarkCode"].stringValue
            if average == "" {
                averagesArray.append("-")
            } else {
                averagesArray.append(average.replacingOccurrences(of: ",", with: "."))
            }
            
            let coeff = semesterP[d]["CreditsAttempt"].stringValue
            if coeff == "" {
                coeffSesctionArray.append("-")
            } else {
                coeffSesctionArray.append(coeff)
            }
            
            var moduleAverage = semesterP[d]["MarkCode"].stringValue
            moduleAverage = moduleAverage.replacingOccurrences(of: ",", with: ".")
            
            if moduleAverage == "" {
                moduleAverages.append("-")
            } else {
                moduleAverages.append(moduleAverage.replacingOccurrences(of: ",", with: "."))
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
                    averageSection.append(average.replacingOccurrences(of: ",", with: "."))
                }
            }
            
            averagesSectionArray.append(averageSection)
            coursesArray.append(moduleCourses)
            moduleCourses.removeAll()
            averageSection.removeAll()
        }
        let semesterList = student.getSemestersNamesList()
        semestreLabel.resetLabel()
        semestreLabel.text = "\(semesterList[selectedSemester])"
        semestreLabel.fadeLength = 10
        semestreLabel.type = .continuous
        semestreLabel.animationCurve = .easeInOut
        semestreLabel.animationDelay = 5
        semestreLabel.restartLabel()
        
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
        if Reachability.isConnectedToNetwork() == true {
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
    
    func arrayAverage(marks: [Float], coeffs: [Float]) -> Float {
        
        if marks.count != coeffs.count {
            return 9999
        } else if marks.count == 0 || coeffs.count == 0 {
            return 9999
        }
        var marksWithCoeff = [Float]()
        var totalCoeff: Float = 0
        var totalMark: Float = 0
        
        for coeff in coeffs {
            totalCoeff += Float(coeff)
        }
        for i in 0..<marks.count {
            marksWithCoeff.append(marks[i] * coeffs[i])
        }
        for mark in marksWithCoeff {
            totalMark += Float(mark)
        }
        let average: Float = Float(totalMark) / Float(totalCoeff)
        
        return average
    }
}

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}


