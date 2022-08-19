//
//  LoginViewController.swift
//  PhotoSharing
//
//  Created by 陳鈺翔 on 2022/8/18.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    var blurEffectView: UIVisualEffectView!
    
    // MARK: - IBOutlet
    
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    // MARK: - 登入帳戶
    
    @IBAction func login(sender: UIButton) {
        
        // 沒有輸入完整
        guard let email = emailTextField.text, email != "",
              let password = passwordTextField.text, password != "" else {
            
            let alertController = UIAlertController(title: "Login error", message: "Please make sure both fields are bot blank", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(OKAction)
            present(alertController, animated: true, completion: nil)
            
            return
        }
        
        // 登入
        Auth.auth().signIn(withEmail: email, password: password, completion: { authResult, error in
            
            if let error = error {
                let alertController = UIAlertController(title: "Login error", message: error.localizedDescription, preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            
            // 確認 Email 認證是否完成
            guard let authResult = authResult, authResult.user.isEmailVerified else {
            
                let alertController = UIAlertController(title: "Login error", message: "You haven't confirm your email yet", preferredStyle: .alert)
                let resendAction = UIAlertAction(title: "Resend", style: .default, handler: { action in
                    
                    Auth.auth().currentUser?.sendEmailVerification(completion: nil)
                })
                let OKAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                alertController.addAction(resendAction)
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            
            self.view.endEditing(true)
            
            // 登入成功後到主畫面
            if let HomeViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeView") {
                
                UIApplication.shared.keyWindow?.rootViewController = HomeViewController
                self.dismiss(animated: true)
            }
        })
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.becomeFirstResponder()
        
        let blurEffect = UIBlurEffect(style: .dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView!.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.title = "Log In"
    }
    
    override func viewWillLayoutSubviews() {
        
        blurEffectView.frame = view.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = ""
    }
}
