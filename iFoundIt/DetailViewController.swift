//
//  DetailViewController.swift
//  iFoundIt
//
//  Created by Мануэль on 28.04.16.
//  Copyright © 2016 Мануэль. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    //MARK: # OUTLETS #
    
    @IBOutlet weak var popupView:        UIView!
    @IBOutlet weak var kindLabel:        UILabel!
    @IBOutlet weak var nameLabel:        UILabel!
    @IBOutlet weak var genreLabel:       UILabel!
    @IBOutlet weak var artistNameLabel:  UILabel!
    @IBOutlet weak var priceButton:      UIButton!
    @IBOutlet weak var artworkImageView: UIImageView!    
  
     //MARK: # ACTIONS #
    
    @IBAction func close() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: # PARENT CLASS FUNCTIONS #

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        modalPresentationStyle = .Custom
        transitioningDelegate  = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK: $ <<<<< EXTENSIONS >>>>>$

extension DetailViewController: UIViewControllerTransitioningDelegate {
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
}

