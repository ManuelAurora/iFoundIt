//
//  Search.swift
//  iFoundIt
//
//  Created by Мануэль on 06.05.16.
//  Copyright © 2016 Мануэль. All rights reserved.
//

import Foundation

typealias SearchComplete = (Bool) -> Void

class Search
{
    enum State
    {
        case NotSearchedYet
        case Loading
        case NoResults
        case Results([SearchResult])
    }
    
    enum Category: Int
    {
        case All      = 0
        case Music    = 1
        case Software = 2
        case Ebooks   = 3
        
        var entityName: String {
        
            switch self
            {
            case .Music:
                return "musicTrack"
            case .Software:
                return "software"
            case .Ebooks:
                return "ebook"
            case .All:
                return ""
            }
        }
    }
    
    private var dataTask: NSURLSessionTask? = nil
    
    private(set) var state: State = .NotSearchedYet
    
    func performSearchForText(text: String, category: Category, completion: SearchComplete) {
        
        guard !text.isEmpty else { return }
        
        dataTask?.cancel()
        
        state = .Loading
        
        let url = urlWithSearchText(text, category: category)
        
        let session = NSURLSession.sharedSession()
        
        dataTask = session.dataTaskWithURL(url) {
            data, response, error in
            
            self.state = .NotSearchedYet
            
            var success = false
            
            if let error = error where error.code == -999 { return }
                
            else if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200 {
                guard let data = data, dictionary = self.parseJSON(data) else { return }
                
                var searchResults = self.parseDictionary(dictionary)
                
                if searchResults.isEmpty {
                    self.state = .NoResults
                } else {
                    searchResults.sortInPlace(<)
                    self.state = .Results(searchResults)
                }
                success = true
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                completion(success)
            }
        }
        dataTask?.resume()
    }
    
    private func urlWithSearchText(searchText: String, category: Category) -> NSURL {
        
        let entityName = category.entityName
        
        let encodedText = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let urlString   = String(format: "https://itunes.apple.com/search?term=%@&limit=200&entity=%@", encodedText, entityName)
        let url         = NSURL(string: urlString)
        
        return url!
    }
    
    private func parseJSON(data: NSData) -> [String: AnyObject]? {
        
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject]
        }
        catch {
            print("JSON Error: \(error)")
            return nil
        }
    }
    
    private func parseDictionary(dictionary: [String: AnyObject]) -> [SearchResult] {
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
    
    private func parseTrack(dictionary: [String: AnyObject]) -> SearchResult {
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
    
    private func parseSoftware(dictionary: [String: AnyObject]) -> SearchResult {
        
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
    
    private func parseEBook(dictionary: [String: AnyObject]) -> SearchResult {
        
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
    
    
    private func parseAudioBook(dictionary: [String: AnyObject]) -> SearchResult {
        
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

