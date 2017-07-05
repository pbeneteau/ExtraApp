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
import TextFieldEffects
import TKSubmitTransitionSwift3
import NVActivityIndicatorView

class LoginViewController: UIViewController {
    
    @IBOutlet weak var splashScreen: UIImageView!
    
    @IBOutlet weak var usernameTextField: KaedeTextField!
    @IBOutlet weak var passwordTextField: KaedeTextField!
    
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var backgroundView: UIImageView!
    
    @IBOutlet weak var loginButton2: TKTransitionSubmitButton!
    
    @IBOutlet weak var helpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configuration.timeoutIntervalForRequest = 6 // seconds
        configuration.timeoutIntervalForResource = 6
        
        manager = Alamofire.SessionManager(configuration: configuration)
        
        loginButton2.layer.cornerRadius = loginButton2.frame.size.height / 2
        
        self.activityIndicator.startAnimating()
        
        // Auto completion des textFields
        if userDefaults.string(forKey: "password") != nil || userDefaults.string(forKey: "username") != nil{
            passwordTextField.text! = userDefaults.string(forKey: "password")!
            usernameTextField.text! = userDefaults.string(forKey: "username")!
        }
        
        // Si deja login
        if userDefaults.string(forKey: "isLogged") != nil {
            if userDefaults.string(forKey: "isLogged") == "loggedIn" {
                self.mainView.isHidden = true
                self.activityIndicator.startAnimating()
                if Reachability.isConnectedToNetwork() == true {
                    autoLogin { (success,isTimedOut) in
                        if success {
                            self.initInformations { (success,isTimedOut) in
                                if success {
                                    self.activityIndicator.stopAnimating()
                                    moveToProfile()
                                    self.splashScreen.isHidden = true
                                }
                            }
                        } else {
                            self.initInformations { (success,isTimedOut) in
                                if success {
                                    self.activityIndicator.stopAnimating()
                                    moveToProfile()
                                    self.splashScreen.isHidden = true
                                }
                            }
                        }
                    }
                } else {
                    self.initInformations { (success,isTimedOut) in
                        if success {
                            self.activityIndicator.stopAnimating()
                            moveToProfile()
                            self.splashScreen.isHidden = true
                        }
                    }
                }
            } else {
                self.splashScreen.isHidden = true
            }
        } else {
            userDefaults.set("loggedIn", forKey: "notLogged")
            self.splashScreen.isHidden = true

        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
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
                
                loginButton2.startLoadingAnimation()
                
                if Reachability.isConnectedToNetwork() == true
                {
                    log { (success, isTimedOut) in
                        if success { // Redirection Profile
                            if userDefaults.string(forKey: "username") != nil {
                                if userDefaults.string(forKey: "username") !=  self.usernameTextField.text!{
                                    if let bundle = Bundle.main.bundleIdentifier {
                                        UserDefaults.standard.removePersistentDomain(forName: bundle)
                                    }
                                }
                            }
                            self.initInformations { (success,isTimedOut) in
                                if success {
                                    self.view.endEditing(true)
                                    self.loginButton2.startFinishAnimation(0) {
                                        moveToProfile()
                                    }
                                } else if isTimedOut {
                                    self.view.endEditing(true)
                                    self.loginButton2.returnToOriginalState()
                                    showAlert(title: "Attention", message: "Mauvaise connexion internet", color: UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0), sender: self)
                                } else {
                                    self.view.endEditing(true)
                                    self.loginButton2.returnToOriginalState()
                                    showAlert(title: "Attention", message: "Pas de connexion internet", color: UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0), sender: self)
                                }
                            }
                        } else if isTimedOut { // Time Out
                            self.view.endEditing(true)
                            self.loginButton2.returnToOriginalState()
                            showAlert(title: "Attention", message: "Mauvaise connexion internet", color: UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0), sender: self)
                        } else { // Mauvaise combinaison
                            self.view.endEditing(true)
                            self.loginButton2.returnToOriginalState()
                            showAlert(title: "Attention", message: "Mauvaise combinaison", color: UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0), sender: self)
                        }
                    }
                } else { // Pas de connection
                    self.view.endEditing(true)
                    self.loginButton2.returnToOriginalState()
                    showAlert(title: "Attention", message: "Pas de connexion internet", color: UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0), sender: self)
                }
                
                
            } else {
                self.view.endEditing(true)
                showAlert(title: "Attention", message: "Veuillez entrer correctement vos Ids", color: UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0), sender: self)
            }
        } else {
            self.view.endEditing(true)
            showAlert(title: "Attention", message: "Veuillez entrer correctement vos Ids", color: UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0), sender: self)
        }
    }
    
    
    func log(completionHandler: @escaping (_ success: Bool, _ isTimedOut: Bool) -> ()) {
        student.logIn { (success, isTimedOut) in
            if success { // Connection réussie
                userDefaults.set("loggedIn", forKey: "isLogged") // Pour retser connecté
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
            } else if isTimedOut { // Connection Time Out
                completionHandler(false,true)
            } else { // Autre erreur
                completionHandler(false,false)
            }
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
