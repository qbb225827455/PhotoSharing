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
    
    // MARK: - IBOulet
    
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
        
        if let currentUser = Auth.auth().currentUser {
                
            nameLabel.text = currentUser.displayName
            emailLabel.text = currentUser.email
            print("-UID: \(currentUser.uid)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationItem.title = "Profile"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.navigationItem.title = ""
    }
}
