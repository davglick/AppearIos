//
//  AddressGalleryView.swift
//  Appear_Ios
//
//  Created by Davin Glick on 4/11/16.
//  Copyright © 2016 Appear. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import AVFoundation



class AddressGalleryView: UIViewController, UIViewControllerTransitioningDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var gravity: UIGravityBehavior!
    var animator: UIDynamicAnimator!
    
 
    let addressMapView = AddressMapView()
    
    let transition = CircularTransition()
    
    let addressMap = AddressMapView()
    
    
    @IBOutlet var addressGallery: UITableView!
    
    @IBOutlet var addressGalleryView: UIView!
    
    @IBOutlet var addressGalleryHeader: UIButton!
    
    @IBOutlet var addAddressButton: UIButton!
    
    @IBOutlet var addressTable: UITableView!
    
    var soundEffect = AVAudioPlayer()
    
    
    // Call firebase database and Address Array
    
    var addressArray = [addAddress]()
    
    var databaseRef: FIRDatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // scroll.scrollView.isScrollEnabled = false;
        
        // self.scroll.scrollView.isScrollEnabled = false
        
        
        addressTable.delegate = self
        addressTable.dataSource = self
        
        
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
                self.addressTable.reloadData()
                
            }) { (Error) in
                
                print(Error.localizedDescription)
                
            }
            
            
        }
        
        
        
        // profile View Design
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        self.addressGalleryView.layer.cornerRadius = 4
        
        // address gallery grey header design
        
        self.addressGalleryHeader.layer.cornerRadius = 1
        
        
        // add address button design
        
        self.addAddressButton.layer.cornerRadius = self.addAddressButton.frame.size.width/2
        self.addAddressButton.layer.borderColor = UIColor(red: 160/255, green: 160/255, blue: 159/255, alpha: 1).cgColor
        self.addAddressButton.layer.borderWidth = 0.05
        self.addAddressButton.clipsToBounds = true
        
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    func animateOut () {
        
        UIView.animate(withDuration: 0.5, animations: {
            //self.view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0
            
            self.animator = UIDynamicAnimator(referenceView: self.addressGalleryView)
            self.gravity = UIGravityBehavior(items: [self.addressGalleryView])
            self.animator.addBehavior(self.gravity)
            
        }) { (success: Bool) in
            self.addressGalleryView.removeFromSuperview()
            
        }
        
    }
    
    
   
    
        
    
    
    @IBAction func closeAddressPopUp(_ sender: AnyObject) {
        
        animateOut()
        
    }
    
    
    // Create an observer to see chages in address table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return addressArray.count
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AddressCell
        
        // Configure the Cell
        
        //cell.textLabel?.text = addressArray[indexPath.row].addressName
        //cell.addressCellString.text = addressArray[indexPath.row].addressName
        //cell.selectedAddressTick = addressArray[indexPath.row].DefaultAddress.true
        
        
        cell.addressStringLabel.text = addressArray[indexPath.row].addressName
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)  {
        
        
        
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)  {
        if editingStyle == .delete {
            
            
            // Delete the row from the data source
            let ref = addressArray[indexPath.row].ref
            ref!.removeValue()
            addressArray.remove(at: indexPath.row)
            
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
    
    @IBAction func addNewAddress(_ sender: Any) {
        
        let toMap = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddressMapView") as! AddressMapView
        self.addChildViewController(toMap)
        toMap.view.frame = self.view.frame
        self.view.addSubview(toMap.view)
        toMap.didMove(toParentViewController: self)
        
    }
    
}
