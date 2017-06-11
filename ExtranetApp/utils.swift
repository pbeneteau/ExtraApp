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

extension String {
    func indexDistance(of character: Character) -> Int? {
        guard let index = characters.index(of: character) else { return nil }
        return distance(from: startIndex, to: index)
    }
}
