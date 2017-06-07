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

    
    @IBOutlet weak var studentPicture: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let manager = NetworkReachabilityManager(host: "http://extranet.groupe-efrei.fr")
//        
//        manager?.listener = { status in
//            print("Network Status Changed: \(status)\n")
//        }
//        
//        manager?.startListening()
//        
//        logIn { success in
//            self.getVnCodes{ vnCodes in
//                self.studentVnCodes = vnCodes
//                self.getStudentPhoto()
//                for vnCode in self.studentVnCodes {
//                    self.getStudentMarks(vn: vnCode){ marksDict in
//                        self.studentMarks.append(JSON(marksDict))
//                        self.listMarks(jsonFile: JSON(marksDict))
//                    }
//                }
//                self.getInfos()
//            }
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}



