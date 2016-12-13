//
//  creditCard.swift
//  Appear_Ios
//
//  Created by Davin Glick on 28/11/16.
//  Copyright © 2016 Appear. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase


struct creditCard {
    
    var cardNumber: String!
    var ref: FIRDatabaseReference?
    var key: String!
    
    init(cardNum: String, key: String = "") {
        
        self.cardNumber = cardNum
        self.key = key
        self.ref = FIRDatabase.database().reference()
        
        
    }
    
    
    init(snapshot: FIRDataSnapshot){
        
        
        cardNumber = (snapshot.value as? NSDictionary)?["cardNum"] as? String

        self.key = snapshot.key
        self.ref = snapshot.ref
        
    }

    
    func toAnyObject() -> [String: AnyObject] {
        
        return ["cardNum": cardNumber as AnyObject]
    }
    
    
    
}

