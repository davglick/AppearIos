//
//  cardCell.swift
//  Appear_Ios
//
//  Created by Davin Glick on 28/11/16.
//  Copyright © 2016 Appear. All rights reserved.
//

import UIKit

class cardCell: UITableViewCell {

    @IBOutlet var creditCardLine: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
