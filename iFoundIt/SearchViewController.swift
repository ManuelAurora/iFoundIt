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
    
    var searchResults = [SearchResult]()
    var hasSearched   = false
    var isLoading     = false
    
    var dataTask:                NSURLSessionDataTask?
    var landscapeViewController: LandscapeViewController?
    
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
        
        listenForUIContentSizeCategoryDidChangeNotification()
        
        searchBar.becomeFirstResponder()
        
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
        
        switch newCollection.verticalSizeClass
        {
        case .Compact:
            showLandscapeViewWithCoordinator(coordinator)
        case .Regular, .Unspecified:
            hideLandscapeViewWithCoordinator(coordinator)
        }
    }
    
    //MARK: # SEGUES #
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            let detailViewController = segue.destinationViewController as! DetailViewController
            
            let indexPath = sender as! NSIndexPath
            
            let item = searchResults[indexPath.row]
            
            detailViewController.searchResult = item
        }
    }
    
    //MARK: # FUNCTIONS #
    
    func showLandscapeViewWithCoordinator(coordinator: UIViewControllerTransitionCoordinator) {
        precondition(landscapeViewController == nil)
        
        landscapeViewController = storyboard!.instantiateViewControllerWithIdentifier("LandscapeViewController") as? LandscapeViewController
        
        guard let controller = landscapeViewController else { return }
        
        controller.view.frame = view.bounds
        controller.view.alpha = 0
        
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
        
        dataTask?.cancel()
        
        hasSearched = true
        isLoading   = true
        
        tableView.reloadData()
        
        searchBar.resignFirstResponder()
        
        searchResults = [SearchResult]()
        
        let url = urlWithSearchText(searchBar.text!, category: segmentedControl.selectedSegmentIndex)
        
        let session = NSURLSession.sharedSession()
        
         dataTask = session.dataTaskWithURL(url) {
            data, response, error in
            
            if let error = error where error.code == -999 { return }
            else if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200 {
                guard let data = data, dictionary = self.parseJSON(data) else { return }
                
                self.searchResults = self.parseDictionary(dictionary)
                self.searchResults.sortInPlace(<)
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.isLoading = false
                    self.tableView.reloadData()
                }
                return
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.hasSearched = false
                self.isLoading   = false
                self.tableView.reloadData()
                self.showNetworkError()
            }
        }
        dataTask?.resume()
    }
}

//MARK: # TABLEVIEW DELEGATE #

extension SearchViewController: UITableViewDelegate
{
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        performSegueWithIdentifier("ShowDetail", sender: indexPath)
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        guard searchResults.count == 0 || isLoading else { return indexPath }
        
        return nil
    }
}

//MARK: # TABLEVIEW DATA SOURCE #

extension SearchViewController: UITableViewDataSource
{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isLoading { return 1 }
        
        guard searchResults.count == 0 else { return searchResults.count }
        
        return hasSearched ? 1 : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if isLoading {
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            
            return cell
        }
        else if searchResults.count == 0 {
            
            return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath)
            
        } else {
            let cell         = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
            let searchResult = searchResults[indexPath.row]
            
            cell.configureForSearchResult(searchResult)
            
            return cell
        }
    }
}

//MARK: # URL REQUEST HANDLING #

extension SearchViewController
{
    func urlWithSearchText(searchText: String, category: Int) -> NSURL {
        
        let entityName: String
        
        switch category
            {
        case 1:
            entityName = "musicTrack"
        case 2:
            entityName = "software"
        case 3:
            entityName = "ebook"
        default:
            entityName = ""
        }
        
        let encodedText = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let urlString   = String(format: "https://itunes.apple.com/search?term=%@&limit200&entity=%@", encodedText, entityName)
        let url         = NSURL(string: urlString)
        
        return url!
    }
    
