//
//  LandscapeViewController.swift
//  iFoundIt
//
//  Created by Мануэль on 04.05.16.
//  Copyright © 2016 Мануэль. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController
{
    
    //MARK: # PROPERTIES #
    
    private var firstTime = true
    
    private var downloadTasks = [NSURLSessionTask]()
    
    var searchResults = [SearchResult]()
    
    
    //MARK: # OUTLETS #
    
    @IBOutlet weak var scrollView:  UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    //MARK: # ACTIONS #
    
    @IBAction func pageChanged(sender: UIPageControl) {
        UIView.animateWithDuration(0.3) {
            self.scrollView.contentOffset = CGPoint(x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage),
                                                    y: 0)
        }
    }
    
    //MARK: # PARENT CLASS FUNCS #
    
    deinit {
        print("deinit \(self)")
        for task in downloadTasks { task.cancel() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.numberOfPages = 0
        
        view.removeConstraints(view.constraints)
        scrollView.removeConstraints(scrollView.constraints)
        pageControl.removeConstraints(pageControl.constraints)
        
        view.translatesAutoresizingMaskIntoConstraints        = true
        scrollView.translatesAutoresizingMaskIntoConstraints  = true
        pageControl.translatesAutoresizingMaskIntoConstraints = true
        
        scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        pageControl.frame = CGRect(x: 0,
                                   y: view.frame.size.height - pageControl.frame.size.height,
                                   width: view.frame.size.width,
                                   height: pageControl.frame.size.height)
        
        if firstTime { firstTime = false; tileButtons(searchResults) }
    }
    
    //MARK: # FUNCTIONS #
    
    private func tileButtons(searchResults: [SearchResult]){
        var rowsPerPage    = 3
        var columnsPerPage = 5
        
        var marginX: CGFloat    = 0
        var marginY: CGFloat    = 20
        var itemWidth: CGFloat  = 96
        var itemHeight: CGFloat = 88
        
        let scrollViewWidth = scrollView.bounds.size.width
        
        let buttonWidth: CGFloat  = 82
        let buttonHeight: CGFloat = 82
        
        let paddingHorz = (itemWidth - buttonWidth) / 2
        let paddingVert = (itemHeight - buttonHeight) / 2
        
        switch scrollViewWidth
        {
        case 568:
            columnsPerPage = 6; marginX = 2; rowsPerPage = 94
        case 667:
            columnsPerPage = 7; marginX = 1; marginY = 29; itemWidth = 95; itemHeight = 98
        case 736:
            rowsPerPage = 4; columnsPerPage = 8; itemWidth = 82
        default:
            break
        }
        
        var row    = 0
        var column = 0
        var x      = marginX
        
        for searchResult in searchResults {
            
            let button = UIButton(type: .Custom)
            button.layer.cornerRadius = 10
            button.setBackgroundImage(UIImage(named: "LandscapeButton"), forState: .Normal)
            
            button.frame           = CGRect(x: x + paddingHorz,
                                            y: marginY + CGFloat(row) * itemHeight + paddingVert,
                                            width: buttonWidth,
                                            height: buttonHeight)
            
            button.backgroundColor = UIColor.whiteColor()
            
            scrollView.addSubview(button)
            
            downloadImageForSearchResult(searchResult, andPlaceOnButton: button)
            
            row += 1;
            
            if row == rowsPerPage {
                row = 0; x += itemWidth; column += 1
                
                if column == columnsPerPage {
                    column = 0; x += marginX * 2
                }
            }
        }
        
        let buttonsPerPage = columnsPerPage * rowsPerPage
        
        let numPages = 1 + (searchResults.count - 1) / buttonsPerPage
        
        scrollView.contentSize = CGSize(width: CGFloat(numPages) * scrollViewWidth,
                                        height: scrollView.bounds.size.height)
        
        pageControl.numberOfPages = numPages
        pageControl.currentPage   = 0
    }
    
    private func downloadImageForSearchResult(searchResult: SearchResult, andPlaceOnButton button: UIButton) {
        guard let url = NSURL(string: searchResult.artworkURL60) else { return }
        let session = NSURLSession.sharedSession()
        let downloadTask = session.downloadTaskWithURL(url) {
            [weak button] url, response, error in
            
            if error == nil, let url = url, data = NSData(contentsOfURL: url), image = UIImage(data: data) {
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    guard let button = button else { return }
                    
                    button.setImage(image, forState: .Normal)
                }
            }
        }
        downloadTask.resume()
        downloadTasks.append(downloadTask)
    }
}

//MARK: $ <<<<< EXTENSIONS >>>>> $

extension LandscapeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let width       = scrollView.bounds.size.width
        let currentPage = Int((scrollView.contentOffset.x + width / 2) / width)
        
        pageControl.currentPage = currentPage
    }
}
