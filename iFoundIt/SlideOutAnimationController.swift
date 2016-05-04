//
//  SlideOutAnimationController.swift
//  iFoundIt
//
//  Created by Мануэль on 04.05.16.
//  Copyright © 2016 Мануэль. All rights reserved.
//

import UIKit

class SlideOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning
{
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval { return 0.3 }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView      = transitionContext.viewForKey(UITransitionContextFromViewKey),
              let containerView = transitionContext.containerView()
        else { return }
        
        let duration = transitionDuration(transitionContext)
        
        UIView.animateWithDuration(duration, animations: { 
            
            fromView.center.y -= containerView.bounds.height
            fromView.transform = CGAffineTransformMakeScale(0.5, 0.5)
            
            }) { finished in
                transitionContext.completeTransition(finished)
        }
    }
    
}

