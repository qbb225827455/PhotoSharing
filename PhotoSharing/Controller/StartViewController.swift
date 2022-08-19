//
//  StartViewController.swift
//  PhotoSharing
//
//  Created by 陳鈺翔 on 2022/8/18.
//

import UIKit
import FacebookLogin
import Firebase

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
