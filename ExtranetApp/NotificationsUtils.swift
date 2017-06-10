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
        
        //print(marks1)
        findNewMarks(marks1: marks1, marks2: marks2)

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
        
        var newNotes = [[String]]()
        var y = 0
        
        for i in 0..<marks1.count { // semestres
            
            let semester1 = marks1[i]
            let semester2 = marks2[i]
            
            for d in 0..<semester1.count { // modules
                
                let courses1 = semester1[d]["children"]
                let courses2 = semester2[d]["children"]
                
                for e in 0..<courses1.count { // courses
                    
                    let course1 = courses1[e]["children"]
                    let course2 = courses2[e]["children"]
                    
                    for f in 0..<course1.count {
                        
                        let exam1 = course1[f]
                        let exam2 = course2[f]
                        
                        print(exam1)
                        print(exam2)
                        
                        if exam1["GradePoint"].stringValue != exam2["GradePoint"].stringValue {
                            
                            print("Nouvelle note:\(exam2["Title"].stringValue) : \(exam2["GradePoint"].stringValue)")
                            
                            //let arr = [""]
                            
                            for z in 0..<3 {
                                
                                newNotes[y][z] = ""
                                
                                y+=1
                            }
                        }
                        
                    }
                }
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
    
    
    // Internet connexion needed
    func initNotifications() {
        
        if isNewMarkLoaded(marks1: studentMarksLoaded, marks2: student.getSemesters()) {
            
            findNewMarks(marks1: studentMarksLoaded, marks2: student.getSemesters())
            
            
            print("There are new marks!")
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
