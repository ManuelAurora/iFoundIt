//
//  ViewController.swift
//  iFoundIt
//
//  Created by Мануэль on 08.04.16.
//  Copyright © 2016 Мануэль. All rights reserved.
//

import UIKit
import Foundation

class SearchViewController: UIViewController
{
    
    //MARK: # PROPERTIES #
    
    let search = Search()
    
    var landscapeViewController: LandscapeViewController?
    
    weak var splitViewDetail: DetailViewController?
    
    struct TableViewCellIdentifiers
    {
        static let loadingCell      = "LoadingCell"
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
    }
    
    //MARK: # OUTLETS #
    
    @IBOutlet weak var tableView:        UITableView!
    @IBOutlet weak var searchBar:        UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    //MARK: # ACTIONS #
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        performSearch()
    }
    
    //MARK: # PARENT CLASS FUNCTIONS #
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Search", comment: "Split-view master button")
        
        listenForUIContentSizeCategoryDidChangeNotification()
        
        if UIDevice.currentDevice().userInterfaceIdiom != .Pad {
            searchBar.becomeFirstResponder()
        }
        
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        
        tableView.rowHeight = 80
        tableView.contentInset = UIEdgeInsets(top: 88, left: 0, bottom: 0, right: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
        
        let rect = UIScreen.mainScreen().bounds
        
        if (rect.width == 736 && rect.height == 414) ||
           (rect.width == 414 && rect.height == 736) {
            
            if presentedViewController != nil { dismissViewControllerAnimated(true, completion: nil) }
            
        } else {
            
            switch newCollection.verticalSizeClass
            {
            case .Compact:
                showLandscapeViewWithCoordinator(coordinator)
            case .Regular, .Unspecified:
                hideLandscapeViewWithCoordinator(coordinator)
            }
        }
    }
    
    //MARK: # METHODS #
    
    func hideMasterPane() {
        UIView.animateWithDuration(0.25, animations: { 
            self.splitViewController!.preferredDisplayMode = .PrimaryHidden
            }) { _ in
                self.splitViewController!.preferredDisplayMode = .Automatic
        }
    }
    
    //MARK: # SEGUES #
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowDetail" {
            
            if case .Results(let list) = search.state {
                
                let detailViewController = segue.destinationViewController as! DetailViewController
                
                let indexPath = sender as! NSIndexPath
                
                let item = list[indexPath.row]
                
                detailViewController.isPopUp      = true
                detailViewController.searchResult = item
            }
        }
    }
    
    func showLandscapeViewWithCoordinator(coordinator: UIViewControllerTransitionCoordinator) {
        
        landscapeViewController = storyboard!.instantiateViewControllerWithIdentifier("LandscapeViewController") as? LandscapeViewController
        
        guard let controller = landscapeViewController else { return }
        
        controller.search = search //Before asking for view. Cause asking will cause viewDidLoad to implement.
        controller.view.alpha    = 0
        controller.view.frame    = view.bounds
        
        
        view.addSubview(controller.view)
        
        addChildViewController(controller)
        
        coordinator.animateAlongsideTransition({ _ in
            controller.view.alpha = 1
            self.searchBar.resignFirstResponder()
            
            if self.presentedViewController != nil { self.dismissViewControllerAnimated(true, completion: nil) }
            
        }) { _ in
            
            controller.didMoveToParentViewController(self)
        }
    }
    
    func hideLandscapeViewWithCoordinator(coordinator: UIViewControllerTransitionCoordinator) {
        guard let controller = landscapeViewController else { return }
        
        controller.willMoveToParentViewController(nil)
        
        coordinator.animateAlongsideTransition({ _ in
            controller.view.alpha = 0
            
            if self.presentedViewController != nil { self.dismissViewControllerAnimated(true, completion: nil) }
            
            self.searchBar.becomeFirstResponder()
            }) { _ in
                controller.view.removeFromSuperview()
                controller.removeFromParentViewController()
                self.landscapeViewController = nil
        }
    }
}

//MARK: $ <<<<< EXTENSIONS >>>>> $

//MARK: # SEARCH BAR DELEGATE #
extension SearchViewController: UISearchBarDelegate
{
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        performSearch()
    }
    
    func performSearch() {
        
        guard !searchBar.text!.isEmpty else { return }
        guard let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex) else { return }
        
        search.performSearchForText(searchBar.text!, category: category) { success in
            
            if !success { self.showNetworkError() }
            
            self.tableView.reloadData()
            
            self.landscapeViewController?.searchResultsReceived()
        }
        
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
}

//MARK: # TABLEVIEW DELEGATE #

extension SearchViewController: UITableViewDelegate
{
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        searchBar.resignFirstResponder()
        
        if view.window!.rootViewController!.traitCollection.horizontalSizeClass == .Compact {
            
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
            performSegueWithIdentifier("ShowDetail", sender: indexPath)
        } else {
            
            if case .Results(let list) = search.state {
                splitViewDetail?.searchResult = list[indexPath.row]
            }
            
            if splitViewController!.displayMode != .AllVisible { hideMasterPane() } //All Visible in landscape
        }
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        switch search.state
        {
        case .NotSearchedYet, .Loading, .NoResults:
            return nil
        case .Results:
            return indexPath
        }
    }
}

//MARK: # TABLEVIEW DATA SOURCE #

extension SearchViewController: UITableViewDataSource
{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch search.state
        {
        case .NotSearchedYet:
            return 0
        case .Loading, .NoResults:
            return 1
        case .Results(let list):
            return list.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch search.state
        {
        case .NotSearchedYet:
            fatalError("Should never get here")
            
        case .Loading:
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            
            return cell
            
        case .NoResults:
            
            return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath)
            
        case .Results(let list):
            
            let cell         = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
            let searchResult = list[indexPath.row]
            
            cell.configureForSearchResult(searchResult)
            
            return cell
        }
    }
}

//MARK: # ALERTS & ERRORS HANDLING #

extension SearchViewController
{
    func showNetworkError() {
        let alert = UIAlertController(title: "Whoops..." , message: "There was an error reading from the iTunes Store. Please try again", preferredStyle: .Alert)
        
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        
        presentViewController(alert, animated: true, completion: nil)
    }
}

extension SearchViewController {
    func listenForUIContentSizeCategoryDidChangeNotification() {
        NSNotificationCenter.defaultCenter().addObserverForName(UIContentSizeCategoryDidChangeNotification, object: nil, queue: NSOperationQueue.mainQueue()) { notification in
            
            self.tableView.reloadData()
        }
    }
}

//MARK: # AUXILLARY FUNCTIONS #

func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.name.localizedStandardCompare(rhs.name) == .OrderedAscending
}






