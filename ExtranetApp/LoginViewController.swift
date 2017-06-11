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

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginView: UIView!
    
    @IBOutlet weak var loginButton2: UIButton!
    
    @IBOutlet weak var helpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        loginView.layer.cornerRadius = 10
        loginButton2.layer.borderWidth = 2
        loginButton2.layer.borderColor = UIColor(red:0.21, green:0.95, blue:0.59, alpha:1.0).cgColor
        loginButton2.layer.cornerRadius = 8
        
        usernameTextField.layer.cornerRadius = 8
        passwordTextField.layer.cornerRadius = 8
        usernameTextField.textColor = UIColor.white
        passwordTextField.textColor = UIColor.white
        
        if userDefaults.string(forKey: "password") != nil || userDefaults.string(forKey: "username") != nil{
            passwordTextField.text! = userDefaults.string(forKey: "password")!
            usernameTextField.text! = userDefaults.string(forKey: "username")!
        }
        
        if userDefaults.string(forKey: "isLogged") == nil {
            userDefaults.set("loggedIn", forKey: "notLogged")
        } else {
            if userDefaults.string(forKey: "isLogged")! == "loggedIn" {
                
                if userDefaults.string(forKey: "studentName") != nil || userDefaults.string(forKey: "studentName") != ""{
                    student.loadInfosFromUserDefaults()
                }
                
                
                if Reachability.isConnectedToNetwork() == true {
                    log { success in
                        if success {
                            if userDefaults.string(forKey: "studentName") == nil || userDefaults.string(forKey: "studentName") == ""{
                                student.initInfos { success in
                                    if success {
                                        student.saveInfosToUserDefaults()
                                    }
                                }
                            }
                            
                            print("User successfuly logged in")
                            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                            let naviVC = storyBoard.instantiateViewController(withIdentifier: "MainView")
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.window?.rootViewController = naviVC
                        } else {
                            print("Error while trying to login")
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
        
        log { success in
            if success {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let naviVC = storyBoard.instantiateViewController(withIdentifier: "MainView")
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = naviVC
            } else {
                let alert = UIAlertController(title: "Pas de connexion internet", message: "Verifiez votre connection", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Fermer", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    func log(completionHandler: @escaping (_ success: Bool) -> ()) {
        student.setPassword(password: self.passwordTextField.text!)
        student.setUsername(username: self.usernameTextField.text!)
        
        userDefaults.set(self.passwordTextField.text!, forKey: "password")
        userDefaults.set(self.usernameTextField.text!, forKey: "username")
        
        
        if Reachability.isConnectedToNetwork() == true
        {
            student.logIn { success in
                if success {
                    userDefaults.set("loggedIn", forKey: "isLogged")
                    completionHandler(true)
                } else {
                    print("Bad entries")
                }
            }
        } else {
            completionHandler(false)
        }
    }
}
