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
    
    var search: Search!
    
    
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
        
        if firstTime {
            firstTime = false
            
            switch search.state
            {
            case .NoResults:
                showNothingFoundLabel()
            case .Loading:
                showSpinner()
            case .Results(let list):
                tileButtons(list)
            case .NotSearchedYet:
                break
            }
        }
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
        
        switch scrollViewWidth
        {
        case 568:
            columnsPerPage = 6; marginX = 2
        case 667:
            columnsPerPage = 7; marginX = 1; marginY = 29; itemWidth = 95; itemHeight = 98
        case 736:
            rowsPerPage = 4; columnsPerPage = 8; itemWidth = 92
        default:
            break
        }
        
        var row    = 0
        var column = 0
        var x      = marginX
        
        let buttonWidth: CGFloat  = 82
        let buttonHeight: CGFloat = 82
        
        let paddingHorz = (itemWidth - buttonWidth) / 2
        let paddingVert = (itemHeight - buttonHeight) / 2
        
        for (index, searchResult) in searchResults.enumerate() {
            
            let button = UIButton(type: .Custom)
            let image  = UIImage(named: "LandscapeButton")
            
            button.setBackgroundImage(image, forState: .Normal)
            
            button.frame           = CGRect(x: x + paddingHorz,
                                            y: marginY + CGFloat(row) * itemHeight + paddingVert,
                                            width: buttonWidth,
                                            height: buttonHeight)
            
            scrollView.addSubview(button)
            
            downloadImageForSearchResult(searchResult, andPlaceOnButton: button)
            
            button.tag = 2000 + index
            
            button.addTarget(self, action: #selector(buttonPressed), forControlEvents: .TouchUpInside)
            
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
                    
                    
                    button.setImage(image.resizedWithBounds(button.bounds.size), forState: .Normal)
                }
            }
        }
        downloadTask.resume()
        downloadTasks.append(downloadTask)
    }
    
    private func showSpinner() {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        
        spinner.center = CGPoint(x: CGRectGetMidX(scrollView.bounds) + 0.5,
                                 y: CGRectGetMidY(scrollView.bounds) + 0.5) // + 0.5 cause screen size is odd
        
        spinner.tag = 1000
        
        view.addSubview(spinner)
        
        spinner.startAnimating()
    }
    
    private func hideSpinner() {
        view.viewWithTag(1000)?.removeFromSuperview()
    }
    
    func searchResultsReceived() {
        hideSpinner()
        
        switch search.state
        {
        case .NotSearchedYet, .Loading:
            break
        case .NoResults:
            showNothingFoundLabel()
        case .Results(let list):
            tileButtons(list)
        }
    }
    
    private func showNothingFoundLabel() {
        let label = UILabel(frame: CGRect.zero)
        
        label.text            = "Nothing Found"
        label.textColor       = UIColor.whiteColor()
        label.backgroundColor = UIColor.clearColor()
        
        label.sizeToFit()
        
        var rect = label.frame
        
        rect.size.width  = ceil(rect.size.width / 2) * 2 // make even
        rect.size.height = ceil(rect.size.height / 2) * 2 //make even
        
        label.frame = rect
        label.center = CGPoint(x: CGRectGetMidX(scrollView.bounds), y: CGRectGetMidY(scrollView.bounds))
        
        view.addSubview(label)
    }
    
    func buttonPressed(sender: UIButton) {
        performSegueWithIdentifier("ShowDetail", sender: sender)
    }
    
    //MARK:___ SEGUES ___
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard segue.identifier == "ShowDetail" else { return }
        
        if case .Results(let list) = search.state {
            let detailViewController = segue.destinationViewController as! DetailViewController
            
            let searchResult = list[sender!.tag - 2000]
            
            detailViewController.isPopUp      = true
            detailViewController.searchResult = searchResult
        }
    }
    
}

//MARK: $ <<<<< EXTENSIONS >>>>> $

extension LandscapeViewController: UIScrollViewDelegate {
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        let width       = scrollView.bounds.size.width
//        let currentPage = Int((scrollView.contentOffset.x + width / 2) / width)
//        
//        pageControl.currentPage = currentPage
    }

