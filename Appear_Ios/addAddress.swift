//
//  addAddress.swift
//  Appear_Ios
//
//  Created by Davin Glick on 4/11/16.
//  Copyright © 2016 Appear. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase




struct addAddress {
    
    var addressName: String!
    var DefaultAddress:String!
    var number: String!
    var GeoLocation: String!
    var ref: FIRDatabaseReference?
    var key: String!
    
    init(addressName: String, DefaultAddress: String, number: String, GeoLocation: String, key: String = "") {
        
        self.addressName = addressName
        self.DefaultAddress = DefaultAddress
        self.number = number
        self.GeoLocation = GeoLocation
        self.key = key
        self.ref = FIRDatabase.database().reference()
        
        
    }
    
    
    init(snapshot: FIRDataSnapshot){
        
        
        addressName = (snapshot.value as? NSDictionary)?["addressName"] as? String
        DefaultAddress = (snapshot.value as? NSDictionary)?["default Address"] as? String
        GeoLocation = (snapshot.value as? NSDictionary)? ["GeoLocation"] as? String
        number = (snapshot.value as? NSDictionary)?["0"] as? String
        self.key = snapshot.key
        self.ref = snapshot.ref
        
    }
    
    func toAnyObject() -> [String: AnyObject] {
        
        return ["addressName": addressName as AnyObject , "DefaultAddress": DefaultAddress as AnyObject, "number": number as AnyObject, "GeoLocation" : GeoLocation as AnyObject]
    }
    
    
    
}


