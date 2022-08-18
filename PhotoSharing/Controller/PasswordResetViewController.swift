//
//  PasswordResetViewController.swift
//  PhotoSharing
//
//  Created by 陳鈺翔 on 2022/8/18.
//

import UIKit

class PasswordResetViewController: UIViewController {
    
    var blurEffectView: UIVisualEffectView!
    
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var emailTextField: UITextField!

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
