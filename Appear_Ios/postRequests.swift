//
//  postRequests.swift
//  Appear_Ios
//
//  Created by Davin Glick on 29/11/16.
//  Copyright © 2016 Appear. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Alamofire
import SwiftyJSON
import Stripe

class postRequests: UIViewController, STPPaymentCardTextFieldDelegate {
    
    @IBOutlet var userID: UILabel!
    @IBOutlet var button: UIButton!
    @IBOutlet var textField: STPPaymentCardTextField!
    
    
    var cust = [User]()
    var stripeUtil = createStripeUser()
    var cards = [AnyObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let user = FIRAuth.auth()?.currentUser
    
        let email = user?.email
        let uid = user?.uid
        let photoURL = user?.photoURL
        let userName = user?.displayName
        
        if FIRAuth.auth()?.currentUser != nil {
            
        userID.text = userName
            
            print(uid)
            
            
        } else {
            
            print("fuck off")
        
        }
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    func getStripeUser() {
        
        let shopifyURL = "http://localhost:3000/customer"
        Alamofire.request(shopifyURL).responseJSON { (response) -> Void in
        // check if the result has a value
        
            
        if let value = response.result.value {
            
            let json = JSON(value)
               
            print(json)
            
          
            }
         }
    }
    
    @IBAction func button(_ sender: Any) {
        
         let params = textField.cardParams
        
        //check if the customerId exist
        if let tokenId = stripeUtil.customerId {
            //if yes, call the createCard method of our stripeUtil object, pass customer id
            self.stripeUtil.createCard(tokenId, card: params, completion: { (success) in
                //there is a new card !
                self.stripeUtil.getCardsList({ (result) in
                    if let result = result {
                        self.cards = result
                    }
                    //store results on our cards, clear textfield and reload tableView
                    dispatch_async(dispatch_get_main_queue(), {
                        self.cardTextField.clear()
                        self.cardsTableView.reloadData()
                    })
                })
            })
        }
        else {
            //if not, create the user with our createUser method
            self.stripeUtil.createUser(card: params, completion: { (success) in
                
                    //store results on our cards, clear textfield and reload tableView
                
                        self.textField.clear()
                        
               
                })
        }
    }
}
