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
            imageView.layer.cornerRadius = imageView.bounds.width / 2
            imageView.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet var view: UIView! {
        didSet {
            view.layer.cornerRadius = view.bounds.width / 2
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
    
    func indexpathRowEuqalZero() {
        view.backgroundColor = .black
        view.alpha = 0.5
        view.layer.borderWidth = 0
    }
    
    func indexpathRowNotEuqalZero() {
        let gradient = CAGradientLayer()
        gradient.frame =  CGRect(origin: CGPoint.zero, size: view.frame.size)
        gradient.colors = [UIColor.red.cgColor, UIColor.orange.cgColor]
        let shape = CAShapeLayer()
        shape.lineWidth = 2
        shape.path = UIBezierPath(roundedRect: view.bounds.insetBy(dx: 1, dy: 1), cornerRadius: view.layer.cornerRadius).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        view.layer.addSublayer(gradient)
        
        view.backgroundColor = UIColor.white.withAlphaComponent(0)
    }
}
