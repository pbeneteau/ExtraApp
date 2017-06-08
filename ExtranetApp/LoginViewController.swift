//
//  LoginViewController.swift
//  ExtranetApp
//
//  Created by antoine beneteau on 2017-06-06.
//  Copyright © 2017 Tastyapp. All rights reserved.
//

import UIKit
import SwiftyJSON

class LoginViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if userDefaults.string(forKey: "password") != nil || userDefaults.string(forKey: "username") != nil{
            passwordTextField.text! = userDefaults.string(forKey: "password")!
            usernameTextField.text! = userDefaults.string(forKey: "username")!
        }
        
        if userDefaults.string(forKey: "isLogged") == nil {
            userDefaults.set("loggedIn", forKey: "notLogged")
        } else {
            if userDefaults.string(forKey: "isLogged")! == "loggedIn" {
                loginButton.isHidden = true
                firstLabel.isHidden = true
                secondLabel.isHidden = true
                usernameTextField.isHidden = true
                passwordTextField.isHidden = true
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
                
                if Reachability.isConnectedToNetwork() == true {
                    log { success in
                        if success {
                            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                            let naviVC = storyBoard.instantiateViewController(withIdentifier: "MainView")
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.window?.rootViewController = naviVC
                            self.activityIndicator.stopAnimating()
                        }
                    }
                } else {
                    student.loadInfosFromUserDefaults()
                    student.loadSemestersFromUserDefaults()
                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                    let naviVC = storyBoard.instantiateViewController(withIdentifier: "MainView")
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = naviVC
                    self.activityIndicator.stopAnimating()
                }
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        log { success in
            if success {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let naviVC = storyBoard.instantiateViewController(withIdentifier: "MainView")
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = naviVC
            } else {
                let alert = UIAlertController(title: "Pas d'internet", message: "Verifiez votre connection", preferredStyle: UIAlertControllerStyle.alert)
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
