//
//  testView.swift
//  Appear_Ios
//
//  Created by Davin Glick on 5/12/16.
//  Copyright © 2016 Appear. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class testView: UIViewController {
    
   var fir: FIRDatabaseReference!
   let ref = FIRDatabase.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    @IBAction func firebaseQ(_ sender: Any) {
        
        createSuperCart()
    
    }
    
    func createSuperCart() {
        
        if let user = FIRAuth.auth()?.currentUser {
            
            let uid = user.uid
            
            self.ref.child("CCard").observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                if snapshot.hasChild(uid.self){
                    
                    print("Cart does exist")
                    
                }else{
                    
                    print("cart doesn't exist")
                    
                }
                
                
            })
        }

    
 }


}
