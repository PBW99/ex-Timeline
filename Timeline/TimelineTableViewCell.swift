//
//  TimelineTableViewCell.swift
//  Timeline
//
//  Created by pbw on 2017. 7. 27..
//  Copyright © 2017년 pbw. All rights reserved.
//

import UIKit

class TimelineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var TextLabel: UILabel!
    @IBOutlet weak var ImageView: UIImageView!
    
    
    override func awakeFromNib(){
        super.awakeFromNib()
        
        // Initialization codey
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
  
    
}
