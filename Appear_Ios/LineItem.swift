//
//  LineItem.swift
//  Appear_Ios
//
//  Created by Davin Glick on 1/11/16.
//  Copyright © 2016 Appear. All rights reserved.
//

import UIKit

class LineItem: NSObject {
    
    var id: String?
    var image = [String?]()
    var title: String?
    var vendor: String?
    var price: Int?
    var quantity: Int = 0
    var SKU: String?
    var option: Option?
    var variantID: String?
    
}
