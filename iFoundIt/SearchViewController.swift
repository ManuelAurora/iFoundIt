//
//  ViewController.swift
//  iFoundIt
//
//  Created by Мануэль on 08.04.16.
//  Copyright © 2016 Мануэль. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController
{
    
    //MARK: # PROPERTIES #
    
    var searchResults = [SearchResult]()
    var hasSearched   = false
    var isLoading     = false
    
    var dataTask: NSURLSessionDataTask?
    
    struct TableViewCellIdentifiers
    {
        static let loadingCell      = "LoadingCell"
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
    }
    
    //MARK: # OUTLETS #
    
    @IBOutlet weak var tableView:  UITableView!
    @IBOutlet weak var searchBar:  UISearchBar!
    
    //MARK: # CLASS FUNCTIONS #
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.becomeFirstResponder()
        
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        
        tableView.rowHeight = 80
        tableView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

//MARK: $ EXTENSIONS $

//MARK: # SEARCH BAR DELEGATE #
extension SearchViewController: UISearchBarDelegate
{
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        guard !searchBar.text!.isEmpty else { return }
        
        dataTask?.cancel()
        
        hasSearched = true
        isLoading   = true
        
        tableView.reloadData()
        
        searchBar.resignFirstResponder()
        
        searchResults = [SearchResult]()
        
        let url = urlWithSearchText(searchBar.text!)
        
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
            
            cell.nameLabel.text       = searchResult.name
            
            if searchResult.artistName.isEmpty {
                cell.artistNameLabel.text = "Unknown"
            } else {
                cell.artistNameLabel.text = String(format: "%@ (%@)", searchResult.artistName, kindForDisplay(searchResult.kind))
            }
            
            return cell
        }
    }
}

//MARK: # URL REQUEST HANDLING #

extension SearchViewController
{
    func urlWithSearchText(searchText: String) -> NSURL {
        
        let encodedText = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let urlString   = String(format: "https://itunes.apple.com/search?term=%@&limit200", encodedText)
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
    
    func kindForDisplay(kind: String) -> String {
        switch kind
        {
        case "book":          return "Book"
        case "song":          return "Song"
        case "album":         return "Album"
        case "ebook":         return "E-Book"
        case "podcast":       return "Podcast"
        case "software":      return "App"
        case "audiobook":     return "Audio Book"
        case "tv-episode":    return "TV Episode"
        case "music-video":   return "Music Video"
        case "feature-movie": return "Movie"
        default:              return kind
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

func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.name.localizedStandardCompare(rhs.name) == .OrderedAscending
}




