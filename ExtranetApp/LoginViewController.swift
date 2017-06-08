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
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordTextField.text! = defaults.string(forKey: "password")!
        usernameTextField.text! = defaults.string(forKey: "username")!
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        student.setPassword(password: self.passwordTextField.text!)
        student.setUsername(username: self.usernameTextField.text!)
        
        defaults.set(self.passwordTextField.text!, forKey: "password")
        defaults.set(self.usernameTextField.text!, forKey: "username")
        
        student.logIn { success in
            if success {
                self.performSegue(withIdentifier: "loginSucceed", sender: nil)
            } else {
                print("Bad entries")
            }
        }
    }
    
    
}
