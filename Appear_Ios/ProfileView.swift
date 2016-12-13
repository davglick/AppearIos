//
//  ProfileView.swift
//  Appear_Ios
//
//  Created by Davin Glick on 2/11/16.
//  Copyright © 2016 Appear. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKCoreKit
import FirebaseStorage
import FirebaseDatabase


let interactor = Interact()

extension ViewController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimation()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}

class UserProfile : UIViewController  {
    
 


    @IBOutlet var backToStore: UIBarButtonItem!
    
    @IBOutlet var storeButton: UIBarButtonItem!
    
    @IBOutlet var profileCellView: UIView!
    
    @IBOutlet var profileView: UIView!
    
    @IBOutlet var addressView: UIView!
    
    @IBOutlet var paymentView: UIView!
    
    @IBOutlet var profilePicture: UIImageView!
    
    @IBOutlet var profileViewTrigger: UIButton!
    
    @IBOutlet var PaymentGallery: UIButton!
    
    var supercart: SuperCart?
    var facebookView = FacebookLoginPopUp()
    var ref: FIRDatabaseReference!
    var DBRef = FIRDatabase.database().reference()
    let interactor = Interact()

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? paymentGalleryViewController {
            //destinationViewController.transitioningDelegate = UserProfile.self
            destinationViewController.interactor = interactor
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        // Customize the Profile View
        
        self.profileCellView.layer.cornerRadius = 4
        self.profileCellView.layer.borderWidth = 1
        self.profileCellView.layer.borderColor = UIColor(red:208/255.0, green:208/255.0, blue:208/255.0, alpha: 0.8).cgColor
        
        // Customize Address View
        
        self.addressView.layer.cornerRadius = 4
        self.addressView.layer.borderWidth = 1
        self.addressView.layer.borderColor = UIColor(red:208/255.0, green:208/255.0, blue:208/255.0, alpha: 0.8).cgColor
        // Customize Payment View
        
        self.paymentView.layer.cornerRadius = 4
        self.paymentView.layer.borderWidth = 1
        self.paymentView.layer.borderColor = UIColor(red:208/255.0, green:208/255.0, blue:208/255.0, alpha: 0.8).cgColor
        
        
        // make the profile picture round
        
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width/2
        self.profilePicture.layer.borderColor = UIColor(red: 211/255, green: 221/255, blue: 229/255, alpha: 0.5).cgColor
        self.profilePicture.layer.borderWidth = 0.25
        self.profilePicture.clipsToBounds = true
        
        
        // No user is signed in.
        
        if FIRAuth.auth()?.currentUser == nil {
            
       
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "FacebookLogin") as! FacebookLoginPopUp
           
            self.navigationController?.pushViewController(vc, animated: false)
            
        
        } else {
   
            
        if let user = FIRAuth.auth()?.currentUser {
            
           // User is signed in.
          
            let name: String = user.displayName!
            let email: String = user.email!
            let photoUrl = user.photoURL
            let uid = user.uid
            
            
            
            //  self.profileName.text = user.displayName
            
            let data = NSData(contentsOf: photoUrl!)
            self.profilePicture.image = UIImage(data: data! as Data)
            
            }
        }
    }


                
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create swipe gesture recogniser
        var leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
    
    }
 

    @IBAction func tranition(_ sender: Any) {
        
        print("Sent")
    }
    
    @IBAction func showPopUpView(_ sender: AnyObject) {
        
        let popUpVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileViewPopUp") as! ViewProfilePopUp
        self.addChildViewController(popUpVc)
        popUpVc.view.frame = self.view.frame
        self.view.addSubview(popUpVc.view)
        popUpVc.didMove(toParentViewController: self)
        
        
    }
    

    // move to the address profile
    
    @IBAction func addressGalleryTrigger(_ sender: AnyObject) {
        
        let addressGalleryPopUp = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddressGalleryPopUp") as! AddressGalleryView
        self.addChildViewController(addressGalleryPopUp)
        addressGalleryPopUp.view.frame = self.view.frame
        self.view.addSubview(addressGalleryPopUp.view)
        addressGalleryPopUp.didMove(toParentViewController: self)
        
        
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

    @IBAction func backToStoreList(_ sender: Any) {
        
        let transition = CATransition()
        transition.duration = 0.1
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        self.navigationController?.view.layer.add(transition, forKey: nil)
        _ = self.navigationController?.popToRootViewController(animated: false)
    }

    // handle the user swipe right to remove the view
    
    func handleSwipeLeft(sender: UISwipeGestureRecognizer) {
        
        if (sender.direction == .left) {
            
            let transition = CATransition()
            transition.duration = 0.15
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            self.navigationController?.view.layer.add(transition, forKey: nil)
            _ = self.navigationController?.popToRootViewController(animated: false)
           
            
        }
        
    }

  }



/*
 
 // Firebase storage
 
 
 // Referance to storage
 
 let storage = FIRStorage.storage()
 
 // Instanciate the firebase database
 
 ref = FIRDatabase.database().reference()
 
 
 // Facebook user in firebase DB
 
 self.ref.child("Users").child(uid).setValue(["userName": name, "UserEmail": email])
 
 
 // Refeance to our storage service
 let storageRef = storage.reference(forURL: "gs://appearprofile.appspot.com")
 
 
 var profilePic = FBSDKGraphRequest(graphPath: "me/picture", parameters: ["height": 300, "width": 300,"redirect": false], httpMethod: "GET")
 profilePic?.start(completionHandler: {(connection, result, error) -> Void in
 
 // Handle the result
 
 if(error == nil)
 
 {
 
 
 let dictionary = result as? NSDictionary
 let data = dictionary?.object(forKey: ("data"))
 
 let urlPic = (data as AnyObject?)?.object(forKey:"url")! as! String
 
 
 if let imageData = NSData(contentsOf: NSURL(string:urlPic)! as URL)
 
 {
 
 
 let profilePicRef = storageRef.child(user.uid+"/profile_pic.jpg")
 
 let uploadTask = profilePicRef.put(imageData as Data, metadata: nil) {
 
 metadata, error in
 
 
 if(error == nil)
 {
 
 let downloadUrl = metadata!.downloadURL
 }
 
 else
 
 {
 }
 print("error in downoalding image")
 
 
 }
 
 }
 
 
 }
 
 })
 
 }
 }
 
 }
 */







