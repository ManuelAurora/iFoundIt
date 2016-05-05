//
//  FadeOutAnimationController.swift
//  iFoundIt
//
//  Created by Мануэль on 05.05.16.
//  Copyright © 2016 Мануэль. All rights reserved.
//

import UIKit


class FadeOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning
{
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.33
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey) else { return }
        
        let duration = transitionDuration(transitionContext)
        
        UIView.animateWithDuration(duration, animations: { 
            fromView.alpha = 0
            }) { finished in
                transitionContext.completeTransition(finished)
        }
    }
}
