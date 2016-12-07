//
//  paymentGalleryViewController.swift
//  Appear_Ios
//
//  Created by Davin Glick on 6/12/16.
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

class paymentGalleryViewController: UIViewController, CardIOPaymentViewControllerDelegate, STPPaymentCardTextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var creditCardGallery: UITableView!
    @IBOutlet var paymentGalleryView: UIView!
    @IBOutlet var addCard: UIButton!
    @IBOutlet var applePay: UIButton!
    @IBOutlet var appleIcon: UIImageView!
    
    var interactor: Interact? = nil
    var customerId: String?
    var soundEffect = AVAudioPlayer()
    var CC = [creditCard]()
    var DBref: FIRDatabaseReference!
    let ref = FIRDatabase.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let x = UINib(nibName: "CreditCardCell", bundle: nil)
        creditCardGallery.register(x, forCellReuseIdentifier: "CreditCardCell")

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
        
        
        self.paymentGalleryView.layer.cornerRadius = 4
        
        // address gallery grey header design
        
        self.paymentGalleryView.layer.cornerRadius = 1
        
        // Make add button rounded
        
        self.addCard.layer.cornerRadius = 2
        self.addCard.layer.borderColor = UIColor(red: 160/255, green: 160/255, blue: 159/255, alpha: 1).cgColor
        self.addCard.layer.borderWidth = 0.05
        
        
        // design apple pay button
        self.applePay.layer.cornerRadius = 2
        self.applePay.layer.borderColor = UIColor(red: 160/255, green: 160/255, blue: 159/255, alpha: 1).cgColor
        self.addCard.layer.borderWidth = 0.05
        self.view.addSubview(appleIcon)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createCard(_ sender: Any) {
        
        createCreditCard()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return CC.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreditCardCell", for: indexPath) as! CreditCardCell
        
             cell.cardNumber.text = CC[indexPath.row].cardNumber
        
    
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var rowHeight:CGFloat = 0.0
        
        if(indexPath.row == 0){
            
            rowHeight = 0.0
            
        }
            
        else{
            
            rowHeight = self.creditCardGallery.frame.height / 5
        }
        
        return rowHeight
        
 
    }
        

    func createCreditCard() {
        
        if let user = FIRAuth.auth()?.currentUser {
            let uid = user.uid
            self.ref.child("CCard").observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                if snapshot.hasChild(uid.self){
                    print("credit card user exists")
                    print(snapshot.value)
                    
                } else {
                    
                    let email = user.email
                    let uid = user.uid
                    let photoURL = user.photoURL
                    let userName = user.displayName
                    let apiURL = "https://shielded-basin-63018.herokuapp.com/add-customer"
                    let params = ["email": email,
                                  "description": uid]
                    let heads = ["Accept": "application/json"]
                    
                    Alamofire.request(apiURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: heads).responseJSON { response in
                        print(response)
                        //to get status code
                        if let status = response.response?.statusCode {
                            switch(status){
                            case 201:
                                print("example success")
                            default:
                                print("error with response status: \(status)")
                            }
                        }
                        
                        //to get JSON return value
                        if let result = response.result.value {
                           let JSON = result as! NSDictionary
                            print(JSON)
                            let id = JSON["id"]!
                            print(id)
                            
                            
                   

                   self.DBref?.child("CustomerId").setValue((id as AnyObject))
                            
                            
                        }
                        
                    }
                    
                  
                    print("there is no user")
                    
                }
            })
        }
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
    
    @IBAction func scanCard(_ sender: AnyObject) {
        let cardIOVC = CardIOPaymentViewController(paymentDelegate: self)
        cardIOVC?.modalPresentationStyle = .formSheet
        present(cardIOVC!, animated: true, completion: nil)
        
    }
    
    func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        // label.text = "user canceled"
        paymentViewController?.dismiss(animated: true, completion: nil)
    }
    
    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        if let info = cardInfo {
            let str = NSString(format: "Received card info.\n Number: %@\n expiry: %02lu/%lu\n cvv: %@.", info.redactedCardNumber, info.expiryMonth, info.expiryYear, info.cvv)
            
            createCreditCard()
            
            if let user = FIRAuth.auth()?.currentUser {
                
                let uid = user.uid
                //createStripeUser()
                
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


    @IBAction func handleGesture(_ sender: UIPanGestureRecognizer) {
        
        
        let percentThreshold:CGFloat = 0.3
        
        // convert y-position to downward pull progress (percentage)
        let translation = sender.translation(in: view)
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
        
        
        guard let interactor = self.interactor else { return }
        
        switch sender.state {
        case .began:
            interactor.hasStarted = true
            dismiss(animated: true, completion: nil)
        case .changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            interactor.shouldFinish
                ? interactor.finish()
                : interactor.cancel()
        default:
            break
        }
    }
    
    @IBAction func getCustomer(_ sender: Any) {
        
        if let user = FIRAuth.auth()?.currentUser {
            
        let uid = user.uid
        let id = FIRDatabase.database().reference().child("CCard").child(uid.self)
        
        print(id)
        
        }
       // let apiURL = "http://localhost:3000/customer"

        
        
    }
}





