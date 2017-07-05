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
    private var calendarLink: String = ""
    
    init() {
        
    }
    
    public func initInfos(completionHandler: @escaping (_ success: Bool, _ isTimedOut: Bool) -> ()) {        
            let url = "https://extranet.groupe-efrei.fr/Student/Home/RightContent"
            
            manager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseString { response in
                print(response)
                switch (response.result) {
                    
                case .success:
                    let dataString = cleanMarksJSONinfos(string: response.result.value!)
                    
                    if let dict = convertToDictionary(text: dataString) {
                        print(dict)
                        self.name = JSON(dict)["items"][0]["items"][0]["items"][0]["value"].stringValue
                        self.name = self.name.replacingOccurrences(of: ",", with: " ")
                        self.birthDate = JSON(dict)["items"][0]["items"][0]["items"][1]["value"].stringValue
                        self.address = JSON(dict)["items"][0]["items"][0]["items"][2]["value"].stringValue
                        self.city = JSON(dict)["items"][0]["items"][0]["items"][3]["value"].stringValue
                        self.phone = JSON(dict)["items"][0]["items"][0]["items"][4]["value"].stringValue
                        self.email = JSON(dict)["items"][0]["items"][0]["items"][5]["items"][0]["value"].stringValue
                        
                        completionHandler(true,false)
                    } else {
                        completionHandler(false,false)
                    }
                    break
                case .failure(let error):
                    if error._code == NSURLErrorTimedOut {
                        completionHandler(false,true)
                    }
                    completionHandler(false,false)
                    break
                }
            }
        
    }
    
    func logIn(completionHandler: @escaping (_ success: Bool, _ isTimedOut: Bool) -> ()) {
        
        manager.request("https://extranet.groupe-efrei.fr/Users/Account/DoLogin?username=\(self.username)&password=\(self.password)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseString { response in
            
            switch (response.result) {
            case .success:
                let string = String(describing: response.response)
                
                if string.range(of:"extranet_db") != nil {
                    completionHandler(true,false)
                } else {
                    completionHandler(false,false)
                }
                break
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    completionHandler(false,true)
                }
                completionHandler(false,false)
                break
            }
            
        }
    }
    
    public func loadStudentData(completionHandler: @escaping (_ success: Bool, _ isTimedOut: Bool) -> ()) {
        if Reachability.isConnectedToNetwork() == true {
            self.getVnCodes { (success,vnCodes, isTimedOut) in
                if success {
                    self.studentVnCodes = vnCodes
                    self.getStudentMarks() { (success,dict, isTimedOut) in
                        if success {
                            self.setMarks(marks: dict)
                            self.initSemester()
                            self.saveSemesters { success in
                                if success {
                                    completionHandler(true, false)
                                } else {
                                    completionHandler(false, false)
                                }
                            }
                        } else if isTimedOut {
                            completionHandler(false, true)
                        } else {
                            completionHandler(false,false)
                        }
                    }
                } else if isTimedOut {
                    completionHandler(false,true)
                }
            }
        } else {
            completionHandler(false,false)
        }
    }
    
    public func loadStudentDataForRefresh(completionHandler: @escaping (_ success: Bool, _ isTimedOut: Bool) -> ()) {
        if Reachability.isConnectedToNetwork() == true {
            self.getVnCodes { (success,vnCodes, isTimedOut) in
                if success {
                    self.studentVnCodes = vnCodes
                    self.getStudentMarks() { (success,dict, isTimedOut) in
                        if success {
                            self.setMarks(marks: dict)
                            self.initSemester()
                            completionHandler(true, false)
                        } else if isTimedOut {
                            completionHandler(false,true)
                        } else {
                            completionHandler(false, false)
                        }
                    }
                } else if isTimedOut {
                    completionHandler(false,true)
                }
            }
        } else {
            completionHandler(false, false)
        }
    }
    
    
    
    public func refreshMarks(completionHandler: @escaping (_ success: Bool, _ isTimedOut: Bool) -> ()) {
        self.getVnCodes { (success,vnCodes, isTimedOut) in
            if success {
                self.studentVnCodes = vnCodes
                self.getStudentMarks() { (success,dict,isTimedOut) in
                    if success {
                        self.setMarks(marks: dict)
                        self.initSemester()
                        completionHandler(true,false)
                    } else if isTimedOut {
                        completionHandler(false,true)
                    } else {
                        completionHandler(false,false)
                    }
                }
            }
        }
    }
    
    func getStudentMarks(completionHandler: @escaping (_ success: Bool, _ marks: [String:JSON], _ isTimedOut: Bool) -> ()) {
        if Reachability.isConnectedToNetwork() == true {
            
            var dictionnary = [String:JSON]()
            let vnCount = studentVnCodes.count
            
            for vn in studentVnCodes {
                let url = "https://extranet.groupe-efrei.fr/Student/Grade/GetFinalGrades?&vn=\(vn)&academic_year=All"
                
                manager.request(url).responseString { response in
                    
                    switch (response.result) {
                    case .success:
                        var dataString: String = (response.result.value)!
                        
                        dataString = cleanMarksJSON(string: dataString)
                        
                        if let dict = convertToDictionary(text: dataString) {
                            dictionnary[vn] = (JSON(dict as Any))
                            
                            if (vnCount == dictionnary.count) {
                                completionHandler(true, dictionnary, false)
                            }
                        } else {
                            completionHandler(false, dictionnary, false)
                        }
                        break
                    case .failure(let error):
                        if error._code == NSURLErrorTimedOut {
                            completionHandler(false,dictionnary, true)
                        }
                        completionHandler(false,dictionnary, false)
                        break
                    }

                }
            }
        }
    }
    
    func getVnCodes(completionHandler: @escaping (_ success: Bool, _ vnCodes: [String], _ isTimedOut: Bool) -> ()) {
        if Reachability.isConnectedToNetwork() == true
        {
            let url = "https://extranet.groupe-efrei.fr/Student/Episode/GetEpisodes"
            var vnCodes = [String]()
            
            manager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
                
                switch (response.result) {
                case .success:
                    if response.result.value != nil {
                        for i in 0..<JSON(response.result.value!)["data"].count {
                            let enscapedString = self.encodeEscapeUrl(string: JSON(response.result.value!)["data"][i]["vn"].stringValue)
                            vnCodes.append(enscapedString)
                        }
                        completionHandler(true, vnCodes, false)
                    } else {
                        completionHandler(false,vnCodes, false)
                    }
                    break
                case .failure(let error):
                    if error._code == NSURLErrorTimedOut {
                        completionHandler(false,vnCodes, true)
                    }
                    completionHandler(false,vnCodes, false)
                    break
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
    
    public func downloadPicture(completionHandler: @escaping (_ success: Bool, _ picture: Data, _ isTimedOut: Bool) -> ()) {
        
        let url = "https://extranet.groupe-efrei.fr/Student/Home/Photo/"
        
        var pictureData = Data()
        
        manager.request(url).validate().responseData { response in
            switch (response.result) {
            case .success:
                if response.result.value != nil {
                    pictureData = response.result.value!
                    completionHandler(true, pictureData, false)
                } else {
                    completionHandler(false,pictureData, false)
                }
                break
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    completionHandler(false,pictureData, true)
                }
                completionHandler(false,pictureData, false)
                break
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
    
    public func getCalendarLink() -> String {
        return self.calendarLink
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
    
    public func saveInfosToUserDefaults(completionHandler: @escaping (_ success: Bool) -> ()) {
        userDefaults.set(self.name, forKey: "studentName")
        userDefaults.set(self.birthDate, forKey: "studentBirthDate")
        userDefaults.set(self.city, forKey: "studentCity")
        userDefaults.set(self.address, forKey: "studentAddress")
        userDefaults.set(self.phone, forKey: "studentPhone")
        userDefaults.set(self.email, forKey: "studentEmail")
        
        if userDefaults.string(forKey: "studentName") != nil && userDefaults.string(forKey: "studentBirthDate") != nil && userDefaults.string(forKey: "studentCity") != nil && userDefaults.string(forKey: "studentAddress") != nil && userDefaults.string(forKey: "studentPhone") != nil && userDefaults.string(forKey: "studentEmail") != nil{
            completionHandler(true)
        } else {
            completionHandler(false)
        }
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
    
    public func saveSemesters(completionHandler: @escaping (_ success: Bool) -> ()) {
        userDefaults.setValue(self.studentSemesters.count, forKey: "numberSemesters")
        var i = 0
        for semester in studentSemesters {
            userDefaults.setValue(semester.rawString()!, forKey: "semester\(i)")
            if userDefaults.value(forKey: "semester\(i)") == nil {
                completionHandler(false)
            }
            i += 1
        }
        i = 0
        for semester in semestersNamesList {
            userDefaults.setValue(semester, forKey: "semesterName\(i)")
            if userDefaults.value(forKey: "semesterName\(i)") == nil {
                completionHandler(false)
            }
            i += 1
        }
        completionHandler(true)
    }
    
    public func loadInfosFromUserDefaults(completionHandler: @escaping (_ success: Bool) -> ()) {
        if userDefaults.string(forKey: "studentName") != nil {
            self.name = userDefaults.string(forKey: "studentName")!
        } else {
            completionHandler(false)
        }
        if userDefaults.string(forKey: "studentBirthDate") != nil {
            self.birthDate = userDefaults.string(forKey: "studentBirthDate")!
        } else {
            completionHandler(false)
        }
        if userDefaults.string(forKey: "studentCity") != nil {
            self.city = userDefaults.string(forKey: "studentCity")!
        } else {
            completionHandler(false)
        }
        if userDefaults.string(forKey: "studentAddress") != nil {
            self.address = userDefaults.string(forKey: "studentAddress")!
        } else {
            completionHandler(false)
        }
        if userDefaults.string(forKey: "studentPhone") != nil {
            self.phone = userDefaults.string(forKey: "studentPhone")!
        } else {
            completionHandler(false)
        }
        if userDefaults.string(forKey: "studentEmail") != nil {
            self.email = userDefaults.string(forKey: "studentEmail")!
        } else {
            completionHandler(false)
        }
        
        completionHandler(true)
        
    }
    
    public func loadSemestersFromUserDefaults(completionHandler: @escaping (_ success: Bool) -> ()) {
        var n = 0
        semestersNamesList.removeAll()
        studentSemesters.removeAll()
        if userDefaults.integer(forKey: "numberSemesters") > 0 {
            n = userDefaults.integer(forKey: "numberSemesters")
            self.studentSemesters.removeAll()
            for i in 0..<(n) {
                self.studentSemesters.append(JSON.init(parseJSON: userDefaults.value(forKey: "semester\(i)") as! String))
            }
            
            for i in 0..<(n) {
                self.semestersNamesList.append(userDefaults.value(forKey: "semesterName\(i)") as! String)
            }
            completionHandler(true)
        } else {
            completionHandler(false)
        }
    }
    
    public func initCalendarLink(completionHandler: @escaping (_ success: Bool, _ isTimedOut: Bool) -> ()) {
        let url = "https://extranet.groupe-efrei.fr/Student/Calendar/Display"
        
        manager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseString { response in
            
            switch (response.result) {
            case .success:
                if (response.result.value?.slice(from: "OpenCalendar?key=", to: "%3D%3D")) != nil {
                    let str = response.result.value?.slice(from: "OpenCalendar?key=", to: "%3D%3D")!
                    self.calendarLink = "https://extranet.groupe-efrei.fr/Student/OpenCalendar?key=\(String(str!)!)%3D%3D&langue=FR"
                }
                completionHandler(true,true)
                break
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    completionHandler(false,true)
                }
                completionHandler(false,false)
                break
            }
            
        }
    }
    
    
}



