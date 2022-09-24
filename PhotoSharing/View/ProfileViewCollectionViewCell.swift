//
//  ProfileViewCollectionViewCell.swift
//  PhotoSharing
//
//  Created by 陳鈺翔 on 2022/9/24.
//

import UIKit

class ProfileViewCollectionViewCell: UICollectionViewCell {
 
    var nowpost: Post?
    
    @IBOutlet var imageView: UIImageView!
    
    func configurePost(post: Post) {
        
        nowpost = post
        
        imageView.image = nil
        
        if let image = CacheManager.shared.loadFromCache(key: post.imageFileURL) as? UIImage {
        
            self.imageView.image = image
            
        } else {
            
            if let url = URL(string: post.imageFileURL) {
                let downloadTask = URLSession.shared.dataTask(with: url) { data, response, error in
                    
                    guard let imageData = data else {
                        return
                    }
                    
                    OperationQueue.main.addOperation {
                        guard let downloadImage = UIImage(data: imageData) else {
                            return
                        }
                        if self.nowpost?.imageFileURL == post.imageFileURL {
                            self.imageView.image = downloadImage
                        }
                        CacheManager.shared.saveInCache(obj: downloadImage, key: post.imageFileURL)
                    }
                }
                downloadTask.resume()
            }
        }
    }
}
