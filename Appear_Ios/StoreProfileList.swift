//
//  StoreProfileList.swift
//  Appear_Ios
//
//  Created by Davin Glick on 28/10/16.
//  Copyright © 2016 Appear. All rights reserved.
//

import UIKit
import SceneKit

class StoreProfileList: UITableViewCell {
    
    @IBOutlet weak var vendorName: UILabel!
    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var opacity: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
 
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    
}
