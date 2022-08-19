//
//  ProfileViewController.swift
//  PhotoSharing
//
//  Created by 陳鈺翔 on 2022/8/19.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentUser = Auth.auth().currentUser {
                
            nameLabel.text = currentUser.displayName
            emailLabel.text = currentUser.email
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationItem.title = "Profile"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.navigationItem.title = ""
    }
}
