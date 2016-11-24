//
//  AddressGalleryCell.swift
//  Appear_Ios
//
//  Created by Davin Glick on 7/11/16.
//  Copyright © 2016 Appear. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase



class AddressGalleryCell: UIViewController {
    
    @IBOutlet var defaultAddress: UILabel!
    
    var addressArray = [addAddress]()
    
    var databaseRef: FIRDatabaseReference!
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = FIRAuth.auth()?.currentUser {
            
            let uid = user.uid
            
           
            databaseRef = FIRDatabase.database().reference().child("Delivery-Address").child(uid)

           
            
            
        }

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
