//
//  User.swift
//  Appear_Ios
//
//  Created by Davin Glick on 4/11/16.
//  Copyright © 2016 Appear. All rights reserved.
//

import UIKit

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class User: NSObject {
    
    var email: String?
    var firstName: String?
    var lastName: String?
    var password: String?
    var gender: String?
    var mobile: String?
    var profilePic: UIImage?
    var key: String!
    var ref: FIRDatabaseReference?
    
    
    init(snapshot: FIRDataSnapshot){
        
        
        email = (snapshot.value as? NSDictionary)?["email"] as? String
        firstName = (snapshot.value as? NSDictionary)?["firstName"] as? String
        lastName = (snapshot.value as? NSDictionary)? ["lastName"] as? String
        gender = (snapshot.value as? NSDictionary)?["Gender"] as? String
        mobile = (snapshot.value as? NSDictionary)?["000 000 000"] as? String
        self.key = snapshot.key
        self.ref = snapshot.ref
        
    }
    
    func toAnyObject() -> [String: AnyObject] {
        
        return ["email": email as AnyObject , "firstName": firstName as AnyObject, "lastName": lastName as AnyObject, "Gender" : gender as AnyObject]
    }
    
    
}
