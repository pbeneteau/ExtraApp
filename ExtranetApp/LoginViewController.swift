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
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        student.setPassword(password: self.passwordTextField.text!)
        student.setUsername(username: self.usernameTextField.text!)
        
        student.logIn { success in
            if success {
                self.performSegue(withIdentifier: "loginSucceed", sender: nil)
            } else {
                print("Bad entries")
            }
        }
    }


}
