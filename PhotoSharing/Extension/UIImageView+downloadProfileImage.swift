//
//  UIImageView+Ext.swift
//  PhotoSharing
//
//  Created by 陳鈺翔 on 2022/8/25.
//

import UIKit
import Firebase
import FirebaseStorage

extension UIImageView {
    
    func downloadProfileImage(uid: String) {
        
        let uidphotoString = "\(uid)photo"
        print("#### uidphotoString ####")
        print(uidphotoString)
        
        if let data = UserDefaults.standard.data(forKey: uidphotoString) {
            print("Load image from UserDefaults by key \(uidphotoString).")
            let decoded = try! PropertyListDecoder().decode(Data.self, from: data)
            self.image = UIImage(data: decoded)
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
                    let data = downloadImage.jpegData(compressionQuality: 1)
                    let encoded = try! PropertyListEncoder().encode(data)
                    UserDefaults.standard.set(encoded, forKey: uidphotoString)
                    print("Save image to UserDefaults by key \(uidphotoString).")
                    self.image = downloadImage
                }
            }
        }
    }
}
