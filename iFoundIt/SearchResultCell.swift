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
       
        let selectedView = UIView(frame: CGRect.zero)
        
        selectedView.backgroundColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
        
        selectedBackgroundView = selectedView
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
