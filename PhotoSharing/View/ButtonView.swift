//
//  ButtonView.swift
//  PhotoSharing
//
//  Created by 陳鈺翔 on 2022/8/18.
//

import Foundation

import UIKit

@IBDesignable
class ButtonView: UIButton {
    
    @IBInspectable var cornerRadius: Double = 0.0 {
        didSet {
            layer.cornerRadius = CGFloat(cornerRadius)
            layer.masksToBounds = true
        }
    }
    
    @IBInspectable var borderWidth: Double = 0.0 {
        didSet {
            layer.borderWidth = CGFloat(borderWidth)
        }
    }
    
    @IBInspectable var borderColor: UIColor = .black {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var enableGradientBackground: Bool = false
    
    @IBInspectable var gradientColor1: UIColor = UIColor.black
    
    @IBInspectable var gradientColor2: UIColor = UIColor.white
    
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        if enableGradientBackground {
            
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = self.bounds
            gradientLayer.colors = [gradientColor1.cgColor, gradientColor2.cgColor]
            gradientLayer.locations = [0.0, 1.0]
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            self.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
}
