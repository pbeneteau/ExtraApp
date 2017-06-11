//
//  LoginViewController.swift
//  ExtranetApp
//
//  Created by antoine beneteau on 2017-06-06.
//  Copyright © 2017 Tastyapp. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import JSSAlertView

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginView: UIView!
    
    @IBOutlet weak var loginButton2: UIButton!
    
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var mainView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configuration.timeoutIntervalForRequest = 6 // seconds
        configuration.timeoutIntervalForResource = 6
        
        manager = Alamofire.SessionManager(configuration: configuration)
        
        
        
        loginView.layer.cornerRadius = 10
        loginButton2.layer.borderWidth = 2
        loginButton2.layer.borderColor = UIColor(red:0.21, green:0.95, blue:0.59, alpha:1.0).cgColor
        loginButton2.layer.cornerRadius = 8
        
        usernameTextField.layer.cornerRadius = 8
        passwordTextField.layer.cornerRadius = 8
    
        
        if userDefaults.string(forKey: "password") != nil || userDefaults.string(forKey: "username") != nil{
            passwordTextField.text! = userDefaults.string(forKey: "password")!
            usernameTextField.text! = userDefaults.string(forKey: "username")!
        }
        
        if userDefaults.string(forKey: "isLogged") != nil {
            if userDefaults.string(forKey: "isLogged") == "loggedIn" {
                self.mainView.isHidden = true
            }
        }
        
        if userDefaults.string(forKey: "isLogged") == nil {
            userDefaults.set("loggedIn", forKey: "notLogged")
        } else {
            if userDefaults.string(forKey: "isLogged")! == "loggedIn" {
                
                if userDefaults.string(forKey: "studentName") != nil || userDefaults.string(forKey: "studentName") != ""{
                    student.loadInfosFromUserDefaults()
                }
                
                if Reachability.isConnectedToNetwork() == true {
                    log { (success,isTimedOut) in
                        if success {
                            student.initInfos { (success,isTimedOut) in
                                if success {
                                    student.saveInfosToUserDefaults { success in
                                        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                                        let naviVC = storyBoard.instantiateViewController(withIdentifier: "MainView")
                                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                        appDelegate.window?.rootViewController = naviVC
                                    }
                                } else if isTimedOut {
                                    print("Time Out")
                                } else {
                                    print("No connection")
                                }
                            }
                            
                        } else if isTimedOut {
                            let alertview = JSSAlertView().show(self,
                                                                title: "Attention",
                                                                text: "Mauvaise connection internet",
                                                                buttonText: "Fermer",
                                                                color: UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0))
                            alertview.setTitleFont("Roboto-Bold")
                            alertview.setTextFont("Roboto-Regular")
                            alertview.setButtonFont("Roboto-Medium")
                            alertview.setTextTheme(.light)
                        } else {
                            let alertview = JSSAlertView().show(self,
                                                                title: "Attention",
                                                                text: "Pas de connection internet",
                                                                buttonText: "Fermer",
                                                                color: UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0))
                            alertview.setTitleFont("Roboto-Bold")
                            alertview.setTextFont("Roboto-Regular")
                            alertview.setButtonFont("Roboto-Medium")
                            alertview.setTextTheme(.light)
                        }
                    }
                } else {
                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                    let naviVC = storyBoard.instantiateViewController(withIdentifier: "MainView")
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = naviVC
                }
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    @IBAction func firstLoginButtonPressed(_ sender: Any) {
        
    }
    
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        loginButtonPressed()
    }
    
    func loginButtonPressed() {
        log { (success, isTimedOut) in
            if success {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let naviVC = storyBoard.instantiateViewController(withIdentifier: "MainView")
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = naviVC
            } else if isTimedOut {
                let alertview = JSSAlertView().show(self,
                                                    title: "Attention",
                                                    text: "Mauvaise connection internet",
                                                    buttonText: "Fermer",
                                                    color: UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0))
                alertview.setTitleFont("Roboto-Bold")
                alertview.setTextFont("Roboto-Regular")
                alertview.setButtonFont("Roboto-Medium")
                alertview.setTextTheme(.light)
            } else {
                let alertview = JSSAlertView().show(self,
                                                    title: "Attention",
                                                    text: "Pas de connection internet",
                                                    buttonText: "Fermer",
                                                    color: UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0))
                alertview.setTitleFont("Roboto-Bold")
                alertview.setTextFont("Roboto-Regular")
                alertview.setButtonFont("Roboto-Medium")
                alertview.setTextTheme(.light)
            }
        }
    }
    
    
    func log(completionHandler: @escaping (_ success: Bool, _ isTimedOut: Bool) -> ()) {
        student.setPassword(password: self.passwordTextField.text!)
        student.setUsername(username: self.usernameTextField.text!)
        
        userDefaults.set(self.passwordTextField.text!, forKey: "password")
        userDefaults.set(self.usernameTextField.text!, forKey: "username")
        
        
        if Reachability.isConnectedToNetwork() == true
        {
            student.logIn { (success, isTimedOut) in
                if success {
                    userDefaults.set("loggedIn", forKey: "isLogged")
                    completionHandler(true, false)
                } else if isTimedOut {
                    completionHandler(false,true)
                
                } else {
                    print("Bad entries")
                    completionHandler(false,false)
                
                }
            }
        } else {
            completionHandler(false, false)
        }
    }
}
