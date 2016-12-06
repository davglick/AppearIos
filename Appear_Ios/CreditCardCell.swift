//
//  CreditCardCell.swift
//  Appear_Ios
//
//  Created by Davin Glick on 6/12/16.
//  Copyright © 2016 Appear. All rights reserved.
//

import UIKit

class CreditCardCell: UITableViewCell {

    @IBOutlet var cardImage: UIImageView!
    @IBOutlet var cardNumber: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
