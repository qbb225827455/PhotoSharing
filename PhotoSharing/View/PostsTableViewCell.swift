//
//  PostsTableViewCell.swift
//  PhotoSharing
//
//  Created by 陳鈺翔 on 2022/8/30.
//

import UIKit

class PostsTableViewCell: UITableViewCell {

    var nowpost: Post?
    
    @IBOutlet var nameLabel: UILabel!

    @IBOutlet var postImageView: UIImageView! {
        didSet {
            postImageView.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet var profileImageView: UIImageView! {
        didSet {
            profileImageView.layer.cornerRadius = 15
            profileImageView.clipsToBounds = true
            profileImageView.contentMode = .scaleAspectFill
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configurePost(post: Post) {
        
        nowpost = post
        
        self.selectionStyle = .none
        nameLabel.text = post.username

        postImageView.image = nil
        
        if let image = CacheManager.shared.loadFromCache(key: post.imageFileURL) as? UIImage {
        
            self.postImageView.image = image
            
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
                            self.postImageView.image = downloadImage
                        }
                        self.profileImageView.downloadProfileImage(uid: post.uid)
                        CacheManager.shared.saveInCache(obj: downloadImage, key: post.imageFileURL)
                    }
                }
                downloadTask.resume()
            }
        }
    }

}
