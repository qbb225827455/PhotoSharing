//
//  PostsTableViewCell.swift
//  PhotoSharing
//
//  Created by 陳鈺翔 on 2022/8/30.
//

import UIKit

class PostsTableViewCell: UITableViewCell, UIScrollViewDelegate {

    var nowpost: Post?
    var width = 0.0
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var profileImageView: UIImageView! {
        didSet {
            profileImageView.layer.cornerRadius = 15
            profileImageView.clipsToBounds = true
            profileImageView.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var view: UIView!
    @IBOutlet var pageControl: UIPageControl!
    
    @IBAction func pageChange(_ sender: UIPageControl) {
        let currentPage = sender.currentPage
        let offset = CGPoint(x: self.width * CGFloat(currentPage), y: 0)
        scrollView.setContentOffset(offset, animated: true)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func clearSubView() {
        for subview in scrollView.subviews {
            subview.removeFromSuperview()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = currentPage
    }
    
    func configWidth() {
        if traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular {
            self.width = UIScreen.main.bounds.width - 200
        } else {
            self.width = self.frame.width
        }
    }
    
    func configScrollView() {
        
        configWidth()
        scrollView.delegate = self
        scrollView.contentSize.width = self.width * 3
        scrollView.frame = CGRect(x: 0, y: 0, width: width, height: 400)
        scrollView.contentSize.height = 400
        scrollView.backgroundColor = .black
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        
        pageControl.currentPage = 0
        pageControl.numberOfPages = 3
        
        for i in 1...2 {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "startView-background")
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(x: self.width * CGFloat(i), y: 0, width: self.width, height: 400)
            scrollView.addSubview(imageView)
        }
    }
    
    func configurePost(post: Post) {
        
        nowpost = post
        configWidth()
        self.selectionStyle = .none
        nameLabel.text = post.username
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: self.width, height: 400)
        
        if let image = CacheManager.shared.loadFromCache(key: post.imageFileURL) as? UIImage {
        
            imageView.image = image
            self.scrollView.addSubview(imageView)
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
                            imageView.image = downloadImage
                            self.scrollView.addSubview(imageView)
                        }
                        CacheManager.shared.saveInCache(obj: downloadImage, key: post.imageFileURL)
                    }
                }
                downloadTask.resume()
            }
        }
    }

}
