//
//  UIImage + Resize.swift
//  iFoundIt
//
//  Created by Мануэль on 05.05.16.
//  Copyright © 2016 Мануэль. All rights reserved.
//

import UIKit

extension UIImage
{
    func resizedWithBounds(bounds: CGSize) -> UIImage {
        
        let verticalRatio   = bounds.height / size.height
        let horizontalRatio = bounds.width  / size.width
        
        let ratio           = max(horizontalRatio, verticalRatio)
        
        let newSize         = CGSize(width:  size.width  * ratio / 1.4,
                                     height: size.height * ratio / 1.4)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        
        drawInRect(CGRect(origin: CGPoint.zero, size: newSize))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
