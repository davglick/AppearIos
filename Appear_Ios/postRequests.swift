//
//  postRequests.swift
//  Appear_Ios
//
//  Created by Davin Glick on 29/11/16.
//  Copyright © 2016 Appear. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import AVFoundation
import Stripe
import SVProgressHUD
import Alamofire
import SwiftyJSON





class postRequests: UIViewController,  CardIOPaymentViewControllerDelegate, STPPaymentCardTextFieldDelegate {
    
    @IBOutlet var userID: UILabel!
    @IBOutlet var button: UIButton!
    let ref = FIRDatabase.database().reference()
    let user = FIRAuth.auth()?.currentUser

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // card.io preload
        
        CardIOUtilities.preload()
        
      
    
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
    
    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        if let info = cardInfo {
            let str = NSString(format: "Received card info.\n Number: %@\n expiry: %02lu/%lu\n cvv: %@.", info.redactedCardNumber, info.expiryMonth, info.expiryYear, info.cvv)
            
            let uid = user?.uid
            
            self.ref.queryOrdered(byChild: "CCard").queryEqual(toValue: "\(uid)")
                .observeSingleEvent(of: .value, with: { snapshot in
                    
                    if ( snapshot.value is NSNull ) {
                        print("not found)") //didnt find it, ok to proceed
                        
                    } else {
                        print(snapshot.value) //found it, stop!
                    }
            })
            
        
        
            var stripCard = STPCard()
            
            // pass card to stripe
            stripCard.number = info.cardNumber
            stripCard.cvc = info.cvv
            stripCard.expMonth = info.expiryMonth
            stripCard.expYear = info.expiryYear
            
        
            print(str)
            
            
            //dismiss scanning controller
            paymentViewController?.dismiss(animated: true, completion: nil)
            
            
        }
        
    }

    
    @IBAction func scanCard(_ sender: AnyObject) {
        
        
        let cardIOVC = CardIOPaymentViewController(paymentDelegate: self)
        cardIOVC?.modalPresentationStyle = .formSheet
        present(cardIOVC!, animated: true, completion: nil)
        
        
        
        let email = user?.email
        let uid = user?.uid
        let photoURL = user?.photoURL
        let userName = user?.displayName
        let apiURL = "http://localhost:3000/add-customer"
        let params = ["email": email]
        let heads = ["Accept": "application/json"]
        
        
        
       
    }
    func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        // label.text = "user canceled"
        paymentViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    
    
}
