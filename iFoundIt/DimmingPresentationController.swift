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
    override func shouldRemovePresentersView() -> Bool {
        return false
    }
}
