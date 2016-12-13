//
//  AddCreditCard.swift
//  Appear_Ios
//
//  Created by Davin Glick on 14/11/16.
//  Copyright © 2016 Appear. All rights reserved.
//



import UIKit
import Stripe
import SVProgressHUD

class AddCreditCard: UIViewController, STPPaymentCardTextFieldDelegate, CardIOPaymentViewControllerDelegate {
    
    @IBOutlet weak var payButton: UIButton!
    var paymentTextField: STPPaymentCardTextField!
    
    override func viewDidLoad() {
        // add stripe built-in text field to fill card information in the middle of the view
        super.viewDidLoad()
        let frame1 = CGRect(x: 20, y: 150, width: self.view.frame.size.width - 40, height: 40)
        paymentTextField = STPPaymentCardTextField(frame: frame1)
        paymentTextField.center = view.center
        paymentTextField.delegate = self
        view.addSubview(paymentTextField)
        //disable payButton if there is no card information
        payButton.enabled = false
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        CardIOUtilities.preload()
    }
    
    @IBAction func scanCard(sender: AnyObject) {
        //open cardIO controller to scan the card
        let cardIOVC = CardIOPaymentViewController(paymentDelegate: self)
        cardIOVC.modalPresentationStyle = .FormSheet
        presentViewController(cardIOVC, animated: true, completion: nil)
        
    }
    
    
    @IBAction func payButtonTapped(sender: AnyObject) {
        let card = paymentTextField.cardParams
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.Dark)
        //send card information to stripe to get back a token
        getStripeToken(card)
    }
    
    
    func getStripeToken(card:STPCardParams) {
        // get stripe token for current card
        STPAPIClient.sharedClient().createTokenWithCard(card) { token, error in
            if let token = token {
                print(token)
                SVProgressHUD.showSuccessWithStatus("Stripe token successfully received: \(token)")
                self.postStripeToken(token)
            } else {
                print(error)
                SVProgressHUD.showErrorWithStatus(error?.localizedDescription)
            }
        }
    }
    
    // charge money from backend
    func postStripeToken(token: STPToken) {
        //Set up these params as your backend require
        let params: [String: NSObject] = ["stripeToken": token.tokenId, "amount": 10]
        
        //TODO: Send params to your backend to process payment
        
    }
    
    func paymentCardTextFieldDidChange(textField: STPPaymentCardTextField) {
        if textField.valid{
            payButton.enabled = true
        }
    }
    
    //MARK: - CardIO Methods
    
    //Allow user to cancel card scanning
    func userDidCancelPaymentViewController(paymentViewController: CardIOPaymentViewController!) {
        print("user canceled")
        paymentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Callback when card is scanned correctly
    func userDidProvideCreditCardInfo(cardInfo: CardIOCreditCardInfo!, inPaymentViewController paymentViewController: CardIOPaymentViewController!) {
        if let info = cardInfo {
            let str = NSString(format: "Received card info.\n Number: %@\n expiry: %02lu/%lu\n cvv: %@.", info.redactedCardNumber, info.expiryMonth, info.expiryYear, info.cvv)
            print(str)
            
            //dismiss scanning controller
            paymentViewController?.dismissViewControllerAnimated(true, completion: nil)
            
            //create Stripe card
            let card: STPCardParams = STPCardParams()
            card.number = info.cardNumber
            card.expMonth = info.expiryMonth
            card.expYear = info.expiryYear
            card.cvc = info.cvv
            
            //Send to Stripe
            getStripeToken(card)
            
        }
    }

}
