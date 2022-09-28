//
//  DetailViewController.swift
//  PhotoSharing
//
//  Created by 陳鈺翔 on 2022/9/28.
//

import UIKit
import Firebase

class DetailViewController: UIViewController {

    enum Section {
        case all
    }
    
    var uid = ""
    var posts: [Post] = []
    var refreshControl: UIRefreshControl!
    var spinner = UIActivityIndicatorView()
    var isLoadingPost = false
    
    lazy var dataSource = configureDataSource()
    
    // MARK: - IBOulet
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var nameLabel: UILabel! {
        didSet {
            nameLabel.text = ""
        }
    }
    @IBOutlet var emailLabel: UILabel! {
        didSet {
            emailLabel.text = ""
        }
    }
    @IBOutlet var profileImage: UIImageView! {
        didSet {
            profileImage.layer.cornerRadius = 50
            profileImage.contentMode = .scaleAspectFill
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUser(uid: uid)
        
        profileImage.downloadProfileImage(uid: uid)
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.black
        refreshControl?.tintColor = UIColor.white
        refreshControl?.addTarget(self, action: #selector(loadPosts), for: UIControl.Event.valueChanged)
        collectionView.refreshControl = refreshControl
        
        spinner.style = .large
        spinner.color = .white
        spinner.hidesWhenStopped = true
        collectionView.addSubview(spinner)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.topAnchor.constraint(equalTo: collectionView.safeAreaLayoutGuide.topAnchor, constant: 150.0),
            spinner.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor)])
        spinner.startAnimating()
        
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        collectionView.collectionViewLayout = createGridLayout()
        
        loadPosts()
    }
    
    func getUser(uid: String) {
        let databaseRef = Database.database().reference().child("users")
        databaseRef.observeSingleEvent(of: .value) { DataSnapshot in
            for item in DataSnapshot.children.allObjects as! [DataSnapshot] {
                
                if item.key == uid {
                    let info = item.value as? [String: Any] ?? [:]
                    self.nameLabel.text = info["name"] as? String
                    self.emailLabel.text = info["email"] as? String
                }
            }
        }
    }
    
    @objc func loadPosts() {
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue.global(qos: .background)
        
        queue.async {
            PostService.shared.loadCurrentUserPosts(uid: self.uid) { posts in
                
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
                self.spinner.stopAnimating()
            }
        }
    }
    
    // MARK: - CollectionView grid layout
    
    func createGridLayout() -> UICollectionViewLayout {
        
        // 一列3個item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // 每一列的高度設定
        var groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(120.0))
        if (self.traitCollection.horizontalSizeClass == .regular && self.traitCollection.verticalSizeClass == .regular) {
            groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(300.0))
        }
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
}

// MARK: - Diffable Data Source

extension DetailViewController {
    
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

extension DetailViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard !isLoadingPost, posts.count - indexPath.row == 4 else {
            return
        }
        
        isLoadingPost = true
        
        guard let timestamp = posts.last?.timestamp, let uid = Auth.auth().currentUser?.uid else {
            isLoadingPost = false
            return
        }
        
        if isLoadingPost {
            spinner.startAnimating()
        }
        
        PostService.shared.getMoreCurrentUserPosts(uid: uid, start: timestamp, limit: 15) { posts in
            
            for post in posts {
                self.posts.append(post)
            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                self.spinner.stopAnimating()
            }
            
            self.isLoadingPost = false
            self.updateSnapshot()
        }
    }
}
