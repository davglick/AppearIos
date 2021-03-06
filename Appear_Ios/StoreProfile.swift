//
//  StoreProfile.swift
//  Appear_Ios
//
//  Created by Davin Glick on 28/10/16.
//  Copyright © 2016 Appear. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import SDWebImage



class StoreProfile: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var profilePicture: UIBarButtonItem!
    
     var gravity: UIGravityBehavior!
     var animator: UIDynamicAnimator!
    
 
    
    @IBOutlet var navigationBarrrrr: UINavigationBar!
    
    @IBOutlet var list: UITableView!
    
    var ThescrollView: UIScrollView!
    
    var stores = [Vendor]()
    var databaseRef: FIRDatabaseReference!
    var storage: FIRStorageReference!
    var transitionManager = MenuTransitionManager()
    
    override func viewWillAppear(_ animated: Bool) {
        
        loadStores()
        
    }
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.transitionManager.sourceViewController = self
               
        // Reference to table view nib file
        let nib = UINib(nibName: "storeProfileCell", bundle: nil)
        list.register(nib, forCellReuseIdentifier: "Cell")
        list.separatorStyle = .none
        list.showsHorizontalScrollIndicator = false
        list.showsVerticalScrollIndicator = false
        
        
        // make the nav bar transparent
        navigationBarrrrr.setBackgroundImage(UIImage(), for: .default)
        navigationBarrrrr.shadowImage = UIImage()
        self.navigationBarrrrr.backgroundColor = .clear
        self.navigationBarrrrr.isTranslucent = true
        
        
        
        
        list.delegate = self
        list.dataSource = self
        
        
        // Call to firebase DB and get stores to load
        
        
        databaseRef = FIRDatabase.database().reference().child("Vendor")
        
        databaseRef.observe(.value, with: { (snapshot) in
            
            
            var newItems = [Vendor]()
            
            for item in snapshot.children {
                
                let newVendors = Vendor(snapshot: item as! FIRDataSnapshot)
                newItems.insert(newVendors, at: 0)
            }
            
            self.stores = newItems
            self.list.reloadData()
            
        }) { (Error) in
            
            
            print(Error.localizedDescription)
            
        }
        
    }
    
    // **************** Segue to user profile section *************** //
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        let menu = segue.destination as! ProfileView
        menu.transitioningDelegate = self.transitionManager
        
        
        
    }
    
    
    
    @IBAction func unwindToViewController (sender: UIStoryboardSegue){
  
            
            self.dismiss(animated: false, completion: nil)
       
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func loadStores() {
        // Call to firebase DB and get stores to load
        
        
    databaseRef = FIRDatabase.database().reference().child("Vendor")
    
    databaseRef.observe(.value, with: { (snapshot) in
    
    
    var newItems = [Vendor]()
    
    for item in snapshot.children {
    
    let newVendors = Vendor(snapshot: item as! FIRDataSnapshot)
    newItems.insert(newVendors, at: 0)
    }
    
    self.stores = newItems
    self.list.reloadData()
    
    }) { (Error) in
    
    
    print(Error.localizedDescription)
    
    }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.stores.count
        
    }
    

    
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        let cell: StoreProfileList = self.list.cellForRow(at: indexPath) as! StoreProfileList
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "vendorProfile") as! VendorProfile
        self.addChildViewController(vc)
        vc.view.frame = self.view.frame
        self.view.addSubview(vc.view)
        vc.didMove(toParentViewController: self)
  
        vc.store = self.stores[indexPath.row]
        
        vc.loadStore()
           
        print(cell.vendorName)

    
    
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return self.list.frame.height / 3.6
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! StoreProfileList
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        
        // getting web image URL content
        
        DispatchQueue.global(qos: .background).async {
            
       
            let cover = self.stores[indexPath.row].coverURL
            let imageURL:NSURL? = NSURL(string: cover! )
            if let url = imageURL {
                cell.cover.sd_setImage(with: url as URL!, placeholderImage: #imageLiteral(resourceName: "storebackground"))
         
                // testing speed //
                
                let methodStart = Date()
                
                
                let methodFinish = Date()
                let executionTime = methodFinish.timeIntervalSince(methodStart)
                print("Execution Time: \(executionTime)")
                
                
                
                
            }
        }
        
        // Display the vendor name
        cell.vendorName.text = stores[indexPath.row].name
        
        
        return cell
    }
    

}


