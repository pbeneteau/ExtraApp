//
//  ProfileViewController.swift
//  ExtranetApp
//
//  Created by antoine beneteau on 2017-06-06.
//  Copyright © 2017 Tastyapp. All rights reserved.
//

import UIKit
import Alamofire
import UserNotificationsUI
import UserNotifications
import Whisper

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    private var profilePicture: UIImage!
    
    var msgDisplayed = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = student.getName()
        
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
        let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if let dirPath          = paths.first
        {
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent("profilePic.jpg")
            if let image    = UIImage(contentsOfFile: imageURL.path) {
                let resizedPic = self.resizeImage(image: image, targetSize: self.picture.frame.size)
                
                self.picture.image = resizedPic
                self.picture.clipsToBounds = true
            } else {
                student.downloadPicture { (success, pictureData, timeOut) in
                    if success {
                        if let picture = UIImage(data: pictureData) {
                            
                            if let data = UIImageJPEGRepresentation(picture, 1) {
                                let filename = self.getDocumentsDirectory().appendingPathComponent("profilePic.jpg")
                                try? data.write(to: filename)
                            }
                            
                            self.profilePicture = picture
                            let newPic = self.resizeImage(image: self.profilePicture, targetSize: self.picture.frame.size)
                            self.picture.image = newPic
                            self.picture.clipsToBounds = true
                            self.saveProfilePiture()
                        }
                    }
                }
            }
        } else {
            
            if let imageData = userDefaults.object(forKey: "profilePicture"),
                let image = UIImage(data: (imageData as! Data)) {
                let newPic = self.resizeImage(image: image, targetSize: self.picture.frame.size)
                self.picture.image = newPic
                self.picture.clipsToBounds = true
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if Reachability.isConnectedToNetwork() == false && msgDisplayed == 0{
            
            var murmur = Murmur(title: "Pas de connexion: Mode hors ligne")
            murmur.backgroundColor = UIColor(red:0.20, green:0.29, blue:0.37, alpha:1.0)
            murmur.titleColor = UIColor.white
            
            // Show and hide a message after delay
            Whisper.show(whistle: murmur, action: .show(5))
            
            msgDisplayed = 1
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func saveProfilePiture() {
        userDefaults.set(UIImagePNGRepresentation(self.profilePicture), forKey: "profilePicture")
    }
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        if (userDefaults.string(forKey: "isLogged") != nil) {
            
            userDefaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            userDefaults.synchronize()
            
            userDefaults.set("notLogged", forKey: "isLogged")

            moveToLogin()
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
}

