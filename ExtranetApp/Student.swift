//
//  Student.swift
//  ExtranetApp
//
//  Created by antoine beneteau on 2017-06-06.
//  Copyright © 2017 Tastyapp. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class Student {
    
    private var name = "";
    private var birthDate = "";
    private var address = "";
    private var city = "";
    private var phone = "";
    private var email = "";
    private var username = "";
    private var password = "";
    private var studentVnCodes = [String]()
    private var studentMarks = [JSON]()
    private var studentSemesters = [JSON]()
    var studentPicture = UIImage()
    private var semestersNamesList = [String]()
    
    
    init() {
        
    }
    
    
    public func initInfos(completionHandler: @escaping (_ success: Bool) -> ()) {
        if Reachability.isConnectedToNetwork() == true {
            let url = "https://extranet.groupe-efrei.fr/Student/Home/RightContent"
            
            Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseString { result in
                let dataString = cleanMarksJSONinfos(string: result.value!)
                let dict = convertToDictionary(text: dataString)
                
                self.name = JSON(dict!)["items"][0]["items"][0]["items"][0]["value"].stringValue
                self.name = self.name.replacingOccurrences(of: ",", with: " ")
                self.birthDate = JSON(dict!)["items"][0]["items"][0]["items"][1]["value"].stringValue
                self.address = JSON(dict!)["items"][0]["items"][0]["items"][2]["value"].stringValue
                self.city = JSON(dict!)["items"][0]["items"][0]["items"][3]["value"].stringValue
                self.phone = JSON(dict!)["items"][0]["items"][0]["items"][4]["value"].stringValue
                self.email = JSON(dict!)["items"][0]["items"][0]["items"][5]["items"][0]["value"].stringValue
                
                self.saveInfosToUserDefaults()

                completionHandler(true)
            }
        } else {
            print("Error at initInfos: No internet connexion")
            completionHandler(false)
        }
    }
    
    func logIn(completionHandler: @escaping (_ success: Bool) -> ()) {
        
        Alamofire.request("https://extranet.groupe-efrei.fr/Users/Account/DoLogin?username=\(self.username)&password=\(self.password)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseString { response in
            
            let string = String(describing: response.response)
            if string.range(of:"extranet_db") != nil{
                
                completionHandler(true)
            } else {
                completionHandler(false)
            }
            
        }
    }
    
    func loadStudentData(completionHandler: @escaping (_ success: Bool) -> ()) {
        if Reachability.isConnectedToNetwork() == true {
            self.getVnCodes { vnCodes in
                self.studentVnCodes = vnCodes
                self.getStudentMarks() { dict in
                    self.setMarks(marks: dict)
                    self.initSemester()
                    self.saveSemesters()
                    completionHandler(true)
                }
            }
        } else {
            completionHandler(false)
        }
    }
    
    public func refreshMarks(completionHandler: @escaping (_ success: Bool) -> ()) {
        self.getVnCodes { vnCodes in
            self.studentVnCodes = vnCodes
            self.getStudentMarks() { dict in
                self.setMarks(marks: dict)
                self.initSemester()
                completionHandler(true)
            }
        }
    }
    
    func getStudentMarks(completionHandler: @escaping (_ marks: [String:JSON]) -> ()) {
        if Reachability.isConnectedToNetwork() == true {
            
            var dictionnary = [String:JSON]()
            let vnCount = studentVnCodes.count
            
            for vn in studentVnCodes {
                let url = "https://extranet.groupe-efrei.fr/Student/Grade/GetFinalGrades?&vn=\(vn)&academic_year=All"
                
                Alamofire.request(url).responseString { response in
                    
                    var dataString: String = (response.result.value)!
                    dataString = cleanMarksJSON(string: dataString)
                    
                    if let dict = convertToDictionary(text: dataString) {
                        dictionnary[vn] = (JSON(dict as Any))
                    }
                    if (vnCount == dictionnary.count) {
                        completionHandler(dictionnary)
                    }
                }
            }
        }
    }
    
    func getVnCodes(completionHandler: @escaping (_ vnCodes: [String]) -> ()) {
        if Reachability.isConnectedToNetwork() == true
        {
            let url = "https://extranet.groupe-efrei.fr/Student/Episode/GetEpisodes"
            var vnCodes = [String]()
            
            Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { result in
                
                if result.value != nil {
                    for i in 0..<JSON(result.value!)["data"].count {
                        let enscapedString = self.encodeEscapeUrl(string: JSON(result.value!)["data"][i]["vn"].stringValue)
                        vnCodes.append(enscapedString)
                    }
                    completionHandler(vnCodes)
                }
            }
        }
    }
    
    
    func encodeEscapeUrl(string: String) -> String {
        
        let escapedString = string.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        return escapedString
    }
    
    public func initSemester() {
        
        studentSemesters.removeAll()
        semestersNamesList.removeAll()
        
        for json in studentMarks {
            let year = json["children"][0]
            for i in 0..<year["children"].count {
                let semester = year["children"][i]["children"]
                studentSemesters.append(semester)
                semestersNamesList.append(year["children"][i]["Title"].stringValue)
            }
        }
    }
    
    func listMarks(jsonFile: JSON) {
        
        if jsonFile["children"].count > 0 {
            let years = jsonFile["children"]
            for i in 0..<years.count {
                print("\(years[i]["Title"].stringValue)")
                print("     |")
                
                let semesters = years[i]["children"]
                for i in 0..<semesters.count {
                    print("     \(semesters[i]["Title"].stringValue)")
                    print("             |")
                    
                    let modules = semesters[i]["children"]
                    for i in 0..<modules.count {
                        print("             \(modules[i]["Title"].stringValue)          credits: \(modules[i]["CreditsAttempt"].stringValue)")
                        print("                     |")
                        
                        let courses = modules[i]["children"]
                        for i in 0..<courses.count {
                            print("                     \(courses[i]["Title"].stringValue)          coefficient: \(courses[i]["Weight"].stringValue)")
                            print("                             Moyenne: \(courses[i]["MarkCode"].stringValue)")
                            
                            
                            let exams = courses[i]["children"]
                            for i in 0..<exams.count {
                                print("                             \(exams[i]["Title"].stringValue)          coefficient: \(exams[i]["Weight"].stringValue)")
                                print("                                     Note: \(exams[i]["MarkCode"].stringValue)")
                                
                            }
                        }
                    }
                }
            }
        } else {
            print("No")
        }
    }
    
    public func downloadPicture(completionHandler: @escaping (_ picture: UIImage) -> ()) {
        Alamofire.download("https://extranet.groupe-efrei.fr/Student/Home/Photo").responseData { response in
            if let data = response.result.value {
                completionHandler(UIImage(data: data)!)
            }
        }
    }
    
    public func setSemesters(_semesters: [JSON]) {
        self.studentSemesters = _semesters
    }
    
    public func setSemestersNameList(_semestersNameList: [String]) {
        self.semestersNamesList = _semestersNameList
    }
    
    public func getSemesters() -> [JSON] {
        return self.studentSemesters
    }
    
    public func getSemestersNamesList() -> [String] {
        return self.semestersNamesList
    }
    
    public func getUsername() -> String {
        return self.username
    }
    
    public func getPassword() -> String {
        return self.password
    }
    
    public func getName() -> String {
        return self.name
    }
    
    public func getBirthDate() -> String {
        return self.birthDate
    }
    
    public func getAddress() -> String {
        return self.address
    }
    
    public func getCity() -> String {
        return self.city
    }
    
    public func getPhone() -> String {
        return self.phone
    }
    
    public func getEmail() -> String {
        return self.email
    }
    
    public func getVnCodes() -> [String] {
        return self.studentVnCodes
    }
    
    public func getMarks() -> [JSON] {
        return self.studentMarks
    }
    
    public func getPicture() -> UIImage {
        return self.studentPicture
    }
    
    public func setName(name: String) {
        self.name = name
    }
    
    public func setBirthDate(birthDate: String) {
        self.birthDate = birthDate
    }
    
    public func setAddress(address: String) {
        self.address = address
    }
    
    public func setCity(city: String) {
        self.city = city
    }
    
    public func setPhone(phone: String) {
        self.phone = phone
    }
    
    public func setEmail(email: String) {
        self.email = email
    }
    
    public func setVnCodes(vnCodes: [String]) {
        self.studentVnCodes = vnCodes
    }
    
    public func setMarks(marks: [String:JSON]) {
        for vn in studentVnCodes {
            studentMarks.append(marks[vn]!)
        }
    }
    
    public func setPicture(picture: UIImage) {
        self.studentPicture = picture
    }
    
    public func setUsername(username: String) {
        self.username = username
    }
    
    public func setPassword(password: String) {
        self.password = password
    }
    
    public func saveInfosToUserDefaults() {
        userDefaults.set(self.name, forKey: "studentName")
        userDefaults.set(self.birthDate, forKey: "studentBirthDate")
        userDefaults.set(self.city, forKey: "studentCity")
        userDefaults.set(self.address, forKey: "studentAddress")
        userDefaults.set(self.phone, forKey: "studentPhone")
        userDefaults.set(self.email, forKey: "studentEmail")
    }
    
    public func isUserInfosSavedinUserDefaults() -> Bool {
        let keys = ["studentName", "studentBirthDate", "studentCity", "studentAddress", "studentPhone", "studentEmail"]
        for key in keys {
            if userDefaults.value(forKey: key) as? String == nil || userDefaults.value(forKey: key) as? String == "" {
                return false
            }
        }
        return true
    }
    
    public func saveSemesters() {
        userDefaults.setValue(self.studentSemesters.count, forKey: "numberSemesters")
        var i = 0
        for semester in studentSemesters {
            userDefaults.setValue(semester.rawString()!, forKey: "semester\(i)")
            i += 1
        }
        i = 0
        for semester in semestersNamesList {
            userDefaults.setValue(semester, forKey: "semesterName\(i)")
            i += 1
        }
    }
    
    public func loadInfosFromUserDefaults() {
        if userDefaults.string(forKey: "studentName") != nil {
            self.name = userDefaults.string(forKey: "studentName")!
        }
        if userDefaults.string(forKey: "studentBirthDate") != nil {
            self.birthDate = userDefaults.string(forKey: "studentBirthDate")!
        }
        if userDefaults.string(forKey: "studentCity") != nil {
            self.city = userDefaults.string(forKey: "studentCity")!
        }
        if userDefaults.string(forKey: "studentAddress") != nil {
            self.address = userDefaults.string(forKey: "studentAddress")!
        }
        if userDefaults.string(forKey: "studentPhone") != nil {
            self.phone = userDefaults.string(forKey: "studentPhone")!
        }
        if userDefaults.string(forKey: "studentEmail") != nil {
            self.email = userDefaults.string(forKey: "studentEmail")!
        }
        
    }
    
    public func loadSemestersFromUserDefaults() {
        var n = 0
        if userDefaults.integer(forKey: "numberSemesters") != 0 {
            n = userDefaults.integer(forKey: "numberSemesters")
            self.studentSemesters.removeAll()
            for i in 0..<(n) {
                self.studentSemesters.append(JSON.init(parseJSON: userDefaults.value(forKey: "semester\(i)") as! String))
            }
            for i in 0..<(n) {
                self.semestersNamesList.append(userDefaults.value(forKey: "semesterName\(i)") as! String)
            }
        } else {
            print("loadSemestersFromUserDefaults: No userDefaults data")
        }
    }
    
    public func downloadFile() {
        
    }
    
    
}



