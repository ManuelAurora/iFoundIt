//
//  MenuTableViewController.swift
//  iFoundIt
//
//  Created by Мануэль on 13.05.16.
//  Copyright © 2016 Мануэль. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController
{
 
    weak var delegate: MenuTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
   
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.row == 0 {
            delegate?.MenuTableViewControllerSendSupportEmail(self)
        }
    }

}

protocol MenuTableViewControllerDelegate: class
{
    
    func MenuTableViewControllerSendSupportEmail(controller: MenuTableViewController)
    
}