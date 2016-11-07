//
//  Vendor.swift
//  Appear_Ios
//
//  Created by Davin Glick on 28/10/16.
//  Copyright © 2016 Appear. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class Vendor: NSObject {
    
    var coverURL: String?
    var coverPhoto: UIImageView?
    var name: String!
    var key: String!
    var hex: String!
    var logo: UIImageView?
    var logoURL: String!
    var APIToken: String?
    var StoreDomain: String?
    var imageDisplay: String!
    var ref: FIRDatabaseReference?
    
    
    
    
    init(coverURL: String, coverPhoto: String, name: String, hex: String, APIToken: String, StoreDomain: String, imageDisplay: String, logoURL: String, key: String = "") {
        
        self.coverURL = coverURL
        self.coverPhoto = UIImageView()
        self.logoURL = logoURL
        self.name = name
        self.hex = hex
        self.APIToken = APIToken
        self.StoreDomain = StoreDomain
        self.imageDisplay = imageDisplay
        self.logo = UIImageView()
        self.key = key
        self.ref = FIRDatabase.database().reference()
        
        
        
    }
    
    
    init(snapshot: FIRDataSnapshot) {
        
        
        coverURL = (snapshot.value as? NSDictionary)?["background"] as? String
        coverPhoto = UIImageView()
        name = (snapshot.value as? NSDictionary)? ["name"] as? String
        hex = (snapshot.value as? NSDictionary)? ["hex"] as? String
        APIToken = (snapshot.value as? NSDictionary)? ["APIToken"] as? String
        StoreDomain = (snapshot.value as? NSDictionary)? ["StoreDomain"] as? String
        imageDisplay = (snapshot.value as? NSDictionary)? ["imageDisplay"] as? String
        logoURL = (snapshot.value as? NSDictionary)? ["logo"] as? String
        self.key = snapshot.key
        self.ref = snapshot.ref
        
    }
    
    func toAnyObject() -> [String: AnyObject] {
        
        return ["coverURL": coverURL as AnyObject , "coverPhoto": coverPhoto as AnyObject, "name": name as AnyObject, "hex": hex as AnyObject, "APIToken": APIToken as AnyObject, "StoreDomain": StoreDomain as AnyObject, "imageDisplay": imageDisplay as AnyObject, "logoUrl": logoURL as AnyObject]
    }
    
    
}
