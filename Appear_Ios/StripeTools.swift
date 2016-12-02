//
//  StripeTools.swift
//  Appear_Ios
//
//  Created by Davin Glick on 2/12/16.
//  Copyright © 2016 Appear. All rights reserved.
//

import UIKit
import Stripe

class StripeTools: NSObject {

    //store stripe secret key
    private var stripeSecret = "sk_test_ndoQxTKblloCG2EDELfg3kJT"
    
    //generate token each time you need to get an api call
    func generateToken(card: STPCardParams, completion: @escaping (_ token: STPToken?) -> Void) {
        STPAPIClient.shared().createToken(withCard: card) { token, error in
            if let token = token {
                completion(token)
            }
            else {
                print(error)
                completion(nil)
            }
        }
    }
    
    func getBasicAuth() -> String{
        return "Bearer \(self.stripeSecret)"
    }
    
}
