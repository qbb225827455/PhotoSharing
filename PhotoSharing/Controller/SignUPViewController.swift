//
//  SignUPViewController.swift
//  PhotoSharing
//
//  Created by 陳鈺翔 on 2022/8/18.
//

import UIKit

class SignUPViewController: UIViewController {

    var blurEffectView: UIVisualEffectView!
    
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
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
