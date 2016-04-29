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
    }
    
    override func shouldRemovePresentersView() -> Bool {
        return false
    }
}
