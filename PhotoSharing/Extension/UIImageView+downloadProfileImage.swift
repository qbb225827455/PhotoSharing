//
//  UIImageView+Ext.swift
//  PhotoSharing
//
//  Created by 陳鈺翔 on 2022/8/25.
//

import UIKit
import Firebase
import FirebaseStorage

var imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    func downloadProfileImage(uid: String) {
        
        let uidphotoString = "\(uid)photo"
        print("#### uidphotoString ####")
        print(uidphotoString)
        if let cacheImage = imageCache.object(forKey: uidphotoString as NSString) {
            self.image = cacheImage
            print("Get image from cache!")
            return
        }
        
        let databaseRef = Database.database().reference().child("users").child(uid)
        
        databaseRef.observeSingleEvent(of: .value) { DataSnapshot in
            
            let profileImageURL = DataSnapshot.childSnapshot(forPath: "profileImageURL").value  as! String
            let ref = Storage.storage().reference(forURL: profileImageURL)
            
            ref.getData(maxSize: 3 * 1024 * 1024) { data, error in
                
                if error != nil {
                    return
                }
                
                guard let data = data else {
                    return
                }
                
                if let downloadImage = UIImage(data: data) {
                    imageCache.setObject(downloadImage, forKey:  uidphotoString as NSString)
                    print("Set image into cache!")
                    self.image = downloadImage
                }
            }
        }
    }
}
