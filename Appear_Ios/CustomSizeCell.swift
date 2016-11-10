//
//  CustomSizeCellTable.swift
//  Appear_Ios
//
//  Created by Davin Glick on 9/11/16.
//  Copyright © 2016 Appear. All rights reserved.
//

import UIKit

class CustomSizeCell: UITableViewCell {

    @IBOutlet weak var stock: UILabel!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var size: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}


