//
//  UIImageScale.swift
//  PhotoSharing
//
//  Created by 陳鈺翔 on 2022/8/23.
//

import UIKit

extension UIImage {
    
    func scale(newWidth: CGFloat) -> UIImage {

        if self.size.width == newWidth {
            return self
        }

        let scaleFactor = newWidth / self.size.width
        let newHeight = self.size.height * scaleFactor
        let newSize = CGSize(width: newWidth, height: newHeight)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))

        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? self
    }
}
