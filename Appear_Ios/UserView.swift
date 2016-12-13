//
//  UserView.swift
//  Appear_Ios
//
//  Created by Davin Glick on 2/11/16.
//  Copyright © 2016 Appear. All rights reserved.
//


import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit
import FBSDKCoreKit




class ProfileView: UIViewController {
    
    
    @IBOutlet var profileName: UILabel!
    
    var effect:UIVisualEffect!
    
    var databaseRef: FIRDatabaseReference!
 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let user = FIRAuth.auth()?.currentUser {
            // databaseRef.observe(.value, with: { snapshot in

            
            // User is signed in.
            
            
            let name = user.displayName
            let email = user.email
            let photoUrl = user.photoURL
            let uid = user.uid
            
            
            
            //  Display Profile Name, Photo and Email
            
            let data = NSData(contentsOf: photoUrl!)
            self.profileName.text = user.displayName
            // })
 
        }

   
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    }
    
    

