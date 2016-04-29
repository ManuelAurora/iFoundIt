//
//  DetailViewController.swift
//  iFoundIt
//
//  Created by Мануэль on 28.04.16.
//  Copyright © 2016 Мануэль. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    //MARK: # PROPERTIES #
    
    var searchResult: SearchResult!
    var downloadTask: NSURLSessionDownloadTask?
    
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
    
    @IBAction func openInStore() {
        if let url = NSURL(string: searchResult.storeURL) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    //MARK: # PARENT CLASS FUNCTIONS #

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        modalPresentationStyle = .Custom
        transitioningDelegate  = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clearColor()
        
        if searchResult != nil { updateUI() }
        
        popupView.layer.cornerRadius = 10
        
        view.tintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.close))
        
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        
        view.addGestureRecognizer(gestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: # FUNCTIONS #
    
    deinit {
         
        downloadTask?.cancel()
    }
    
    func updateUI() {
        
        let formatter = NSNumberFormatter()
        let priceText: String
        
        formatter.numberStyle  = .CurrencyStyle
        formatter.currencyCode = searchResult.currency
        
        nameLabel.text  = searchResult.name
        kindLabel.text  = searchResult.kindForDisplay()
        genreLabel.text = searchResult.genre
        
        if let url = NSURL(string: searchResult.artworkURL100) {
            downloadTask = artworkImageView.loadImageWithURL(url)
        }
        
        if searchResult.artistName.isEmpty {
            artistNameLabel.text = "Unknown"
        } else {
            artistNameLabel.text = searchResult.artistName
        }
        
        if searchResult.price == 0 {
            priceText = "Free"
        } else if let text = formatter.stringFromNumber(searchResult.price) {
            priceText = text
        } else {
            priceText = ""
        }
        
        priceButton.setTitle(priceText, forState: .Normal)
    }
}

//MARK: $ <<<<< EXTENSIONS >>>>>$

extension DetailViewController: UIViewControllerTransitioningDelegate {
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
}

extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return (touch.view === self.view)
    }
}
