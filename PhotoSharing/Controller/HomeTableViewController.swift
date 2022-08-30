//
//  PostTableViewController.swift
//  PhotoSharing
//
//  Created by 陳鈺翔 on 2022/8/23.
//

import UIKit
import YPImagePicker
import Firebase
import FirebaseStorage

class HomeTableViewController: UITableViewController {
    
    // 打開相機介面
    // https://github.com/Yummypets/YPImagePicker
    
    @IBAction func openCamera(sender: UIBarButtonItem) {
        
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
            
            guard let uid = Auth.auth().currentUser?.uid else {
                return
            }
            
            PostService.shared.uploadPostImage(image: photo.image) {
                
                picker.dismiss(animated: true, completion: nil)
            }
        }
        present(picker, animated: true, completion: nil)
    }

    // MARK: - Life cycle
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
}
