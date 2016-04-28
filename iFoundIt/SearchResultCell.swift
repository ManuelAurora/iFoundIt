//
//  SearchResultCell.swift
//  iFoundIt
//
//  Created by Мануэль on 25.04.16.
//  Copyright © 2016 Мануэль. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell
{
    //MARK: # INSTANCE VARIABLES #
    
    var downloadTask: NSURLSessionDownloadTask?
    
    //MARK: # OUTLETS #
    
    @IBOutlet weak var nameLabel:        UILabel!
    @IBOutlet weak var artistNameLabel:  UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    
    //MARK: # PARENT METHODS #

    override func awakeFromNib() {
        super.awakeFromNib()
       
        let selectedView = UIView(frame: CGRect.zero)
        
        selectedView.backgroundColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
        
        selectedBackgroundView = selectedView
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        downloadTask?.cancel()
        downloadTask = nil
        
        nameLabel.text         = nil
        artistNameLabel.text   = nil
        artworkImageView.image = nil
    }
    
    //MARK: # METHODS #
    
    func configureForSearchResult(searchResult: SearchResult) {
        nameLabel.text = searchResult.name
        
        if searchResult.artistName.isEmpty {
            artistNameLabel.text = "Unknown"
        } else {
            artistNameLabel.text = String(format: "%@ (%@)", searchResult.artistName, kindForDisplay(searchResult.kind))
        }
        
        artworkImageView.image = UIImage(named: "Placeholder")
        
        if let url = NSURL(string: searchResult.artworkURL60) {
            downloadTask = artworkImageView.loadImageWithURL(url)
        }
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
