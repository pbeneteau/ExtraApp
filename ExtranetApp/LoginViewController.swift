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
import LocalAuthentication


class LoginViewController: UIViewController {
    
    @IBOutlet weak var splashScreen: UIImageView!
    
    @IBOutlet weak var usernameTextField: KaedeTextField!
    @IBOutlet weak var passwordTextField: KaedeTextField!
    
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var backgroundView: UIImageView!
    
    @IBOutlet weak var loginButton2: TKTransitionSubmitButton!
    
    @IBOutlet weak var helpButton: UIButton!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    var message = ""
    
    var context = LAContext()
    var policy : LAPolicy?
    
    deinit {
        removeObserverForNotifications(observer: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        messageLabel.text = ""
                
        setupController()
        updateUI()
        
        configuration.timeoutIntervalForRequest = 6 // seconds
        configuration.timeoutIntervalForResource = 6
        
        manager = Alamofire.SessionManager(configuration: configuration)
        
        loginButton2.layer.cornerRadius = loginButton2.frame.size.height / 2
        
        // Auto completion des textFields
        if userDefaults.string(forKey: "password") != nil || userDefaults.string(forKey: "username") != nil{
            passwordTextField.text! = userDefaults.string(forKey: "password")!
            usernameTextField.text! = userDefaults.string(forKey: "username")!
        }
        
        // Si deja login
        if userDefaults.string(forKey: "isLogged") != nil {
            if userDefaults.string(forKey: "isLogged") == "loggedIn" {
                
                if userDefaults.bool(forKey: "touchIdLogin") {
                    
                    loginProcess(policy: policy!) { success in
                        self.activityIndicator.startAnimating()
                        if success {
                            self.initLogin()
                        }
                    }
                } else {
                    self.activityIndicator.startAnimating()
                    self.initLogin()
                }
            } else {
                self.splashScreen.isHidden = true
            }
        } else {
            userDefaults.set("loggedIn", forKey: "notLogged")
            self.splashScreen.isHidden = true
            
        }
    }
    
    func initLogin() {
        
        self.mainView.isHidden = true
        self.activityIndicator.startAnimating()
        if Reachability.isConnectedToNetwork() == true {
            self.autoLogin { (success,isTimedOut) in
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
    }
    
    
    private func setupController() {
        registerNotificationWillEnterForeground(observer: self, selector: #selector(self.updateUI))
        
        // The Refresh button will let us to repeat the login process so many times as we want
        //refresh.alpha = 0
    }
    
    
    func updateUI() {
        // Depending the iOS version we'll need to choose the policy we are able to use
        if #available(iOS 9.0, *) {
            // iOS 9+ users with Biometric and Passcode verification
            policy = .deviceOwnerAuthentication
        } else {
            // iOS 8+ users with Biometric and Custom (Fallback button) verification
            context.localizedFallbackTitle = "Fuu!"
            policy = .deviceOwnerAuthenticationWithBiometrics
        }
        
        var err: NSError?
        
        // Check if the user is able to use the policy we've selected previously
        guard context.canEvaluatePolicy(policy!, error: &err) else {
            // Print the localized message received by the system
            print(err?.localizedDescription as Any)
            return
        }
        
        // Great! The user is able to use his/her Touch ID 👍
        
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        loginButtonPressed()
    }
    
    func loginButtonPressed() {
        
        userDefaults.set(false, forKey: "touchIdLogin")
        
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
    
    private func loginProcess(policy: LAPolicy, completionHandler: @escaping (_ success: Bool) -> ()) {
        
        // Start evaluation process with a callback that is executed when the user ends the process successfully or not
        context.evaluatePolicy(policy, localizedReason: "Utiliser Touch ID pour se connecter", reply: { (success, error) in
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5, animations: {
                })
                
                guard success else {
                    guard let error = error else {
                        self.message = "Unexpected error"
                        self.messageLabel.text = self.message
                        print(self.message)
                        completionHandler(false)
                        return
                    }
                    switch(error) {
                    case LAError.authenticationFailed:
                        self.message = "Problème durant la vérification de votre identité."
                    case LAError.userCancel:
                        self.message = "L'authentification a été annulée par l'utilisateur."
                        // Fallback button was pressed and an extra login step should be implemented for iOS 8 users.
                    // By the other hand, iOS 9+ users will use the pasccode verification implemented by the own system.
                    case LAError.userFallback:
                        self.message = "L'utilisateur a activé le bouton de repli."
                    case LAError.systemCancel:
                        self.message = "L'authentification a été annulée par le système."
                    case LAError.passcodeNotSet:
                        self.message = "Le code d'accès n'est pas défini sur l'appareil."
                    case LAError.touchIDNotAvailable:
                        self.message = "Touch ID n'est pas disponible sur l'appareil."
                    case LAError.touchIDNotEnrolled:
                        self.message = "Touch ID n'a pas de doigts configurés."
                    // iOS 9+ functions
                    case LAError.touchIDLockout:
                        self.message = "Il y a eu trop de tentatives d'identification Touch ID donc Touch ID est maintenant verrouillé."
                    case LAError.appCancel:
                        self.message = "L'authentification a été annulée par la demande."
                    case LAError.invalidContext:
                        self.message = "LAContext passé à cet appel a déjà été invalidé."
                    // MARK: IMPORTANT: There are more error states, take a look into the LAError struct
                    default:
                        self.message = "Le Touch ID n'est sans doute pas configuré."
                        break
                    }
                    self.messageLabel.text = self.message
                    print(self.message)
                    completionHandler(false)
                    return
                }
                // Good news! Everything went fine
                self.message = "Authentification réussie!"
                self.messageLabel.text = self.message
                print(self.message)
                completionHandler(true)
            }
        })
    }
    
    
}
