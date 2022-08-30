//
//  PostService.swift
//  PhotoSharing
//
//  Created by 陳鈺翔 on 2022/8/30.
//

import Foundation
import FirebaseStorage
import FirebaseDatabase
import Firebase
import UIKit

class PostService {
    
    static let shared: PostService = PostService()
    
    init() {}
    
    let BASE_DB_REF = Database.database().reference()
    let POST_DB_REF = Database.database().reference().child("posts")
    let POST_PHOTO_STORGE_REF = Storage.storage().reference().child("post_photos")
    
    func uploadImage(image: UIImage, completionHandler: @escaping () -> Void) {
        
        let postsDatabaseRef = POST_DB_REF.childByAutoId()
        
        guard let key = postsDatabaseRef.key,
              let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let userPostsDatabaseRef = BASE_DB_REF.child("users").child(uid).child("posts").child(key)
        let imageKey = key
        
        let imageStorageRef = POST_PHOTO_STORGE_REF.child("\(imageKey).jpg")
        
        let scaleImage = image.scale(newWidth: 640)
        
        guard let imageData = scaleImage.jpegData(compressionQuality: 0.9) else {
            return
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        let uploadTask = imageStorageRef.putData(imageData, metadata: metadata) { metadata, error in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            imageStorageRef.downloadURL { url, error in
                
                guard let displayName = Auth.auth().currentUser?.displayName else {
                    return
                }
                
                guard let url = url else {
                    return
                }
                
                let imageFileURL = url.absoluteString
                let timestamp = Int(Date().timeIntervalSince1970 * 1000)
                
                let post: [String: Any] = ["imageFileURL": imageFileURL,
                                           "username": displayName,
                                           "uid": uid,
                                           "timestamp": timestamp]
                
                postsDatabaseRef.setValue(post)
                userPostsDatabaseRef.setValue(post)
            }
            completionHandler()
        }
        
        let observer = uploadTask.observe(.progress) { StorageTaskSnapshot in
            
            let completePercent = 100.0 * Double(StorageTaskSnapshot.progress!.completedUnitCount) / Double(StorageTaskSnapshot.progress!.totalUnitCount)
            
            print("uid: \(Auth.auth().currentUser?.uid)")
            print("Uploading \(imageKey).jpg...\(completePercent)% complete!")
        }
    }
}
