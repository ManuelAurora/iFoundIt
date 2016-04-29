//
//  SearchResult.swift
//  iFoundIt
//
//  Created by Мануэль on 19.04.16.
//  Copyright © 2016 Мануэль. All rights reserved.
//

import Foundation

class SearchResult
{
    var price         = 0.0
    var kind          = ""
    var name          = ""
    var genre         = ""
    var currency      = ""
    var storeURL      = ""
    var artistName    = ""
    var artworkURL60  = ""
    var artworkURL100 = ""
    
    func kindForDisplay() -> String {
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