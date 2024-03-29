//
//  Notifications.swift
//  ExtranetApp
//
//  Created by Paul Bénéteau on 10/06/2017.
//  Copyright © 2017 Tastyapp. All rights reserved.
//

import Foundation
import SwiftyJSON
import Whisper


class NotificationsUtils: NSObject {
    
    var notificationsArray = [String]()
    var studentMarksLoaded = [JSON]()
    var newNotesPath = [[Int]]()
    let requestIdentifier = "SampleRequest"
    
    override init() {
        
    }
    
    // Internet connexion needed
    func initNotifications() {
        
        notificationsArray.removeAll()
        
        if isNewMarkLoaded(marks1: studentMarksLoaded, marks2: student.getSemesters()) {
            
            var murmur = Murmur(title: "Des notes ont été ajoutées!")
            murmur.backgroundColor = UIColor(red:0.16, green:0.50, blue:0.73, alpha:1.0)
            murmur.titleColor = UIColor.white
            
            // Show and hide a message after delay
            Whisper.show(whistle: murmur, action: .show(4))
            
            findNewMarks(marks1: studentMarksLoaded, marks2: student.getSemesters())
        }
    }
    
    public func isNewMarkLoaded(marks1: [JSON], marks2: [JSON]) -> Bool {
        
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
    
    public func findNewMarks(marks1: [JSON], marks2: [JSON]) {
        newNotesPath.removeAll()
        
        if marks1.count > 0  && marks2.count > 0 {
            
            if marks1.count == marks2.count {
                
                for a in 0..<marks1.count { // semestres
                    
                    let semester1 = marks1[a]
                    let semester2 = marks2[a]
                    
                    for b in 0..<semester1.count { // modules
                        
                        let courses1 = semester1[b]["children"]
                        let courses2 = semester2[b]["children"]
                        
                        for c in 0..<courses1.count { // courses
                            
                            let course1 = courses1[c]["children"]
                            let course2 = courses2[c]["children"]
                            
                            for d in 0..<course1.count {
                                
                                let exam1 = course1[d]
                                let exam2 = course2[d]
                                
                                if exam1["GradePoint"].stringValue != exam2["GradePoint"].stringValue {
                                    
                                    print("Nouvelle note:\(exam2["Title"].stringValue) : \(exam2["GradePoint"].stringValue)")
                                    
                                    newNotesPath.append([a,b,c,d])
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getNotifications() -> [String] {
        return notificationsArray
    }
    
    func setLoadedmarks(json: [JSON]) {
        studentMarksLoaded = json
    }
    
    func getNewMarksPath() -> [[Int]] {
        return newNotesPath
    }
}
