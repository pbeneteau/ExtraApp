//
//  utils.swift
//  ExtranetApp
//
//  Created by antoine beneteau on 2017-06-06.
//  Copyright © 2017 Tastyapp. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire
import JSSAlertView

let userDefaults = UserDefaults.standard
var student = Student()
var notificationsUtils = NotificationsUtils()
var manager = Alamofire.SessionManager.default
var configuration = URLSessionConfiguration.default


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


public func cleanInfosJSON(string: String) -> String {
    
    var personalDataString = ""
    var importantMessageString = ""
    var noAlertsString = ""
    var addressString = ""
    var birthString = ""
    var cityString = ""
    var EMailString = ""
    var nameString = ""
    var mobilePhoneString = ""
    
    let pre = Locale.preferredLanguages[0]
    
    if pre.range(of:"fr") != nil {
        personalDataString = "Infos personnelles"
        importantMessageString = "Messages importants"
        noAlertsString = "Aucune alerte"
        addressString = "Adresse"
        birthString = "Date de naissance"
        cityString = "Ville"
        EMailString = "Courriel"
        nameString = "Nom"
        mobilePhoneString = "Téléphone mobile"
    } else if pre.range(of:"en") != nil {
        personalDataString = "Personal Data"
        importantMessageString = "Important Messages"
        noAlertsString = "No alerts"
        addressString = "Address"
        birthString = "Birthdate"
        cityString = "City"
        EMailString = "E-mail"
        nameString = "Name"
        mobilePhoneString = "Mobile Phone"
    } else {
        return "language error"
    }
    
    var newString = string.replacingOccurrences(of: "<script type=\"text/javascript\">Ext.ComponentManager.onAvailable(\"ExtranetContent\",", with: "")
    newString = newString.replacingOccurrences(of: "function(){", with: "")
    newString = newString.replacingOccurrences(of: "Ext.net.addTo(\"ExtranetContent\",", with: "")
    newString = newString.replacingOccurrences(of: ");</script>", with: "")
    newString = newString.replacingOccurrences(of: ", false);}", with: "")
    newString = newString.replacingOccurrences(of: ",listeners:{afterrender:{fn:function(item){Ext.net.DirectMethod.request({url: '/Student/Absence/Summary', timeout: 600000, cleanRequest: true, eventMask: {showMask:true} });}}}", with: "")
    newString = newString.replacingOccurrences(of: "id:\"ExtranetRightContent\",border:false,xtype:\"panel\",flex:3,", with: "")
    newString = newString.replacingOccurrences(of: "{cls:\"x-panel-alert\",style:\"padding: 5px\",items:[{cls:\"alert-label\",xtype:\"netlabel\",text:\"\(noAlertsString)\"}],layout:\"vbox\",title:\"\(importantMessageString)\"},", with: "")
    
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
    newString = newString.replacingOccurrences(of: ",fieldLabel:\"\(EMailString)\",labelWidth:50", with: "")
    
    newString = newString.replacingOccurrences(of: ",layout:\"hbox\",title:\"\(personalDataString)\"", with: "")

    
    newString = newString.replacingOccurrences(of: "items:", with: "\"items\":")
    newString = newString.replacingOccurrences(of: "id:", with: "\"id\":")
    newString = newString.replacingOccurrences(of: "xtype:", with: "\"xtype\":")
    newString = newString.replacingOccurrences(of: "value:", with: "\"value\":")
    newString = newString.replacingOccurrences(of: "cls:", with: "\"cls\":")
    newString = newString.replacingOccurrences(of: "layout:", with: "\"layout\":")
    
    newString = newString.replacingOccurrences(of: "[{\"items\":[{\"items\":[{\"items\":", with: "{\"items\":[{\"items\":[{\"items\":")
    //newString = newString.replacingOccurrences(of: "]}]}]", with: "]}]}")
    newString = newString.replacingOccurrences(of: "\(nameString) : ", with: "")
    newString = newString.replacingOccurrences(of: "\(birthString) : ", with: "")
    newString = newString.replacingOccurrences(of: "\(addressString) : ", with: "")
    newString = newString.replacingOccurrences(of: "\(cityString) : ", with: "")
    newString = newString.replacingOccurrences(of: "\(mobilePhoneString) : ", with: "")
    
    
    newString = newString.replacingOccurrences(of: "style:", with: "\"style\":")
    newString = newString.replacingOccurrences(of: "text:", with: "\"text\":")
    newString = newString.replacingOccurrences(of: "title:", with: "\"title\":")
    newString = newString.replacingOccurrences(of: "fieldLabel:", with: "\"fieldLabel\":")
    newString = newString.replacingOccurrences(of: "labelWidth:", with: "\"labelWidth\":")
    
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

public func moveToLogin() {
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    let naviVC = storyBoard.instantiateViewController(withIdentifier: "LoginView")
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    appDelegate.window?.rootViewController = naviVC
}

public func moveToProfile() {
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    let naviVC = storyBoard.instantiateViewController(withIdentifier: "MainView")
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    appDelegate.window?.rootViewController = naviVC
}

public func showAlert(title: String, message: String, color: UIColor, sender: UIViewController) {
    let alertview = JSSAlertView().show(sender,
                                        title: title,
                                        text: message,
                                        buttonText: "Fermer",
                                        color: color)
    alertview.setTitleFont("Roboto-Bold")
    alertview.setTextFont("Roboto-Regular")
    alertview.setButtonFont("Roboto-Medium")
    alertview.setTextTheme(.light)
}

extension String {
    func indexDistance(of character: Character) -> Int? {
        guard let index = characters.index(of: character) else { return nil }
        return distance(from: startIndex, to: index)
    }
    
    func slice(from: String, to: String) -> String? {
        
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                substring(with: substringFrom..<substringTo)
            }
        }
    }
}

public func registerNotificationWillEnterForeground(observer: AnyObject, selector: Selector) {
    // Handle when the app becomes active, going from the background to the foreground
    NotificationCenter.default.addObserver(observer, selector: selector, name: .UIApplicationWillEnterForeground, object: nil)
}

public func removeObserverForNotifications(observer: AnyObject) {
    NotificationCenter.default.removeObserver(observer)
}
