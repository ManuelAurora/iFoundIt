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
    
    //MARK: # VARIABLES #
    
    var searchResults = [SearchResult]()
    var hasSearched   = false

    //MARK: # OUTLETS #
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: # CLASS FUNCTIONS #
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

//MARK: # EXTENSIONS #

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        hasSearched = true
        
        searchBar.resignFirstResponder()
        
        searchResults = [SearchResult]()
        
        guard searchBar.text! != "justin bieber" else { tableView.reloadData(); return }
        
        for i in 0...2 {
            let searchResult = SearchResult()
            
            searchResult.name       = String(format: "Fake Result %d for", i)
            searchResult.artistName = searchBar.text!
            searchResults.append(searchResult)
        }
        tableView.reloadData()
    }
}

extension SearchViewController: UITableViewDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        guard searchResults.count == 0 else { return indexPath }
        
        return nil
    }
}

extension SearchViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard searchResults.count == 0 else { return searchResults.count }
        
        return hasSearched ? 1 : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "SearchResultCell"
        
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
        }
        
        if searchResults.count == 0 {
            cell.textLabel!.text       = "(Nothing found)"
            cell.detailTextLabel!.text = ""
            
        } else {
            
            let searchResult = searchResults[indexPath.row]
            
            cell.textLabel!.text = searchResult.name
            cell.detailTextLabel!.text = searchResult.artistName
        }
        
        return cell
        
    }
}