    func parseJSON(data: NSData) -> [String: AnyObject]? {
        
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject]
        }
        catch {
            print("JSON Error: \(error)")
            return nil
        }
    }
    
    func parseDictionary(dictionary: [String: AnyObject]) -> [SearchResult] {
        guard let array = dictionary["results"] as? [AnyObject] else { print("Expected 'results' array"); return [] }
        
        var searchResults = [SearchResult]()
        
        for resultDict in array {
            var searchResult: SearchResult?
            
            if let wrapperType = resultDict["wrapperType"] as? String {
                switch wrapperType
                {
                case "track":
                    searchResult = parseTrack(resultDict     as! [String: AnyObject])
                case "audiobook":
                    searchResult = parseAudioBook(resultDict as! [String: AnyObject])
                case "software":
                    searchResult = parseSoftware(resultDict  as! [String: AnyObject])
                default:
                    break
                }
            } else if let kind = resultDict["kind"] as? String where kind == "ebook" {
                searchResult = parseEBook(resultDict as! [String: AnyObject])
            }
            
            if let result = searchResult { searchResults.append(result) }
        }
        return searchResults
    }
    
    func parseTrack(dictionary: [String: AnyObject]) -> SearchResult {
        let searchResult = SearchResult()
        
        searchResult.kind          = dictionary["kind"]          as! String
        searchResult.name          = dictionary["trackName"]     as! String
        searchResult.currency      = dictionary["currency"]      as! String
        searchResult.storeURL      = dictionary["trackViewUrl"]  as! String
        searchResult.artistName    = dictionary["artistName"]    as! String
        searchResult.artworkURL60  = dictionary["artworkUrl60"]  as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        
        if let price = dictionary["trackPrice"] as? Double {
            searchResult.price = price
        }
        
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        
        return searchResult
    }
    
    func parseSoftware(dictionary: [String: AnyObject]) -> SearchResult {
        
        let searchResult = SearchResult()
        
        searchResult.kind          = dictionary["kind"]          as! String
        searchResult.name          = dictionary["trackName"]     as! String
        searchResult.currency      = dictionary["currency"]      as! String
        searchResult.storeURL      = dictionary["trackViewUrl"]  as! String
        searchResult.artistName    = dictionary["artistName"]    as! String
        searchResult.artworkURL60  = dictionary["artworkUrl60"]  as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        
        if let price = dictionary["trackPrice"] as? Double {
            searchResult.price = price
        }
        
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        
        return searchResult
    }
    
    func parseEBook(dictionary: [String: AnyObject]) -> SearchResult {
        
        let searchResult = SearchResult()
        
        searchResult.kind          = dictionary["kind"]          as! String
        searchResult.name          = dictionary["trackName"]     as! String
        searchResult.currency      = dictionary["currency"]      as! String
        searchResult.storeURL      = dictionary["trackViewUrl"]  as! String
        searchResult.artistName    = dictionary["artistName"]    as! String
        searchResult.artworkURL60  = dictionary["artworkUrl60"]  as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        
        if let price = dictionary["trackPrice"] as? Double {
            searchResult.price = price
        }
        
        if let genres: AnyObject = dictionary["genres"] {
            searchResult.genre = (genres as! [String]).joinWithSeparator(", ")
        }
        
        return searchResult
    }
    
    
    func parseAudioBook(dictionary: [String: AnyObject]) -> SearchResult {
        
        let searchResult = SearchResult()
        
        searchResult.kind          = "audiobook"
        searchResult.name          = dictionary["collectionName"]     as! String
        searchResult.currency      = dictionary["currency"]           as! String
        searchResult.storeURL      = dictionary["collectionViewUrl"]  as! String
        searchResult.artistName    = dictionary["artistName"]         as! String
        searchResult.artworkURL60  = dictionary["artworkUrl60"]       as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"]      as! String
        
        if let price = dictionary["collectionPrice"] as? Double {
            searchResult.price = price
        }
        
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        
        return searchResult
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






