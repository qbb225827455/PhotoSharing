//
//  SignUPViewController.swift
//  PhotoSharing
//
//  Created by 陳鈺翔 on 2022/8/18.
//

import UIKit
import YPImagePicker
import Firebase
import FirebaseStorage
import SwiftUI


class SignUPViewController: UIViewController {

    var blurEffectView: UIVisualEffectView!
    
    // MARK: - IBOutlet
    
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var profileImage: UIImageView! {
        didSet {
            profileImage.layer.cornerRadius = 100
            profileImage.tintColor = .white
            profileImage.contentMode = .scaleAspectFill
            profileImage.image = UIImage(systemName: "person.circle")
            profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectProfileImage)))
            profileImage.isUserInteractionEnabled = true
        }
    }
    
    // MARK: - 註冊帳戶
    
    @IBAction func registerAccount(sender: UIButton) {
        
        // 確認有沒有輸入全部欄位
        guard let name = nameTextField.text, name != "",
              let email = emailTextField.text, email != "",
              let password = passwordTextField.text, password != "" else {
            
            let alertController = UIAlertController(title: "Register error", message: "Please make sure you provide all your information to complete the register", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(OKAction)
            present(alertController, animated: true, completion: nil)
            
            return
        }
        
        // 在 Firebase 註冊帳號
        Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
            
            if let error = error {
                let alertController = UIAlertController(title: "Register error", message: error.localizedDescription, preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            
            // Update a user's profile
            if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                changeRequest.displayName = name
                changeRequest.commitChanges { error in
                  
                    if let error = error {
                        print("\(error.localizedDescription)")
                    }
                }
            }
            
            guard let uid = Auth.auth().currentUser?.uid else {
                return
            }
            
            let userDatabaseRef = Database.database().reference().child("users").child(uid)
            guard let imageKey = userDatabaseRef.key else {
                return
            }
            
            let profileImageStorgeRef = Storage.storage().reference().child("profile_photos").child("\(imageKey).jpg")
            
            guard var imageData = self.profileImage.image?.jpegData(compressionQuality: 0.5) else {
                return
            }
            
            while imageData.count > 2 * 1024 * 1024 {
                let newData = UIImage(data: imageData)?.jpegData(compressionQuality: 0.9)
                imageData = newData!
            }
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            
            profileImageStorgeRef.putData(imageData, metadata: metadata) { metadata, error in
                
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                profileImageStorgeRef.downloadURL { url, error in
                    
                    guard let url = url else {
                        return
                    }
                    
                    let imageFileURL = url.absoluteString
                    
                    let values: [String: Any] = ["name": name,
                                                 "email": email,
                                                 "profileImageURL": imageFileURL]
                    userDatabaseRef.setValue(values)
                }
            }
            
            self.view.endEditing(true)
            
            let alertController = UIAlertController(title: "Complete create account!", message: "", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .cancel, handler: { action in
                
                // 註冊成功後到 HomeView
                if let HomeViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeView") {
                    
                    UIApplication.shared.keyWindow?.rootViewController = HomeViewController
                    self.dismiss(animated: true)
                }
                
            })
            
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
        })
    }
    
    // MARK: - ImagePicker
    
    @objc func selectProfileImage() {
        
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
            
            self.profileImage.image = photo.image
            picker.dismiss(animated: true)
        }
        present(picker, animated: true, completion: nil)
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Sign Up"
        nameTextField.becomeFirstResponder()
        
        let blurEffect = UIBlurEffect(style: .dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView!.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView!)
    }
    
    override func viewWillLayoutSubviews() {
        
        blurEffectView.frame = view.bounds
    }
}
