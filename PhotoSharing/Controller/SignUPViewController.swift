//
//  SignUPViewController.swift
//  PhotoSharing
//
//  Created by 陳鈺翔 on 2022/8/18.
//

import UIKit
import Firebase

class SignUPViewController: UIViewController {

    var blurEffectView: UIVisualEffectView!
    
    // MARK: - IBOutlet
    
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
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
            
            self.view.endEditing(true)
            
            Auth.auth().currentUser?.sendEmailVerification(completion: { error in
                
                if let error = error {
                    print(error.localizedDescription)
                }
            })
            
            let alertController = UIAlertController(title: "Email verification", message: "We have just send a confirm email to your email address", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .cancel, handler: { action in
                
            
                // 註冊成功後回到 StartView
                if let StartViewController = self.storyboard?.instantiateViewController(withIdentifier: "StartView") {
                    
                    UIApplication.shared.keyWindow?.rootViewController = StartViewController
                    self.dismiss(animated: true)
                }
            })
            
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
        })
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
