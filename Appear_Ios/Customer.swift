//
//  Customer.swift
//  Appear_Ios
//
//  Created by Davin Glick on 29/11/16.
//  Copyright © 2016 Appear. All rights reserved.
//

import UIKit
import Foundation

struct customer {
    
    let id: String!
    let currency:String!
    let email: String!
    
    
    init(id: String, currency: String, email: String) {
        
        self.id = id
        self.currency = currency
        self.email = email
       
    }
    
        
}
