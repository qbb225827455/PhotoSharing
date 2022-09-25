//
//  PostTableViewController.swift
//  PhotoSharing
//
//  Created by 陳鈺翔 on 2022/8/23.
//

import UIKit
import YPImagePicker
import Firebase
import FirebaseStorage

class HomeTableViewController: UITableViewController {
    
    var posts: [Post] = []
    var isLoadingPost = false
    
    // MARK: - 打開相機介面，上傳貼文照片
    // https://github.com/Yummypets/YPImagePicker
    
    @IBAction func openCamera(sender: UIBarButtonItem) {
        
        var config = YPImagePickerConfiguration()
        config.wordings.next = "OK"
        config.wordings.cameraTitle = "Camera"
        config.showsPhotoFilters = false
        
        let picker = YPImagePicker(configuration: config)
        picker.navigationBar.backgroundColor = .darkGray
        
        picker.didFinishPicking { [unowned picker] items, _ in
            
            guard let photo = items.singlePhoto else {
                picker.dismiss(animated: true, completion: nil)
                return
            }
            
            guard let _ = Auth.auth().currentUser?.uid else {
                return
            }
            
            picker.dismiss(animated: true, completion: nil)
            PostService.shared.uploadPostImage(image: photo.image) {
                self.loadNewestPosts()
            }
        }
        present(picker, animated: true, completion: nil)
    }

    // MARK: - Life cycle
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.separatorStyle = .none
        
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.black
        refreshControl?.tintColor = UIColor.white
        refreshControl?.addTarget(self, action: #selector(loadNewestPosts), for: UIControl.Event.valueChanged)
        
        loadNewestPosts()
    }
    
    // MARK: - 處理貼文
    
    @objc func loadNewestPosts() {
        
        isLoadingPost = true
        
        PostService.shared.getRecentPosts(start: posts.first?.timestamp, limit: 5) { posts in
            
            if posts.count > 0 {
                self.posts.insert(contentsOf: posts, at: 0)
            }
            
            self.isLoadingPost = false
            
            if let _ = self.refreshControl?.isRefreshing {
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                    
                    self.refreshControl?.endRefreshing()
                    self.displayNewestPosts(newPosts: posts)
                }
            } else {
                
                self.displayNewestPosts(newPosts: posts)
            }
        }
    }
    
    func displayNewestPosts(newPosts posts: [Post]) {
        
        guard posts.count > 0 else {
            return
        }
        
        var indexPaths: [IndexPath] = []
        self.tableView.beginUpdates()
        for i in 0...(posts.count - 1) {
            
            let indexPath = IndexPath(row: i, section: 0)
            indexPaths.append(indexPath)
        }
        self.tableView.insertRows(at: indexPaths, with: .fade)
        self.tableView.endUpdates()
    }
}

// MARK: - UITableViewDataSource

extension HomeTableViewController {
   
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "datacell", for: indexPath) as! PostsTableViewCell
        
        cell.profileImageView.downloadProfileImage(uid: posts[indexPath.row].uid)
        cell.configurePost(post: posts[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        print(indexPath.row)
        guard !isLoadingPost, posts.count - indexPath.row == 2 else {
            return
        }
        
        isLoadingPost = true
        
        guard let lastPostTimestamp = posts.last?.timestamp else {
            isLoadingPost = false
            return
        }
        
        PostService.shared.getMorePosts(start: lastPostTimestamp, limit: 3) { posts in
            
            var indexPaths: [IndexPath] = []
            
            self.tableView.beginUpdates()
            for post in posts {
                self.posts.append(post)
                let indexPath = IndexPath(row: self.posts.count - 1, section: 0)
                indexPaths.append(indexPath)
            }
            self.tableView.insertRows(at: indexPaths, with: .fade)
            self.tableView.endUpdates()
            
            self.isLoadingPost = false
        }
    }
}
