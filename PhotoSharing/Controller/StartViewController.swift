//
//  StartViewController.swift
//  PhotoSharing
//
//  Created by 陳鈺翔 on 2022/8/18.
//

import UIKit
import Firebase
import FirebaseStorage
import FacebookLogin
import GoogleSignIn

class StartViewController: UIViewController {
    
    var blurEffectView: UIVisualEffectView!
    
    // MARK: - IBOutlet
    
    @IBOutlet var backgroundImageView: UIImageView!
    
    // MARK: - IBAction
    
    @IBAction func unwindToStartView(segue: UIStoryboardSegue) {
        dismiss(animated: true)
    }
    
    // MARK: - Facebook Login
    // https://developers.facebook.com/docs/facebook-login/ios/advanced
    
    @IBAction func facebookLogin(sender: UIButton) {
        
        let loginManager = LoginManager()
        loginManager.logOut()
        
        // 除了 email 和 public_profile，其他權限皆需要應用程式審查
        // https://developers.facebook.com/docs/permissions/reference#login_permissions
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { result, error in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let result = result, result.isCancelled {
                
                print("Cancelled")
                return
            }
            
            guard let idTokenString = AccessToken.current?.tokenString else {
                print("Failed to get token")
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: idTokenString)
            
            // Authenticate with Firebase
            Auth.auth().signIn(with: credential, completion: { authResult, error in
                
                if let error = error {
                    let alertController = UIAlertController(title: "Login error", message: error.localizedDescription, preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    
                    alertController.addAction(OKAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                }
                
                guard let currentUser = Auth.auth().currentUser else {
                    return
                }
                
                let userDatabaseRef = Database.database().reference().child("users").child(currentUser.uid)
                guard let imageKey = userDatabaseRef.key else {
                    return
                }
                
                let imageURL = currentUser.photoURL?.absoluteString
                let url = NSURL(string: imageURL!) as! URL
                var data = NSData(contentsOf: url) as! Data
                
                let profileImageStorgeRef = Storage.storage().reference().child("profile_photos").child("\(imageKey).jpg")
                
                while data.count > 2 * 1024 * 1024 {
                    let newData = UIImage(data: data)?.jpegData(compressionQuality: 0.9)
                    data = newData!
                }
                
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpg"
                
                profileImageStorgeRef.putData(data, metadata: metadata) { metadata, error in
                    
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    
                    profileImageStorgeRef.downloadURL { url, error in
                        
                        guard let url = url else {
                            return
                        }
                        
                        let imageFileURL = url.absoluteString
                        
                        let values: [String: Any] = ["name": currentUser.displayName,
                                                     "email": currentUser.email,
                                                     "profileImageURL": imageFileURL]
                        userDatabaseRef.setValue(values)
                    }
                }
                
//                let userDatabaseRef = Database.database().reference().child("users").child(currentUser.uid)
//                let values: [String: Any] = ["name": currentUser.displayName,
//                                             "email": currentUser.email,
//                                             "profileImageURL": currentUser.photoURL?.absoluteString]
//                userDatabaseRef.updateChildValues(values)
                
                // 登入成功後到主畫面
                if let HomeViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeView") {
                    
                    UIApplication.shared.keyWindow?.rootViewController = HomeViewController
                    self.dismiss(animated: true)
                }
            })
        }
    }
    
    // MARK: - Google Login
    
    @IBAction func googleLogin(sender: UIButton) {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            
            if let error = error {
                
                print(error.localizedDescription)
                return
            }
            
            guard let authentication = user?.authentication,
                  let idToken = authentication.idToken else {
                
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            
            // Authenticate with Firebase
            Auth.auth().signIn(with: credential, completion: { authResult, error in
                
                if let error = error {
                    let alertController = UIAlertController(title: "Login error", message: error.localizedDescription, preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    
                    alertController.addAction(OKAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                }
                
                guard let currentUser = Auth.auth().currentUser else {
                    return
                }
                
                let userDatabaseRef = Database.database().reference().child("users").child(currentUser.uid)
                guard let imageKey = userDatabaseRef.key else {
                    return
                }
                
                let imageURL = GIDSignIn.sharedInstance.currentUser?.profile?.imageURL(withDimension: 400)?.absoluteString
                let url = NSURL(string: imageURL!) as! URL
                var data = NSData(contentsOf: url) as! Data
                
                let profileImageStorgeRef = Storage.storage().reference().child("profile_photos").child("\(imageKey).jpg")
                
                while data.count > 2 * 1024 * 1024 {
                    let newData = UIImage(data: data)?.jpegData(compressionQuality: 0.9)
                    data = newData!
                }
                
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpg"
                
                profileImageStorgeRef.putData(data, metadata: metadata) { metadata, error in
                    
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    
                    profileImageStorgeRef.downloadURL { url, error in
                        
                        guard let url = url else {
                            return
                        }
                        
                        let imageFileURL = url.absoluteString
                        
                        let values: [String: Any] = ["name": currentUser.displayName,
                                                     "email": currentUser.email,
                                                     "profileImageURL": imageFileURL]
                        userDatabaseRef.setValue(values)
                    }
                }
                
                // 登入成功後到主畫面
                if let HomeViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeView") {
                    
                    UIApplication.shared.keyWindow?.rootViewController = HomeViewController
                    self.dismiss(animated: true)
                }
            })
        }
    }
    
    // Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = ""
        
        let blurEffect = UIBlurEffect(style: .dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView!.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView!)
    }
    
    override func viewWillLayoutSubviews() {
        
        blurEffectView.frame = view.bounds
    }
}
