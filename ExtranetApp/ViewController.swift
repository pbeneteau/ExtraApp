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
    var studentVnCode: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let manager = NetworkReachabilityManager(host: "http://extranet.groupe-efrei.fr")
        
        manager?.listener = { status in
            print("Network Status Changed: \(status)\n")
        }
        
        manager?.startListening()
        
        logIn { success in
            self.getVnCode{ vnCode in
                self.studentVnCode = vnCode
                self.getStudentPhoto()
                self.getStudentMarks{ marksDict in
                    print(marksDict)
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
    
    func getStudentMarks(completionHandler: @escaping (_ marksDict: Any) -> ()) {
        
        let url = "https://extranet.groupe-efrei.fr/Student/Grade/GetFinalGrades?_dc=&action=read&vn=\(studentVnCode)&academic_year=2016-2017&node=Root"
        
        Alamofire.request(url).responseString { response in
            
            var dataString = response.result.value
            
            dataString = self.cleanMarksJSON(string: dataString!)
            
            let dict = self.convertToDictionary(text: dataString!)
            
           
            if dict != nil {
                let obj = dict as? NSDictionary
                
                //this part write all key and value
                for (key, value) in obj! {
                    print("Property: \"\(key)\", Value: \"\(value)\"")
                }
            }
           
            completionHandler(dict!)
        }
    }
    
    func getVnCode(completionHandler: @escaping (_ vnCode: String) -> ()) {
        
        let url = "https://extranet.groupe-efrei.fr/Student/Episode/GetEpisodes"
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { result in
            let vnCode: String = JSON(result.value!)["data"][0]["vn"].stringValue
            completionHandler(self.encodeEscapeUrl(string: vnCode))
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
    
    
}



