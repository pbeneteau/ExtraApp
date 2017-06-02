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
import Ono

enum BackendError: Error {
    case network(error: Error) // Capture any underlying Error from the URLSession API
    case dataSerialization(error: Error)
    case jsonSerialization(error: Error)
    case xmlSerialization(error: Error)
    case objectSerialization(reason: String)
}

var headers: HTTPHeaders? = nil
let userName: String = "20140637"
let userPassword: String = "T@sty0psfr0st"


internal typealias RequestCompletion = (Int?, Error?) -> ()?
private var completionBlock: RequestCompletion!
var afManager : SessionManager!

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let manager = NetworkReachabilityManager(host: "http://extranet.groupe-efrei.fr")
        
        manager?.listener = { status in
            print("Network Status Changed: \(status)\n")
        }
        
        manager?.startListening()
        
        logIn{ success in
            self.getStudentMarks{ marksDict in
                print(marksDict)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func logIn(completionHandler: @escaping (_ success: Bool) -> ()) {
        
        
        Alamofire.request("https://extranet.groupe-efrei.fr/Users/Account/DoLogin?username=\(userName)&password=\(userPassword)", method: .get).responseJSON { response in
            
            headers = response.response?.allHeaderFields as? HTTPHeaders
            
            let cookies: Array = HTTPCookieStorage.shared.cookies!
            
            headers = Alamofire.HTTPCookie.requestHeaderFields(with: cookies)
            
            completionHandler(true)
        }
    }
    
    func getStudentMarks(completionHandler: @escaping (_ marksDict: Any) -> ()) {
        
        Alamofire.request("https://extranet.groupe-efrei.fr/Student/Grade/GetFinalGrades?_dc=1496321401163&action=read&vn=T%2B0Rhhq6%2FBbHvK3KupsGpQ%3D%3D&academic_year=2016-2017&node=Root").responseString { response in
            
            
            var dataString = response.result.value
            
            dataString = self.cleanMarksJSON(string: dataString!)
            
            //let data = dataString?.data(using: .utf8)
            
            //print(self.nsdataToJSON(data: data! as NSData))
            
            let dict = self.convertToDictionary(text: dataString!)
            
            completionHandler(dict!)
        }
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
    
    func makeAlamofireRequest(url :String){
        let configuration = URLSessionConfiguration.default
        
        afManager = Alamofire.SessionManager(configuration: configuration)
        afManager.request(url, method: .post).validate().responseJSON {
            response in
            switch (response.result) {
            case .success:
                print("data - > \n    \(String(describing: response.data?.debugDescription)) \n")
                print("response - >\n    \(String(describing: response.response?.debugDescription)) \n")
                _ = 0
                if let unwrappedResponse = response.response {
                    _ = unwrappedResponse.statusCode
                }
                
                break
            case .failure(let error):
                print("error - > \n    \(error.localizedDescription) \n")
                _ = response.response?.statusCode
                break
            }
        }
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



