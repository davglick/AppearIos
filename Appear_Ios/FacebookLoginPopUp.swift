//
//  FacebookLoginPopUp.swift
//  Appear_Ios
//
//  Created by Davin Glick on 5/11/16.
//  Copyright © 2016 Appear. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth

class FacebookLoginPopUp: UIViewController, FBSDKLoginButtonDelegate{
    
    @IBOutlet var FBView: UIView!
 
    @IBOutlet var loginButton: FBSDKLoginButton!
    
    var ref: FIRDatabaseReference!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.delegate = self
        loginButton.readPermissions = ["email","public_profile"]
        
        // add custom FB login button
        
        self.loginButton.layer.cornerRadius = 2
        
        self.FBView.layer.cornerRadius = 3
        
        
        // Create swipe gesture recogniser
        var leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
        

        

           }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    

    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {

        print("Did log out of FB")
        
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if error != nil {
            print("error")
            return
        } else
        {
            print("did login to FB")
         
            let accessToken = FBSDKAccessToken.current()
            guard let accessTokenString = accessToken?.tokenString else
            {return}
            
            let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
            
            FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
                if error != nil {
                print("Something went wrong signing in the facebook user", error ?? "")
                    return
                    
                  }
                
                print("Successfully logged in the user:", user ?? "")

                self.loginButton.isHidden = true
                
                self.removeView()
                
            })
            
            
            FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "email, first_name, last_name, gender, hometown, picture.type(large), birthday, verified"]).start {
                (connection, result, err) in
              
                
                if err != nil {
                    print("Failed to start graph request:", err)
                    return
                }
                
                print(result)
     
            }
            

        }
        
        
    }
    
    
    // handle the user swipe right to remove the view
    
    func handleSwipeLeft(sender: UISwipeGestureRecognizer) {
        
        if (sender.direction == .left) {
            
            let transition = CATransition()
            transition.duration = 0.1
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            transition.type = kCATransitionFade
            self.navigationController?.view.layer.add(transition, forKey: nil)
            _ = self.navigationController?.popToRootViewController(animated: false)
            
        }
        
    }
    @IBAction func closeFB(_ sender: Any) {
        
        
        let transition = CATransition()
        transition.duration = 0.1
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        transition.type = kCATransitionFade
        self.navigationController?.view.layer.add(transition, forKey: nil)
        _ = self.navigationController?.popToRootViewController(animated: false)
     


    }
    
    func removeView() {
        
        let transition = CATransition()
        transition.duration = 0.1
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        transition.type = kCATransitionFade
        self.navigationController?.view.layer.add(transition, forKey: nil)
        _ = self.navigationController?.popToRootViewController(animated: false)
    }




}


