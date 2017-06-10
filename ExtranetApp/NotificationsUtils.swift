//
//  Notifications.swift
//  ExtranetApp
//
//  Created by Paul Bénéteau on 10/06/2017.
//  Copyright © 2017 Tastyapp. All rights reserved.
//

import Foundation
import SwiftyJSON

class NotificationsUtils {
    
    var notificationsArray = [String]()
    var studentMarksLoaded = [JSON]()

    
    func isNewMarkLoaded(marks1: [JSON], marks2: [JSON]) -> Bool {
        
        if marks1.count != marks2.count {
            return true
        }
        for i in 0..<marks1.count {
            if marks1[i] != marks2[i] {
                return true
            }
        }
        return false
    }
    
    func findNewMarks(marks1: [JSON], marks2: [JSON]) {
        
        if marks1.count == marks2.count {
            for _ in 0..<marks1.count {
                //let jsonFile1 = marks1[i]
                //let jsonFile2 = marks2[i]
            }
        }
    }
    
    // Internet connexion needed
    func initNotifications() {
        
        if isNewMarkLoaded(marks1: studentMarksLoaded, marks2: student.getMarks()) {
            print("There is new marks!")
            let notif = "Nouvelles notes!"
            notificationsArray.append(notif)
        }
        
    }
    
    func getNotifications() -> [String] {
        return notificationsArray
    }
    
    func setLoadedmarks(json: [JSON]) {
        studentMarksLoaded = json
    }
}
