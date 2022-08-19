//
//  SettingViewController.swift
//  PhotoSharing
//
//  Created by 陳鈺翔 on 2022/8/19.
//

import UIKit
import Firebase

class SettingViewController: UIViewController {
    
    // MARK: - 登出帳戶
    
    @IBAction func logout(sender: UIButton) {
        
        do {
            try Auth.auth().signOut()
        
        } catch {
            
            let alertController = UIAlertController(title: "Logout error", message: error.localizedDescription, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        // 登出成功後回到 StartView
        if let StartViewController = self.storyboard?.instantiateViewController(withIdentifier: "StartView") {
            
            UIApplication.shared.keyWindow?.rootViewController = StartViewController
            self.dismiss(animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
