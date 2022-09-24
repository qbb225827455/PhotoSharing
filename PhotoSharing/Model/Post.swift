//
//  Post.swift
//  PhotoSharing
//
//  Created by 陳鈺翔 on 2022/8/30.
//

import Foundation

struct Post: Hashable {
    var uuid = UUID()
    
    static func ==(lhs: Post, rhs: Post) -> Bool {
        return lhs.uuid == rhs.uuid
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
    
    
    var postID: String
    var imageFileURL: String
    var username: String
    var uid: String
    var timestamp: Int
    
    enum PostInfoKey {
        static let imageFileURL = "imageFileURL"
        static let username = "username"
        static let uid = "uid"
        static let timestamp = "timestamp"
    }
    
    init(postID: String, imageFileURL: String, username: String, uid: String, timestamp: Int = Int(Date().timeIntervalSince1970 * 1000)) {
        
        self.postID = postID
        self.imageFileURL = imageFileURL
        self.username = username
        self.uid = uid
        self.timestamp = timestamp
    }
    
    init?(postID: String, postInfo: [String: Any]) {
        
        guard let imageFileURL = postInfo[PostInfoKey.imageFileURL] as? String,
              let username = postInfo[PostInfoKey.username] as? String,
              let uid = postInfo[PostInfoKey.uid] as? String,
              let timestamp = postInfo[PostInfoKey.timestamp] as? Int else {
            
            return nil
        }
        
        self = Post(postID: postID, imageFileURL: imageFileURL, username: username, uid: uid, timestamp: timestamp)
    }
}
