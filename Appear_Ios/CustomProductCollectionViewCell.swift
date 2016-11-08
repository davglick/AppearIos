//
//  CustomProductCollectionViewCell.swift
//  Appear_Ios
//
//  Created by Davin Glick on 8/11/16.
//  Copyright © 2016 Appear. All rights reserved.
//

import UIKit

class CustomProductCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var productImage: UIImageView!
    
    func setup(bounds: CGRect) {
        productImage.bounds = bounds
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}
