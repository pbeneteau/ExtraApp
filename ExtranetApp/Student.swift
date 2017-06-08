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
    
    enum BackendError: Error {
        case network(error: Error) // Capture any underlying Error from the URLSession API
        case dataSerialization(error: Error)
        case jsonSerialization(error: Error)
        case xmlSerialization(error: Error)
        case objectSerialization(reason: String)
    }
    
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
    private var studentPicture = UIImage()
    private var semestersNamesList = [String]()
    
    init() {
        
    }
    
    public func cleanMarksJSON(string: String) -> String {
        
        var newString = string.replacingOccurrences(of: "X.net.RM.getIcon(\"BulletWhite\")", with: "\"\"")
        newString = newString.replacingOccurrences(of: "\"leaf\":true", with: "\"leaf\":\"true\"")
        newString = newString.replacingOccurrences(of: "\"leaf\":false", with: "\"leaf\":\"false\"")
        newString = newString.replacingOccurrences(of: " \"total\": 0", with: "\"total\": \"0\"")
        newString = newString.replacingOccurrences(of: "Ã©", with: "é")
        newString = newString.replacingOccurrences(of: "Ã¨", with: "è")
        newString = newString.replacingOccurrences(of: "Ã", with: "à")
        
        return newString
    }
    
    public func cleanMarksJSONinfos(string: String) -> String {
        
        var newString = string.replacingOccurrences(of: "<script type=\"text/javascript\">Ext.ComponentManager.onAvailable(\"ExtranetContent\",", with: "")
        newString = newString.replacingOccurrences(of: "function(){", with: "")
        newString = newString.replacingOccurrences(of: "Ext.net.addTo(\"ExtranetContent\",", with: "")
        newString = newString.replacingOccurrences(of: ");</script>", with: "")
        newString = newString.replacingOccurrences(of: ", false);}", with: "")
        newString = newString.replacingOccurrences(of: ",listeners:{afterrender:{fn:function(item){Ext.net.DirectMethod.request({url: '/Student/Absence/Summary', timeout: 600000, cleanRequest: true, eventMask: {showMask:true} });}}}", with: "")
        newString = newString.replacingOccurrences(of: "id:\"ExtranetRightContent\",border:false,xtype:\"panel\",flex:3,", with: "")
        newString = newString.replacingOccurrences(of: "{cls:\"x-panel-alert\",style:\"padding: 5px\",items:[{cls:\"alert-label\",xtype:\"netlabel\",text:\"No alerts\"}],layout:\"vbox\",title:\"Important Messages\"},", with: "")
        newString = newString.replacingOccurrences(of: "cls:\"x-panel-infoperso\",style:\"padding: 5px\",", with: "")
        newString = newString.replacingOccurrences(of: ",{border:false,minHeight:170,style:\"padding: 5px\",xtype:\"container\",flex:1,items:[{xtype:\"netimage\",imageUrl:\"/Student/Home/Photo\"}]}", with: "")
        newString = newString.replacingOccurrences(of: "border:false,padding:0,xtype:\"fieldset\",flex:2,", with: "")
        newString = newString.replacingOccurrences(of: "id:\"idfa34d15a698236ef\",xtype:\"displayfield\",", with: "")
        newString = newString.replacingOccurrences(of: "id:\"id9a187f56aec236ef\",cls:\"alert-detail\",xtype:\"displayfield\",", with: "")
        newString = newString.replacingOccurrences(of: "id:\"EXT_ADDRESS\",xtype:\"displayfield\",", with: "")
        newString = newString.replacingOccurrences(of: "id:\"EXT_PLACE\",cls:\"alert-detail\",xtype:\"displayfield\",", with: "")
        newString = newString.replacingOccurrences(of: "id:\"EXT_TELEPHONEMOBILE\",cls:\"alert-detail\",xtype:\"displayfield\",", with: "")
        newString = newString.replacingOccurrences(of: "xtype:\"fieldcontainer\",", with: "")
        newString = newString.replacingOccurrences(of: "id:\"idd0b11e8e78ad36ef\",xtype:\"displayfield\",", with: "")
        newString = newString.replacingOccurrences(of: ",fieldLabel:\"E-mail\",labelWidth:50", with: "")
        newString = newString.replacingOccurrences(of: ",layout:\"hbox\",title:\"Personal Data\"", with: "")
        newString = newString.replacingOccurrences(of: "items:", with: "\"items\":")
        newString = newString.replacingOccurrences(of: "id:", with: "\"id\":")
        newString = newString.replacingOccurrences(of: "xtype:", with: "\"xtype\":")
        newString = newString.replacingOccurrences(of: "value:", with: "\"value\":")
        newString = newString.replacingOccurrences(of: "cls:", with: "\"cls\":")
        newString = newString.replacingOccurrences(of: "layout:", with: "\"layout\":")
        newString = newString.replacingOccurrences(of: "[{\"items\":[{\"items\":[{\"items\":", with: "{\"items\":[{\"items\":[{\"items\":")
        newString = newString.replacingOccurrences(of: "]}]}]", with: "]}]}")
        newString = newString.replacingOccurrences(of: "Name : ", with: "")
        newString = newString.replacingOccurrences(of: "Birthdate : ", with: "")
        newString = newString.replacingOccurrences(of: "Address : ", with: "")
        newString = newString.replacingOccurrences(of: "City : ", with: "")
        newString = newString.replacingOccurrences(of: "Mobile Phone : ", with: "")
        
        return newString
    }
    
    
    public func convertToDictionary(text: String) -> Any? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: [])
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    // Convert from NSData to json object
    public func nsdataToJSON(data: NSData) -> Any? {
        do {
            return try JSONSerialization.jsonObject(with: data as Data, options: .mutableContainers)
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil
    }
    
    public func initInfos() {
        let url = "https://extranet.groupe-efrei.fr/Student/Home/RightContent"
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseString { result in
            let dataString = self.cleanMarksJSONinfos(string: result.value!)
            let dict = self.convertToDictionary(text: dataString)
            
            self.name = JSON(dict!)["items"][0]["items"][0]["items"][0]["value"].stringValue
            self.birthDate = JSON(dict!)["items"][0]["items"][0]["items"][1]["value"].stringValue
            self.address = JSON(dict!)["items"][0]["items"][0]["items"][2]["value"].stringValue
            self.city = JSON(dict!)["items"][0]["items"][0]["items"][3]["value"].stringValue
            self.phone = JSON(dict!)["items"][0]["items"][0]["items"][4]["value"].stringValue
            self.email = JSON(dict!)["items"][0]["items"][0]["items"][5]["items"][0]["value"].stringValue
        }
    }
    
    func logIn(completionHandler: @escaping (_ success: Bool) -> ()) {
        
        Alamofire.request("https://extranet.groupe-efrei.fr/Users/Account/DoLogin?username=\(self.username)&password=\(self.password)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseString { response in
            
            let string = String(describing: response.response)
            if string.range(of:"extranet_db") != nil{
                
                self.initInfos()
                self.getVnCodes { vnCodes in
                    self.studentVnCodes = vnCodes
                    self.getStudentMarks() { marks in
                        self.setMarks(marks: marks)
                        self.sortBydate()
                        self.initSemester()
                        completionHandler(true)
                    }
                }
                
            } else {
                completionHandler(false)
            }
            
        }
    }
    
    
    func getStudentMarks(completionHandler: @escaping (_ marks: [JSON]) -> ()) {
        var marks = [JSON]()
        for vn in studentVnCodes {
            let url = "https://extranet.groupe-efrei.fr/Student/Grade/GetFinalGrades?&vn=\(vn)&academic_year=All"
            
            Alamofire.request(url).responseString { response in
                
                var dataString: String = (response.result.value)!
                
                dataString = self.cleanMarksJSON(string: dataString)
                
                let dict = self.convertToDictionary(text: dataString)
                
                marks.append(JSON(dict as Any))
                
                if (self.studentVnCodes.count == marks.count) {
                    completionHandler(marks)
                }
            }
        }
    }
    
    func getVnCodes(completionHandler: @escaping (_ vnCodes: [String]) -> ()) {
        
        let url = "https://extranet.groupe-efrei.fr/Student/Episode/GetEpisodes"
        var vnCodes = [String]()
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { result in
            for i in 0..<JSON(result.value!)["data"].count {
                let enscapedString = self.encodeEscapeUrl(string: JSON(result.value!)["data"][i]["vn"].stringValue)
                vnCodes.append(enscapedString)
            }
            completionHandler(vnCodes)
        }
    }
    
    
    func encodeEscapeUrl(string: String) -> String {
        
        let escapedString = string.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        return escapedString
    }
    
    public func initSemester() {
        
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
    
    func sortBydate() {
        
        studentMarks.sort { ($0["children"][0]["Title"].stringValue) < ($1["children"][0]["Title"].stringValue)}
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
    
    public func setMarks(marks: [JSON]) {
        self.studentMarks = marks
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
    
    
}



