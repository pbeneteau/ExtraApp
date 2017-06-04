//
//  ViewController.swift
//  ExtranetApp
//
//  Created by Paul Bénéteau on 31/05/2017.
//  Copyright © 2017 Tastyapp. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
    
    enum BackendError: Error {
        case network(error: Error) // Capture any underlying Error from the URLSession API
        case dataSerialization(error: Error)
        case jsonSerialization(error: Error)
        case xmlSerialization(error: Error)
        case objectSerialization(reason: String)
    }
    
    @IBOutlet weak var studentPicture: UIImageView!
    
    var headers: HTTPHeaders? = nil
    let userName: String = "20140637"
    let userPassword: String = "T@sty0psfr0st"
    var studentVnCodes = [String]()
    var studentMarks = [JSON]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let manager = NetworkReachabilityManager(host: "http://extranet.groupe-efrei.fr")
        
        manager?.listener = { status in
            print("Network Status Changed: \(status)\n")
        }
        
        manager?.startListening()
        
        logIn { success in
            self.getVnCodes{ vnCodes in
                self.studentVnCodes = vnCodes
                self.getStudentPhoto()
                for vnCode in self.studentVnCodes {
                    self.getStudentMarks(vn: vnCode){ marksDict in
                        self.studentMarks.append(JSON(marksDict))
                        self.listMarks(jsonFile: JSON(marksDict))
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func logIn(completionHandler: @escaping (_ success: Bool) -> ()) {
        
        Alamofire.request("https://extranet.groupe-efrei.fr/Users/Account/DoLogin?username=\(userName)&password=\(userPassword)", method: .get).responseJSON { response in
            
            self.headers = response.response?.allHeaderFields as? HTTPHeaders
            
            let cookies: Array = HTTPCookieStorage.shared.cookies!
            
            self.headers = Alamofire.HTTPCookie.requestHeaderFields(with: cookies)
            
            completionHandler(true)
        }
    }
    
    func getStudentPhoto() {
        
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        
        Alamofire.download("https://extranet.groupe-efrei.fr/Student/Home/Photo/Unknown.jpeg", to: destination)
            .downloadProgress { progress in
                print("Download Progress: \(progress.fractionCompleted)")
            }
            .responseData { response in
                if let data = response.result.value {
                    let image = UIImage(data: data)
                    self.studentPicture.image = image
                }
        }
    }
    
    func getStudentMarks(vn: String, completionHandler: @escaping (_ marksDict: Any) -> ()) {
        
        let url = "https://extranet.groupe-efrei.fr/Student/Grade/GetFinalGrades?&vn=\(vn)&academic_year=All"
        
        Alamofire.request(url).responseString { response in
            
            var dataString = response.result.value
            
            dataString = self.cleanMarksJSON(string: dataString!)
            
            let dict = self.convertToDictionary(text: dataString!)
            
           
            completionHandler(dict!)
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
        print(escapedString)
        return escapedString
    }
    
    func cleanMarksJSON(string: String) -> String {
        
        var newString = string.replacingOccurrences(of: "X.net.RM.getIcon(\"BulletWhite\")", with: "\"\"")
        newString = newString.replacingOccurrences(of: "\"leaf\":true", with: "\"leaf\":\"true\"")
        newString = newString.replacingOccurrences(of: "\"leaf\":false", with: "\"leaf\":\"false\"")
        newString = newString.replacingOccurrences(of: " \"total\": 0", with: "\"total\": \"0\"")
        newString = newString.replacingOccurrences(of: " \"total\": 0", with: "\"total\": \"0\"")
        
        return newString
    }
    
    func convertToDictionary(text: String) -> Any? {
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
    func nsdataToJSON(data: NSData) -> Any? {
        do {
            return try JSONSerialization.jsonObject(with: data as Data, options: .mutableContainers)
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil
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
    
    
}



