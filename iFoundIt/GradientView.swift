//
//  GradientView.swift
//  iFoundIt
//
//  Created by Мануэль on 29.04.16.
//  Copyright © 2016 Мануэль. All rights reserved.
//

import UIKit

class GradienView: UIView
{
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor  = UIColor.clearColor()
        autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        backgroundColor = UIColor.clearColor()
    }
    
    override func drawRect(rect: CGRect) {
        
        let locations:  [CGFloat] = [0, 1]
        let components: [CGFloat] = [0, 0, 0, 0.2, 0, 0, 0, 0.85]
       
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient   = CGGradientCreateWithColorComponents(colorSpace, components, locations, 2)
        
        let x       = CGRectGetMidX(bounds)
        let y       = CGRectGetMidY(bounds)
        let point   = CGPoint(x: x, y: y)
        let radiust = max(x, y)
        
        let context = UIGraphicsGetCurrentContext()
        
        CGContextDrawRadialGradient(context, gradient, point, 0, point, radiust, .DrawsAfterEndLocation)
    }    
}
