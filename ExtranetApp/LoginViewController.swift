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
        
        
        // Auto completion des textFields
        if userDefaults.string(forKey: "password") != nil || userDefaults.string(forKey: "username") != nil{
            passwordTextField.text! = userDefaults.string(forKey: "password")!
            usernameTextField.text! = userDefaults.string(forKey: "username")!
        }
        
        // Si deja login
        if userDefaults.string(forKey: "isLogged") != nil {
            if userDefaults.string(forKey: "isLogged") == "loggedIn" {
                self.mainView.isHidden = true
                if Reachability.isConnectedToNetwork() == true {
                    autoLogin { (success,isTimedOut) in
                        if success {
                            self.initInformations { (success,isTimedOut) in
                                if success {
                                    moveToProfile()
                                } else {
                                    self.initInformations { (success,isTimedOut) in
                                        if success {
                                            moveToProfile()
                                        }
                                    }
                                }
                            }
                        } else {
                            self.initInformations { (success,isTimedOut) in
                                if success {
                                    moveToProfile()
                                }
                            }
                        }
                    }
                } else {
                    self.initInformations { (success,isTimedOut) in
                        if success {
                            moveToProfile()
                        }
                    }
                }
            }
        } else {
            userDefaults.set("loggedIn", forKey: "notLogged")
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
        
        if self.passwordTextField.text! != "" {
            if self.usernameTextField.text! != "" {
                student.setPassword(password: self.passwordTextField.text!)
                student.setUsername(username: self.usernameTextField.text!)
                
                userDefaults.set(self.passwordTextField.text!, forKey: "password")
                userDefaults.set(self.usernameTextField.text!, forKey: "username")
                
                log { (success, isTimedOut) in
                    if success { // Redirection Profile
                        self.initInformations { (success,isTimedOut) in
                            if success {
                                moveToProfile()
                            } else if isTimedOut {
                                showAlert(title: "Attention", message: "Mauvaise connection internet", color: UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0), sender: self)
                            } else {
                                showAlert(title: "Attention", message: "Pas de connection internet", color: UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0), sender: self)
                            }
                        }
                    } else if isTimedOut { // Time Out
                        showAlert(title: "Attention", message: "Mauvaise connection internet", color: UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0), sender: self)
                    } else { // Pas de connection
                        showAlert(title: "Attention", message: "Pas de connection internet", color: UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0), sender: self)
                    }
                }
                
            } else {
                showAlert(title: "Attention", message: "Veuillez entrer correctement vos Ids", color: UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0), sender: self)
            }
        } else {
            showAlert(title: "Attention", message: "Veuillez entrer correctement vos Ids", color: UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0), sender: self)
        }
    }
    
    
    func log(completionHandler: @escaping (_ success: Bool, _ isTimedOut: Bool) -> ()) {
        
        
        if Reachability.isConnectedToNetwork() == true
        {
            student.logIn { (success, isTimedOut) in
                if success { // Connection réussie
                    userDefaults.set("loggedIn", forKey: "isLogged") // Pour retser connecté
                    completionHandler(true, false)
                } else if isTimedOut { // Connection Time Out
                    completionHandler(false,true)
                } else { // Autre erreur
                    completionHandler(false,false)
                }
            }
        } else { // Pas de connection internet
            completionHandler(false, false)
        }
    }
    
    func autoLogin(completionHandler: @escaping (_ success: Bool, _ isTimedOut: Bool) -> ()) {
        if userDefaults.string(forKey: "username") != nil && userDefaults.string(forKey: "password") != nil {
            if userDefaults.string(forKey: "username")! != "" && userDefaults.string(forKey: "password")! != "" {
                
                student.setPassword(password: userDefaults.string(forKey: "password")!)
                student.setUsername(username: userDefaults.string(forKey: "username")!)
                
                student.logIn { (success, isTimedOut) in
                    if success { // Connection réussie
                        completionHandler(true, false)
                    } else if isTimedOut { // Connection Time Out
                        completionHandler(false,true)
                    } else { // Autre erreur
                        completionHandler(false,false)
                        
                    }
                }
            }
        }
    }
    
    func initInformations(completionHandler: @escaping (_ success: Bool, _ isTimedOut: Bool) -> ()) {
        student.loadInfosFromUserDefaults() { success in
            if success { // Deja dans UserDefaults
                completionHandler(true, false)
            } else { // Pas dans UserDefaults
                student.initInfos { (success, isTimedOut) in
                    if success {
                        student.saveInfosToUserDefaults { success in
                            completionHandler(true,false)
                        }
                    } else if isTimedOut {
                        completionHandler(false,true)
                    } else {
                        completionHandler(false, false)
                    }
                }
            }
        }
    }
}
