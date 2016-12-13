//
//  DefaultCard.swift
//  Appear_Ios
//
//  Created by Davin Glick on 6/12/16.
//  Copyright © 2016 Appear. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit
import FBSDKCoreKit

class DefaultCard: UIViewController {
    
    @IBOutlet var defaultCard: UILabel!
    var ref = FIRDatabase.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()

        
        if let user = FIRAuth.auth()?.currentUser {
        let uid = user.uid
            
        self.ref.child("CCard").observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            if snapshot.hasChild(uid.self){
                
        self.ref.child("CCard").observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                    if let snapshotValue = snapshot.value as? [String:Any],
                        let currentData = snapshotValue[uid.self] as? [String:Any] {
                        //let cardNum = (currentData["cardNum"])! as! String
                
                        
                    print("credit card user exists")
                   // print(cardNum)
                   // print(snapshot.value)
                    
            //self.defaultCard.text = cardNum
                
     
                } else {
                    
            self.defaultCard.text = "Add a payment method"
                    
            }
                })
                
               }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

}
