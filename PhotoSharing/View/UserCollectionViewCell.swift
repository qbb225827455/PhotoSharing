//
//  UserCollectionViewCell.swift
//  PhotoSharing
//
//  Created by 陳鈺翔 on 2022/9/26.
//

import UIKit

class UserCollectionViewCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView! {
        didSet {
            imageView.layer.cornerRadius = imageView.frame.width / 2
            imageView.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet var view: UIView! {
        didSet {
            view.layer.cornerRadius = view.frame.width / 2
            view.backgroundColor = .black
            view.alpha = 0.5
            view.isHidden = true
            view.addSubview(plusImage)
        }
    }
    
    @IBOutlet var plusImage: UIImageView! {
        didSet {
            plusImage.alpha = 1
            plusImage.layer.cornerRadius = plusImage.frame.width / 2
            plusImage.isHidden = true
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
