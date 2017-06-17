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
    
    var msgDisplayed = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = student.getName()
        student.downloadPicture { picture in
            let newPic = self.resizeImage(image: picture, targetSize: self.picture.frame.size)
            self.picture.image = newPic
            self.picture.clipsToBounds = true
            self.picture.layer.cornerRadius = newPic.size.height / 2
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        if (userDefaults.string(forKey: "isLogged") != nil) {
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

