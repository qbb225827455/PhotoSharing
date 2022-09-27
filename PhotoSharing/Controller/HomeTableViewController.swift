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
    var uids: [String] = []
    var isLoadingPost = false
    var spinner = UIActivityIndicatorView()
    var usersCount = 0
    
    let semaphore = DispatchSemaphore(value: 0)
    let queue = DispatchQueue.global(qos: .background)
    
    var collectionView: UICollectionView!
    
    // MARK: - 打開相機介面，上傳貼文照片
    // https://github.com/Yummypets/YPImagePicker
    
    @IBAction func openCamera(sender: UIBarButtonItem) {
        
        var config = YPImagePickerConfiguration()
        config.wordings.next = "OK"
        config.wordings.cameraTitle = "Camera"
        config.showsPhotoFilters = false
//        config.library.defaultMultipleSelection = true
//        config.library.maxNumberOfItems = 3
        
        let picker = YPImagePicker(configuration: config)
        picker.navigationBar.backgroundColor = .darkGray
        
        picker.didFinishPicking { [unowned picker] items, _ in
            
            guard let photo = items.singlePhoto else {
                picker.dismiss(animated: true, completion: nil)
                return
            }
//            var time = 0
//            for item in items {
//                time += 1
//                print("select: \(time)")
//            }
            
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
        refreshControl?.addTarget(self, action: #selector(loadUsers), for: UIControl.Event.valueChanged)
        
        spinner.style = .large
        spinner.color = .white
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150.0),
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
        spinner.startAnimating()
        
        configureHeaderView()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        loadNewestPosts()
        loadUsers()
        //PostService.shared.reload()
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
                    self.spinner.stopAnimating()
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
    
    // MARK: - CollecctionView config
    
    func configureHeaderView() {

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: 70, height: 70)

        let headerView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 80), collectionViewLayout: layout)
        headerView.isUserInteractionEnabled = true
        headerView.backgroundColor = .black
        
        collectionView = headerView
        collectionView.register(UINib(nibName: "UserCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "myCollectionCell")
        collectionView.showsHorizontalScrollIndicator = false

        tableView.tableHeaderView = headerView
    }
    
    // MARK: - Load users
    
    @objc func loadUsers() {
        let databaseRef = Database.database().reference().child("users")
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        var uids: [String] = []
        queue.async {
            databaseRef.observeSingleEvent(of: .value) { DataSnapshot in
                self.usersCount = Int(DataSnapshot.childrenCount) - 1
                for item in DataSnapshot.children.allObjects as! [DataSnapshot] {
                    if item.key != uid {
                        uids.append(item.key)
                    }
                }
                self.uids = uids
                self.semaphore.signal()
            }
            self.semaphore.wait()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension HomeTableViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.usersCount + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCollectionCell", for: indexPath) as! UserCollectionViewCell
        if indexPath.row == 0 {
            cell.indexpathRowEuqalZero()
            cell.plusImage.isHidden = false
            if let uid = Auth.auth().currentUser?.uid {
                cell.imageView.downloadProfileImage(uid: uid)
            }
        } else {
            cell.indexpathRowNotEuqalZero()
            cell.plusImage.isHidden = true
            let uid = self.uids[indexPath.row - 1]
            cell.imageView.downloadProfileImage(uid: uid)
        }
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
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
