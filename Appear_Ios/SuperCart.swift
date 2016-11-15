//
//  SuperCart.swift
//  Appear_Ios
//
//  Created by Davin Glick on 14/11/16.
//  Copyright © 2016 Appear. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SuperCart: NSObject {
    
    var superCartID: String?
    var userID: String?
    var subTotal: Int?
    var shippingTotal: Int?
    var total: Int?
    var productCount: Int?
    var completed: Bool = false
    
    convenience init(snapshot: FIRDataSnapshot?) {
        self.init()
        superCartID = snapshot!.key as String?
        userID = (snapshot?.value as? NSDictionary)?["UID"] as? String
        subTotal = (snapshot?.value as? NSDictionary)?["subTotal"] as? Int
        shippingTotal = (snapshot?.value as? NSDictionary)? ["shippingTotal"] as? Int
        total = (snapshot?.value as? NSDictionary)?["total"] as? Int
        productCount = (snapshot?.value as? NSDictionary)?["productCount"] as? Int
        // json = nil
        //storeCount = 0
    }
}




