//
//  ComputersAvalaibilityViewController.swift
//  ExtranetApp
//
//  Created by Paul Bénéteau on 25/06/2017.
//  Copyright © 2017 Tastyapp. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import KDCircularProgress

class ComputersAvalaibilityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var upCompurtersLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl: UIRefreshControl!

    var indicatorView: NVActivityIndicatorView! = nil

    
    private var buildings = [String]()
    private var dataJSON: JSON!
    private var buildingComputer = [JSON]()
    private var totalUpComputers = 0
    private var totalComputers = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initActivityIndicatorView()

        initPullToRefresh()
        initTableViewData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initPullToRefresh() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(initTableViewData), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
    }
    
    func initTableViewData() {
        
        self.tableView.contentInset = UIEdgeInsets(top: 20,left: 0,bottom: 0,right: 0)
        
        indicatorView.startAnimating()
        indicatorView.isHidden = false
        
        dataRequest { (success,json,isTimedOut) in
            self.indicatorView.stopAnimating()
            if success {
                self.dataJSON = json
                self.initTableView()
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
                
            } else if isTimedOut {
                showAlert(title: "Attention", message: "Mauvaise connexion internet", color: UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0), sender: self)
                print("time out")
                
            } else {
                showAlert(title: "Attention", message: "Mauvaise connexion internet", color: UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0), sender: self)
                print("error")
            }
        }
    }
    
    func initTableView() {
        
        buildings = ["H","D","C","LI"]
        
        let activeComputers = dataJSON[dataJSON.count - 1]["activity"]
        
        let total = activeComputers["total"]
                
        totalUpComputers = total["down"].intValue
        totalComputers = totalUpComputers + total["up"].intValue
        
        self.upCompurtersLabel.text = "\(totalUpComputers) postes libres sur \(totalComputers)"
        
        let HComputers = activeComputers["H"]
        buildingComputer.append(HComputers)
        let DComputers = activeComputers["D"]
        buildingComputer.append(DComputers)
        let CComputers = activeComputers["C"]
        buildingComputer.append(CComputers)
        let LIComputers = activeComputers["LI"]
        buildingComputer.append(LIComputers)
        
        tableView.reloadData()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buildings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "compaAvaiCell", for: indexPath) as UITableViewCell
        
        (cell.viewWithTag(6))?.layer.cornerRadius = 8
        (cell.viewWithTag(6))?.layer.shadowColor = UIColor.black.cgColor
        (cell.viewWithTag(6))?.layer.shadowOpacity = 0.18
        (cell.viewWithTag(6))?.layer.shadowRadius = 10
        (cell.viewWithTag(6))?.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        
        (cell.viewWithTag(56) as? UILabel)?.text = "Batiment \(buildings[indexPath.row])"
        
        let computersInFloors = buildingComputer[indexPath.row]
        
        var circleTag = 19
        var totalTag = 25
        var upTag = 23
        var floorTag = 31
        
        for (key, floor) in computersInFloors {
            
            let stringJSON = cleanJsonString(string: String(describing: floor))
            
            let newJSON = JSON(convertToDictionary(text: stringJSON)!)
            
            let up = Float(newJSON["down"].intValue)
            let down = Float(newJSON["up"].intValue)
            let total: Float = up + down
            
            let newAngleValue = (up / total) * 360
            
            (cell.viewWithTag(circleTag) as? KDCircularProgress)?.startAngle = -90
            (cell.viewWithTag(circleTag) as? KDCircularProgress)?.angle = Double(newAngleValue)
            
            (cell.viewWithTag(totalTag) as? UILabel)?.text = "/\(Int(total))"
            (cell.viewWithTag(upTag) as? UILabel)?.text = "\(Int(up))"
            
            (cell.viewWithTag(floorTag) as? UILabel)?.text = "Étage \(key)"
            
            circleTag = 21
            totalTag = 29
            upTag = 27
            floorTag = 33
        }
        
        if computersInFloors.count == 1 {
            (cell.viewWithTag(circleTag) as? KDCircularProgress)?.isHidden = true
            (cell.viewWithTag(floorTag) as? UILabel)?.isHidden = true
        } else {
            (cell.viewWithTag(circleTag) as? KDCircularProgress)?.isHidden = false
            (cell.viewWithTag(floorTag) as? UILabel)?.isHidden = false
        }
        
        if indexPath.row == buildings.count - 1 {
            cell.frame.size.height *= 1.5
        }
        cell.selectionStyle = .none
        
        return cell
    }
    
    
    func dataRequest(completionHandler: @escaping (_ success: Bool, _ json: JSON, _ isTimedOut: Bool) -> ()) {
        
        var activeComputers: JSON = JSON("")

        let url = "https://api.eysee.fr/v1/stats/active"

        if Reachability.isConnectedToNetwork() == true {
            
            manager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
                .validate(statusCode: 200..<300)
                .validate(contentType: ["application/json"])
                .responseJSON { response in
                    
                    switch response.result {
                    case .success:
                        if response.result.value != nil {
                            activeComputers = JSON(response.result.value as Any)
                            completionHandler(true, activeComputers, false)
                        } else {
                            completionHandler(false,activeComputers, false)
                        }
                        break
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                        if error._code == NSURLErrorTimedOut {
                            completionHandler(false, activeComputers, true)
                        }
                        completionHandler(false, activeComputers, false)
                        break
                    }
            }
        } else {
            let alert = UIAlertController(title: "Pas d'internet", message: "Verifiez votre connexion", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in self.refreshControl.endRefreshing()}))
            self.present(alert, animated: true, completion: nil)
            completionHandler(false, activeComputers, false)
        }
    }
    
    
    func cleanJsonString(string : String) -> String {
        
        var newString = string
        
        newString = newString.replacingOccurrences(of: "(\"1\", ", with: "")
        newString = newString.replacingOccurrences(of: "(\"2\", ", with: "")
        newString = newString.replacingOccurrences(of: "(\"3\", ", with: "")
        newString = newString.replacingOccurrences(of: ")", with: "")
        
        return newString
    }
    
    func initActivityIndicatorView() {
        
        self.indicatorView = NVActivityIndicatorView(frame: CGRect(x: UIScreen.main.bounds.size.width / 2 - 15, y: UIScreen.main.bounds.size.height / 2 - 15, width: 30, height: 30))
        
        self.indicatorView.type = .ballScaleMultiple
        self.indicatorView.color = UIColor(red:0.21, green:0.95, blue:0.59, alpha:1.0)
        
        self.view.addSubview(indicatorView)
    }
}

extension String {
    
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
}
