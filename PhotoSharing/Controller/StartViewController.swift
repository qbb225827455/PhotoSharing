//
//  StartViewController.swift
//  PhotoSharing
//
//  Created by 陳鈺翔 on 2022/8/18.
//

import UIKit

class StartViewController: UIViewController {
    
    var blurEffectView: UIVisualEffectView!
    
    @IBOutlet var backgroundImageView: UIImageView!
    
    @IBAction func unwindToStartView(segue: UIStoryboardSegue) {
        dismiss(animated: true)
    }

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
