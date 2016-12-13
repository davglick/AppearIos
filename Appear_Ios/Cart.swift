//
//  Cart.swift
//  Appear_Ios
//
//  Created by Davin Glick on 14/11/16.
//  Copyright © 2016 Appear. All rights reserved.
//

import UIKit
import Firebase

class Cart: NSObject {
    
    var cartToken: String?
    var superCartUID: String?
    var vendorID: String?
    var timestampCreated: String?
    var itemCount: Int = 0
    var cartSubTotal: Int = 0
    var cartShippingTotal: Int = 0
    var cartTotal: Int = 0
    var cartId: String?
    
    convenience init(snapshot: FIRDataSnapshot) {
        self.init()
        cartToken = snapshot.key as String
        superCartUID = (snapshot.value as? NSDictionary)?["superCartToken"] as? String
        vendorID = (snapshot.value as? NSDictionary)?["vendorID"] as? String
        cartId = (snapshot.value as? NSDictionary)?["cartId"] as? String
        timestampCreated = (snapshot.value as? NSDictionary)?["timestampCreated"] as? String
    }
}
