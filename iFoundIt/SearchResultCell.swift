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
    //MARK: # OUTLETS #
    
    @IBOutlet weak var nameLabel:        UILabel!
    @IBOutlet weak var artistNameLabel:  UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
