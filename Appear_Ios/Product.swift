//
//  Product.swift
//  Appear_Ios
//
//  Created by Davin Glick on 29/10/16.
//  Copyright © 2016 Appear. All rights reserved.
//

import UIKit
import SwiftyJSON

class Product: NSObject {
    
    var id: String?
    var image = [String?]()
    var title: String?
    var vendor: String?
    var vendorID: String?
    var price: String?
    var product_type: String?
    var body_html: String?
    //var options: JSON?
    var variants: JSON?
    var SKU: String?
    var quantity: Int = 0
    var option: Option?
    var cartToken: String?
    
    convenience init(store: JSON) {
        self.init()
        var i = 0;
        id = String(describing: store["id"])
        while(i < store["images"].count) {
            image.append(store["images"][i]["src"].string)
            i += 1
        }
        title = store["title"].string?.capitalized
        vendor = store["vendor"].string?.capitalized
        price = store["variants"][0]["price"].string
        product_type = store["product_type"].string
        body_html = store["body_html"].string//potentially add when click info button
        //options = store["options"]
        variants = store["variants"]
    }
    
}


 
