//
//  VendorProfile.swift
//  Appear_Ios
//
//  Created by Davin Glick on 29/10/16.
//  Copyright © 2016 Appear. All rights reserved.
//
import UIKit
import SwiftyJSON
import SDWebImage
import Firebase
import FirebaseDatabase
import FirebaseAuth
import Alamofire
import Hex


class VendorProfile: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var gravity: UIGravityBehavior!
    var animator: UIDynamicAnimator!
    var store: Vendor!
    var databaseRef: FIRDatabaseReference!
    var storage: FIRStorageReference!
    var products = [Product]()

    typealias JSONStandard = [String: AnyObject]
    
    @IBOutlet var navigationBar: UINavigationBar!
   
    @IBOutlet var productCollection: UICollectionView!
    
    @IBOutlet var profile: UIBarButtonItem!
    
    @IBOutlet var shoppingBag: UIBarButtonItem!
    
    @IBOutlet var backToStores: UIButton!

    @IBOutlet var profilePic: UIImageView!
  
    @IBOutlet var bag: UIImageView!
  
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        
        
     
        
               self.showAnimate()
        
        // make the nav bar transparent
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        self.navigationBar.backgroundColor = .clear
        self.navigationBar.isTranslucent = true
        
        
        
        // Add the back to stores button
        
        self.view.addSubview(backToStores)
        self.backToStores.layer.cornerRadius = self.backToStores.frame.size.width/2
        self.backToStores.layer.borderColor = UIColor(red: 160/255, green: 160/255, blue: 159/255, alpha: 1).cgColor
        self.backToStores.layer.borderWidth = 0.05
        self.backToStores.clipsToBounds = true
        
        
        // refence the nib cell
        let nib = UINib(nibName: "ProductViewCell", bundle: nil)
        productCollection.register(nib, forCellWithReuseIdentifier: "ProductCell")
        
        
        // create the users facebook profile picture if logged in
        if let user = FIRAuth.auth()?.currentUser {
            
            let photoUrl = user.photoURL
            
            let data = NSData(contentsOf: photoUrl!)
            self.profilePic.image = UIImage(data: data! as Data)
            
            self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width/2
            self.profilePic.layer.borderColor = UIColor(red: 160/255, green: 160/255, blue: 159/255, alpha: 1).cgColor
            self.profilePic.layer.borderWidth = 0.75
            self.profilePic.clipsToBounds = true
            
        } else {
            
            if FIRAuth.auth()?.currentUser == nil {
                
                self.profilePic.image = #imageLiteral(resourceName: "profileIconStore")
                self.profilePic.layer.borderWidth = 0
                
            }
        }
        
        
        // make the profile picture image a button
        profilePic.isUserInteractionEnabled = true
        
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(img:)))
        singleTap.numberOfTapsRequired = 1;
        profilePic.addGestureRecognizer(singleTap)
        
        // make bag a button
        
        bag.isUserInteractionEnabled = true
        
        let touch: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(bagTapped(img:)))
        touch.numberOfTapsRequired = 1;
        bag.addGestureRecognizer(touch)
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    func loadStore() {
        
        
        let shopifyURL = "https://\(self.store.APIToken!)@\(self.store.StoreDomain!).myshopify.com/admin/products.json?&limit=250"
        
        //fields=id,sku,images,title,vendor,variants,product_type,body_html,options,published_scope/"
    
        
        Alamofire.request(shopifyURL).responseJSON { (response) -> Void in
            
            // check if the result has a value
            
            if let value = response.result.value {
                
                
                let json = JSON(value)
                var x = [Product]()
                for test in json["products"] {
                    let product = Product(store: test.1)
                    x.append(product)
                    
                }
                
                self.products = x
                self.productCollection.reloadData()
                
                
                
               
            }
            
        }
    }
    
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteremItemForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        //let frame : CGRect = self.view.frame
        //let margin  = (frame.width - 90 * 3) / 6.0
        return UIEdgeInsetsMake(35, 0, 0, 0) // margin between cells
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: productCollection.frame.size.width/2.00534759, height: productCollection.frame.size.height/2.22333333)
   
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return products.count
        
        
    }
    
    // profile segue
    
    func imageTapped(img: AnyObject)
    {
        performSegue(withIdentifier: "showProfile", sender: nil)
    }
    
    
    // give bag a segue
    
    func bagTapped(img: AnyObject)
    {
        performSegue(withIdentifier: "showBag", sender: nil)
        
    }


    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell  {
       
        let cell = productCollection.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
        
       let url = NSURL(string: self.products[indexPath.row].image[0]!)
        cell.image.sd_setImage(with: url as URL!, placeholderImage: #imageLiteral(resourceName: "whiteSQR"), options: .refreshCached)
        cell.title.text = self.products[indexPath.row].title!
        cell.vendor.text = self.products[indexPath.row].vendor!
        cell.price.text = "$\(self.products[indexPath.row].price!)"
       // cell.vendor.text = self.products[indexPath.row].published_at
        
        
        
        return cell
      
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.5) {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            
        };
    }
    
    
    func removeAnimation()
    {
        
        let transitionOptions = UIViewAnimationOptions.curveEaseOut
        
       
        self.view.alpha = 1.0
        UIView.animate(withDuration: 0.25, delay: 0.25, options: transitionOptions, animations: {
        self.view.alpha = 0.0
      

        }) { _ in
            self.view.removeFromSuperview()
        }
        
        
    }
    



    @IBAction func backToStores(_ sender: Any) {
        
        
        removeAnimation()
        
             }
    


    
    // create the collection view vendor header

    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView: StoreHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! StoreHeaderCollectionReusableView
        
        if kind == UICollectionElementKindSectionHeader {
            
            
            headerView.backgroundColor = UIColor(hex: self.store.hex)
            
            headerView.logo.sd_setImage(with: URL(string: store.logoURL), placeholderImage: #imageLiteral(resourceName: "Placeholder"), options: .refreshCached)
            
        }
        
        return headerView
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProductView") as! ProductViewController
        vc.product = self.products[indexPath.row]
        vc.imageDisplay = self.store.imageDisplay
        vc.product.vendorID = self.store.key!
      
       
        self.navigationController?.pushViewController(vc, animated: false)
}

}




