//
//  AddressList.swift
//  Appear_Ios
//
//  Created by Davin Glick on 4/11/16.
//  Copyright © 2016 Appear. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class AddressList: UITableViewController {
    
    
    var addressArray = [addAddress]()
    
    var databaseRef: FIRDatabaseReference!
    
    @IBOutlet var addressName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initiate the Firebase database
        
        if let user = FIRAuth.auth()?.currentUser {
            
            let uid = user.uid
            
            //let myTopPostsQuery = (databaseRef.child("Delivery_Address").child(uid)).queryOrdered(byChild: "addressName")
            
            databaseRef = FIRDatabase.database().reference().child("Delivery-Address").child(uid)
            
            
            databaseRef.observe(.value, with: { snapshot in
                
                var newAddress = [addAddress]()
                
                for address in snapshot.children {
                    
                    let newAddresses = addAddress(snapshot: address as! FIRDataSnapshot)
                    newAddress.insert(newAddresses, at:0)
                }
                
                self.addressArray = newAddress
                self.tableView.reloadData()
                
            }) { (Error) in
                
                print(Error.localizedDescription)
                
            }
            
            
        }
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return addressArray.count
        
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // Configure the Cell
        
        
        cell.textLabel?.text = addressArray[indexPath.row].addressName
        
        
        //cell.addressStringLabel.text = addressArray[indexPath.row].addressName
        //cell.selectedAddressTick = addressArray[indexPath.row].DefaultAddress.true
        
        return cell
        
}



}
