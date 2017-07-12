//
//  SettingsTableViewController.swift
//  ExtranetApp
//
//  Created by Paul Bénéteau on 05/07/2017.
//  Copyright © 2017 Tastyapp. All rights reserved.
//

import UIKit
import LocalAuthentication

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var averagesCalculationSwitch: UISwitch!
    @IBOutlet weak var touchIDSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUserSettingsValues()
        
    }
    
    func initUserSettingsValues() {
        
        if userDefaults.object(forKey: "averagesCalculation") != nil {
            
            let state = userDefaults.bool(forKey: "averagesCalculation")
            if state == true {
                averagesCalculationSwitch.isOn = true
            } else {
                averagesCalculationSwitch.isOn = false
            }
        } else {
            userDefaults.set(true, forKey: "averagesCalculation")
            averagesCalculationSwitch.isOn = true
        }
        
        if userDefaults.object(forKey: "touchIdLogin") != nil {
            
            let state = userDefaults.bool(forKey: "touchIdLogin")
            if state == true {
                touchIDSwitch.isOn = true
            } else {
                touchIDSwitch.isOn = false
            }
        } else {
            userDefaults.set(true, forKey: "touchIdLogin")
            touchIDSwitch.isOn = false
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func AveragesCalculationSwitchAction(_ sender: Any) {
        if averagesCalculationSwitch.isOn {
            userDefaults.set(true, forKey: "averagesCalculation")
        } else {
            userDefaults.set(false, forKey: "averagesCalculation")
        }
    }
    
    @IBAction func touchIDSwitchAction(_ sender: Any) {
        if touchIDSwitch.isOn {
            
            var authError : NSError?
            if LAContext().canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                if authError?.code != nil {
                    showAlertViewIfNoBiometricSensorHasBeenDetected()
                } else {
                    userDefaults.set(true, forKey: "touchIdLogin")
                }
            }
        } else {
            userDefaults.set(false, forKey: "touchIdLogin")
        }
    }
    
    func showAlertViewIfNoBiometricSensorHasBeenDetected(){
        
        showAlertWithTitle(title: "Erreur", message: "Cet apareil n'a pas de capteur TouchID.")
        
    }
    
    func showAlertWithTitle( title:String, message:String ) {
        
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertVC.addAction(okAction)
        
        DispatchQueue.main.async() { () -> Void in
            
            self.present(alertVC, animated: true, completion: nil)
            
        }
        
    }
}
