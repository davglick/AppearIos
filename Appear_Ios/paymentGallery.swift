//
//  paymentGallery.swift
//  Appear_Ios
//
//  Created by Davin Glick on 28/11/16.
//  Copyright © 2016 Appear. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import AVFoundation
import Stripe
import SVProgressHUD


class paymentGallery: UIViewController, CardIOPaymentViewControllerDelegate, STPPaymentCardTextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var creditCardGallery: UITableView!

    @IBOutlet var addCard: UIButton!
    
    @IBOutlet var paymentGallery: UIView!
    
    @IBOutlet var close: UIButton!
    
    
    var soundEffect = AVAudioPlayer()
    var CC = [creditCard]()
    var DBref: FIRDatabaseReference!

    
    var gravity: UIGravityBehavior!
    var animator: UIDynamicAnimator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initiate the Firebase database
        
        if let user = FIRAuth.auth()?.currentUser {
            
            let uid = user.uid
            
            
            DBref = FIRDatabase.database().reference().child("CCard").child(uid)
            
            
            DBref.observe(.value, with: { snapshot in
                
                var newCards = [creditCard]()
                
                for cCard in snapshot.children {
                    
                    let newCard = creditCard(snapshot: cCard as! FIRDataSnapshot)
                    newCards.insert(newCard, at:0)
                }
                
                self.CC = newCards
                self.creditCardGallery.reloadData()
                
            }) { (Error) in
                
                print(Error.localizedDescription)
                
            }
            
            
        }

        
        creditCardGallery.delegate = self
        creditCardGallery.dataSource = self
        

        // card.io preload
        
        CardIOUtilities.preload()
        
        // give background an opacity 
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        // Make add button rounded 
        
        
        self.addCard.layer.cornerRadius = self.addCard.frame.size.width/2
        self.addCard.layer.borderColor = UIColor(red: 160/255, green: 160/255, blue: 159/255, alpha: 1).cgColor
        self.addCard.layer.borderWidth = 0.05
        self.addCard.clipsToBounds = true

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func animateOut () {
        
        UIView.animate(withDuration: 0.5, animations: {
            //self.view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0
            
            self.animator = UIDynamicAnimator(referenceView: self.paymentGallery)
            self.gravity = UIGravityBehavior(items: [self.paymentGallery])
            self.animator.addBehavior(self.gravity)
            
        }) { (success: Bool) in
            self.paymentGallery.removeFromSuperview()
            
        }
        
    }
    
    @IBAction func paymentGallery(_ sender: Any) {
        
        animateOut()
        
    }
    
    @IBAction func scanCard(_ sender: AnyObject) {
        let cardIOVC = CardIOPaymentViewController(paymentDelegate: self)
        cardIOVC?.modalPresentationStyle = .formSheet
        present(cardIOVC!, animated: true, completion: nil)
        
        
    }
    

    func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
       // label.text = "user canceled"
        paymentViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    
    func getStripeToken(card:STPCardParams) {
        // get stripe token for current card
        STPAPIClient.shared().createToken(withCard: card) { token, error in
            if let token = token {
                print(token)
                SVProgressHUD.showSuccess(withStatus: "Stripe token successfully received: \(token)")
                //self.getStripeToken(token)
            } else {
                print(error)
               // SVProgressHUD.showErrorWithStatus(error?.localizedDescription)
            }
        }
    }

    
    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        if let info = cardInfo {
            let str = NSString(format: "Received card info.\n Number: %@\n expiry: %02lu/%lu\n cvv: %@.", info.redactedCardNumber, info.expiryMonth, info.expiryYear, info.cvv)
           // label.text = str as String
            
            
        if let user = FIRAuth.auth()?.currentUser {
            
            let uid = user.uid
            
            // Create add address ref in firebase
           // let CCRef = DBref.child("CCard").child(uid)
            let addCC = creditCard(cardNum: info.redactedCardNumber)
            
            DBref?.childByAutoId().setValue(addCC.toAnyObject())

            
            }
            
            print(str)

        //dismiss scanning controller
        paymentViewController?.dismiss(animated: true, completion: nil)
        
            
       }
   
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return CC.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
         let cell = tableView.dequeueReusableCell(withIdentifier: "card", for: indexPath) as! cardCell
        
        cell.creditCardLine.text = CC[indexPath.row].cardNumber
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)  {
        if editingStyle == .delete {
            
            
            // Delete the row from the data source
            let ref = CC[indexPath.row].ref
            ref!.removeValue()
            CC.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .none)
            
            // Trigger sound effect when the add address button is pressed
            
            let alertSound = Bundle.main.path(forResource: "swipe", ofType: "mp3")
            
            if let alertSound = alertSound {
                
                let alertSoundURL = NSURL(fileURLWithPath: alertSound)
                
                do{
                    
                    try soundEffect = AVAudioPlayer(contentsOf: alertSoundURL as URL)
                    
                    soundEffect.play()
                    
                } catch {
                    
                    print("error")
                }
            }
            
            
        }
        
    }

}
