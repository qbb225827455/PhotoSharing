//
//  ProfileViewController.swift
//  PhotoSharing
//
//  Created by 陳鈺翔 on 2022/8/19.
//

import UIKit
import Firebase
import FirebaseStorage

class ProfileViewController: UIViewController {
    
    enum Section {
        case all
    }
    
    var posts: [Post] = []
    var refreshControl: UIRefreshControl!
    
    lazy var dataSource = configureDataSource()
    
    // MARK: - IBOulet
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var profileImage: UIImageView! {
        didSet {
            profileImage.layer.cornerRadius = 50
            profileImage.contentMode = .scaleAspectFill
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImage.downloadProfileImage(uid: Auth.auth().currentUser!.uid)
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.black
        refreshControl?.tintColor = UIColor.white
        refreshControl?.addTarget(self, action: #selector(loadPosts), for: UIControl.Event.valueChanged)
        collectionView.refreshControl = refreshControl
        
        if let currentUser = Auth.auth().currentUser {
                
            nameLabel.text = currentUser.displayName
            emailLabel.text = currentUser.email
            print("-UID: \(currentUser.uid)")
        }
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            
            layout.itemSize = CGSize(width: 80, height: 80)
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            layout.estimatedItemSize = .zero
        }
        
        collectionView.dataSource = dataSource
        
        loadPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationItem.title = "Profile"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.navigationItem.title = ""
    }
    
    @objc func loadPosts() {
        
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue.global(qos: .background)
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        queue.async {
            PostService.shared.loadCurrentUserPosts(uid: uid) { posts in
                
                if posts.count > 0 {
                    self.posts = posts
                }
                semaphore.signal()
            }
            semaphore.wait()
            
            
            self.updateSnapshot()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                if let refreshControl = self.refreshControl {
                    if refreshControl.isRefreshing {
                        refreshControl.endRefreshing()
                    }
                }
            }
        }
    }
}

// MARK: - Diffable Data Source

extension ProfileViewController {
    
    func configureDataSource() -> UICollectionViewDiffableDataSource<Section, Post> {

        let dataSource = UICollectionViewDiffableDataSource<Section, Post>(collectionView: collectionView) { (collectionView, indexPath, imageName) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ProfileViewCollectionViewCell
            cell.configurePost(post: self.posts[indexPath.row])
            
            return cell
        }

        return dataSource
    }
    
    func updateSnapshot(animatingChange: Bool = false) {

        var snapshot = NSDiffableDataSourceSnapshot<Section, Post>()
        snapshot.appendSections([.all])
        snapshot.appendItems(posts, toSection: .all)

        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
