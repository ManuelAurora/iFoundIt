//
//  DimmingPresentationController.swift
//  iFoundIt
//
//  Created by Мануэль on 28.04.16.
//  Copyright © 2016 Мануэль. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController
{
    lazy var dimmingView = GradienView(frame: CGRect.zero)
    
    override func presentationTransitionWillBegin() {
        
        dimmingView.frame = containerView!.bounds
        containerView!.insertSubview(dimmingView, atIndex: 0)
        
        dimmingView.alpha = 0
        
        guard let transitionCoordinator = presentedViewController.transitionCoordinator() else { return }
        
        transitionCoordinator.animateAlongsideTransition({ _ in
            self.dimmingView.alpha = 1
            }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        guard let transitionCoordinator = presentedViewController.transitionCoordinator() else { return }
        
        transitionCoordinator.animateAlongsideTransition({ _ in
            self.dimmingView.alpha = 0
            }, completion: nil)
    }    
    
    override func shouldRemovePresentersView() -> Bool {
        return false
    }
}
