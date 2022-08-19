//
//  PasswordResetViewController.swift
//  PhotoSharing
//
//  Created by 陳鈺翔 on 2022/8/18.
//

import UIKit
import Firebase

class PasswordResetViewController: UIViewController {
    
    var blurEffectView: UIVisualEffectView!
    
    // MARK: - IBOutlet
    
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var emailTextField: UITextField!
    
    // MARK: - 重設密碼
    
    @IBAction func resetPassword(sender: UIButton) {
        
        guard let email = emailTextField.text, email != "" else {
            
            let alertController = UIAlertController(title: "Input error", message: "Please make sure you provide your email address for password reset", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(OKAction)
            present(alertController, animated: true, completion: nil)
            
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email, completion: { error in
            
            // 失敗
            if let error = error {
                
                let alertController = UIAlertController(title: "Password reset error", message: error.localizedDescription, preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion: nil)
            }
            // 成功
            else {
               
                let alertController = UIAlertController(title: "Password reset", message: "We have send a password reset email", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .cancel, handler: { action in
                    
                    
                    self.view.endEditing(true)
                    
                    // 回到登入畫面
                    self.navigationController?.popViewController(animated: true)
                })
                
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion: nil)
            }
        })
    }

    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Forgot Password"
        emailTextField.becomeFirstResponder()
        
        let blurEffect = UIBlurEffect(style: .dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView!.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView!)
    }
    
    override func viewWillLayoutSubviews() {
        
        blurEffectView.frame = view.bounds
    }
}
