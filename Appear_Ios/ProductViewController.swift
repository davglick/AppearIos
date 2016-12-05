//
//  ProductViewController.swift
//  Appear_Ios
//
//  Created by Davin Glick on 8/11/16.
//  Copyright © 2016 Appear. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseAuth
import Firebase
import FBSDKLoginKit
import Hex



protocol SuperCartProtocol {
    func getSuperCartCount(valueSent: String)
    
}


// Convert to html to string


extension String {
    var html2AttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

class ProductViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, UITableViewDataSource,
UITableViewDelegate {
    
    var product:Product!
    var images = [UIImageView]()
    var valueFromProductZoom: NSIndexPath?
    var blur = UIVisualEffectView()
    var options = [Option]()
    var selectedRow: Int?
    var imageDisplay: String?
    let ref = FIRDatabase.database().reference()
    var supercart: SuperCart?
    var cart: Cart?
    var delegate: SuperCartProtocol?
    var vendorID: String!
    var cartCount: Int?
    
    
    @IBOutlet var productCollectionView: UICollectionView!
    @IBOutlet var pageControll: UIPageControl!
    @IBOutlet var AddToCart: UIButton!
    @IBOutlet var closeX: UIButton!
    @IBOutlet var infoView: UIView!
    @IBOutlet var blurEffect: UIVisualEffectView!
    
    // Info pop up outlets
    @IBOutlet var infoDesigner: UILabel!
    @IBOutlet var infoTitle: UILabel!
    @IBOutlet var infoPrice: UILabel!
    @IBOutlet var infoDescription: UITextView!
    
    
    // Size pop up outlets
    @IBOutlet var sizeView: UIView!
    @IBOutlet var sizeList: UITableView!
 
    var effect:UIVisualEffect!
    
    
    @IBAction func addToCartButton(sender: AnyObject) {
        var sizeExists = false
        for x in self.options {
            if(x.selected == true) {
                sizeExists = true
            }
        }
        if(sizeExists == false) {
            
            animateSize()
            
          //  self.blur.isHidden = false
          //  self.infoView.isHidden = true
          //  self.sizeView.isHidden = false
        }
        else{
            if(self.cartCount == nil) {
                print("cartcount nil")
                self.cartCount = 1
                self.delegate?.getSuperCartCount(valueSent: String(self.cartCount!))
            }
            else{
                self.delegate?.getSuperCartCount(valueSent: String(self.cartCount! + 1))
            }
            FIRAuth.auth()?.addStateDidChangeListener { auth, user in
                if user != nil {
                    let x = user?.uid
                    self.createSuperCart()
                    self.navigationController?.popViewController(animated: true)
                    //self.createCart()
                    //self.addLineItem()
                } else {
                    // No user is signed in.
                    print("no user is signed in")
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let loginRegisterVC = storyboard.instantiateViewController(withIdentifier: "FacebookLogin") as! FacebookLoginPopUp
                   // loginRegisterVC.cameFromStore = true
                    
                    self.navigationController?.pushViewController(loginRegisterVC, animated: false)
                }
            }
        }
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Create swipe gesture recogniser
        
        
        var DownSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
        
        
        DownSwipe.direction = .down
        
        
        view.addGestureRecognizer(DownSwipe)
        
        
        // Refence classes, functions and nib files
        
        let nib = UINib(nibName: "CustomproductView", bundle: nil)
        productCollectionView.register(nib, forCellWithReuseIdentifier: "CustomProduct")
        productCollectionView.backgroundColor = UIColor.white
        let x = UINib(nibName: "CustomSizeCell", bundle: nil)
        sizeList.register(x, forCellReuseIdentifier: "SizeCell")
        loadImages()
        initInfoView()
        initSizeView()
        getSizes()
        
        productCollectionView.updateConstraints()
        
        
        // hide blur effect 
        
       effect = blurEffect.effect
        blurEffect.effect = nil
        
        
        // design info view
        infoView.layer.cornerRadius = 5
        self.infoView.layer.borderWidth = 0.25
        self.infoView.layer.borderColor = UIColor(red: 28/255.0, green:29/255.0, blue:31/255.0, alpha: 0.15).cgColor
 
        
        // design size view 
        
        sizeView.layer.cornerRadius = 5
        self.sizeView.layer.borderWidth = 0.25
        self.sizeView.layer.borderColor = UIColor(red: 28/255.0, green:29/255.0, blue:31/255.0, alpha: 0.15).cgColor
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = valueFromProductZoom {
            productCollectionView.scrollToItem(at: index as IndexPath, at: .centeredHorizontally, animated: false)
            pageControll.currentPage = index.row
            
              AddToCart.titleLabel!.font =  UIFont(name: "Montserrat-Regular", size: 20)
        }
    }
    
   

    
    // Create user supercart
    
    func createSuperCart() {
        
        if let user = FIRAuth.auth()?.currentUser {
            
            let uid = user.uid
            
            self.ref.child("Supercarts").observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                if snapshot.hasChild(uid.self){
                    
                    print("Cart does exist")
                    
                }else{
                    
                    print("cart doesn't exist")
                    self.supercart = SuperCart()
                    self.supercart!.superCartID = NSUUID().uuidString
                    self.supercart!.productCount = 0
                    self.supercart!.subTotal = 0
                    self.supercart!.shippingTotal = 0
                    self.supercart!.total = 0
                    self.supercart!.completed = false
                    self.ref.child("Supercarts").child(uid).setValue(["cartID": "\(self.supercart!.superCartID!)", "subTotal": "\(self.supercart!.subTotal!)", "shippingTotal": "\(self.supercart!.shippingTotal!)", "total": "\(self.supercart!.total!)", "productCount": "\(self.supercart!.productCount!)"])
                }
                
                self.createCart()
            })
        }
        
    }

    func createCart() {
        
        if let user = FIRAuth.auth()?.currentUser {
            
        let uid = user.uid

        self.ref.child("Carts").queryOrdered(byChild: "superCartToken").queryEqual(toValue: uid.self).observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
            for snap in snapshots {
                if let doing = snap.value as? Dictionary<String, AnyObject> {
                    if(doing["vendorID"] as? String == self.product.vendorID) {
                        self.cart = Cart(snapshot: snapshot.children.nextObject() as! FIRDataSnapshot)
                 
            print(snapshot.value)
                    print("Exists")
                
           } else {

            /*
                self.cart = Cart()
                self.cart!.superCartToken = uid
                self.cart!.cartToken = NSUUID().uuidString
                self.cart!.cartId = NSUUID().uuidString
                self.cart!.vendorID = self.product.vendorID
                self.cart!.timestampCreated = "\(NSDate())"
                self.ref.child("Carts").child(self.cart!.cartToken!).setValue(["superCartToken": "\(self.cart!.superCartToken!)","vendorID": "\(self.cart!.vendorID!)", "cartId": "\(self.cart!.cartId!)","timestampCreated": "\(self.cart!.timestampCreated!)", "itemCount": "\(self.cart!.itemCount)", "cartSubTotal": "\(self.cart!.cartSubTotal)", "cartShippingTotal": "\(self.cart!.cartShippingTotal)", "cartTotal": "\(self.cart!.cartTotal)"])
 
 */
                    print("Nul")
                    
        }
        }
        }
        }
        })
        }
    }
    
/*
            }
        })
    }
}
*/
            /*
            
            self.ref.child("Supercarts").queryOrdered(byChild: user.uid).queryEqual(toValue: uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if(snapshot.exists()) {
                
                    print("Yes")
                    print(snapshot.value)
                
                } else {
                    
                    
                    print("Nul")
            */
            /*
            self.supercart = SuperCart()
            self.supercart!.superCartID = uid
            self.supercart!.productCount = 0
            self.supercart!.subTotal = 0
            self.supercart!.shippingTotal = 0
            self.supercart!.total = 0
            self.supercart!.completed = false
            self.ref.child("Supercarts").child(uid).setValue(["UID": "\(self.supercart!.superCartID!)", "subTotal": "\(self.supercart!.subTotal!)", "shippingTotal": "\(self.supercart!.shippingTotal!)", "total": "\(self.supercart!.total!)", "productCount": "\(self.supercart!.productCount!)"])
            */
                    
    
 

    
        /*
        self.ref.child("Supercarts").queryOrdered(byChild: "UID").queryEqual(toValue: user).observeSingleEvent(of: .value, with: { (snapshot) in
            if(snapshot.exists()) {
               // self.supercart = SuperCart(snapshot: snapshot.children.nextObject() as? FIRDataSnapshot)
                
                print("value exists")
            }
            else{
                
                
                self.supercart = SuperCart()
                self.supercart!.superCartID = NSUUID().uuidString
                self.supercart!.userID = user
                self.supercart!.productCount = 0
                self.supercart!.subTotal = 0
                self.supercart!.shippingTotal = 0
                self.supercart!.total = 0
                self.supercart!.completed = false
                self.ref.child("Supercarts").child(self.supercart!.superCartID!).setValue(["UID": "\(self.supercart!.userID!)", "subTotal": "\(self.supercart!.subTotal!)", "shippingTotal": "\(self.supercart!.shippingTotal!)", "total": "\(self.supercart!.total!)", "productCount": "\(self.supercart!.productCount!)"])
            }
           
        })
 

        
    }

 */
  
    
            /*
            if let snapDict = snapshot.value as? [String:AnyObject]{
                for child in snapDict{
                if(child.value["vendorID"] as? String == self.product.vendorID) {
                    self.cart = Cart(snapshot: snapshot.children.nextObject() as! FIRDataSnapshot)
                    exists = true
                    
                    print("Exists")
                    
            }
        
        }
                
            } else {
                self.cart = Cart()
                self.cart!.cartToken = NSUUID().uuidString
                self.cart!.superCartToken = self.supercart?.superCartID
                self.cart!.vendorID = self.product.vendorID
                self.cart!.timestampCreated = "\(NSDate())"
                self.ref.child("Carts").child(self.cart!.cartToken!).setValue(["superCartToken": "\(self.cart!.superCartToken!)", "vendorID": "\(self.cart!.vendorID!)", "timestampCreated": "\(self.cart!.timestampCreated!)", "itemCount": "\(self.cart!.itemCount)", "cartSubTotal": "\(self.cart!.cartSubTotal)", "cartShippingTotal": "\(self.cart!.cartShippingTotal)", "cartTotal": "\(self.cart!.cartTotal)"])
                
     
            }
            
        })
    }

           */
                
    
    /*
    
    // Create supercart, shopping cart, line items in cart 
    
    func createSuperCart(user: String) {
        self.ref.child("Supercarts").queryOrdered(byChild: "UID").queryEqual(toValue: user).observeSingleEvent(of: .value, with: { (snapshot) in
            if(snapshot.exists()) {
                self.supercart = SuperCart(snapshot: snapshot.children.nextObject() as? FIRDataSnapshot)
            }
            else{
                self.supercart = SuperCart()
                self.supercart!.superCartID = NSUUID().uuidString
                self.supercart!.userID = user
                self.supercart!.productCount = 0
                self.supercart!.subTotal = 0
                self.supercart!.shippingTotal = 0
                self.supercart!.total = 0
                self.supercart!.completed = false
                self.ref.child("Supercarts").child(self.supercart!.superCartID!).setValue(["UID": "\(self.supercart!.userID!)", "subTotal": "\(self.supercart!.subTotal!)", "shippingTotal": "\(self.supercart!.shippingTotal!)", "total": "\(self.supercart!.total!)", "productCount": "\(self.supercart!.productCount!)"])
            }
            self.createCart()
        })
    }
    func createCart() {
        var exists = false
        self.ref.child("Carts").queryOrdered(byChild: "superCartToken").queryEqual(toValue: self.supercart!.superCartID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapDict = snapshot.value as? [String:AnyObject]{
                for item in snapDict{
                if(data.value["vendorID"] as? String == self.product.vendorID) {
                    self.cart = Cart(snapshot: snapshot.children.nextObject() as! FIRDataSnapshot)
                    exists = true
                    }
                }
            }
           // for item in snapshot.children {
                
              
               // if(item.value["vendorID"] as? String == self.product.vendorID) {
                //    self.cart = Cart(snapshot: snapshot.children.nextObject() as! FIRDataSnapshot)
               //     exists = true
          //  }
        
            if(exists == false) {
                self.cart = Cart()
                self.cart!.cartToken = NSUUID().uuidString
                self.cart!.superCartToken = self.supercart?.superCartID
                self.cart!.vendorID = self.product.vendorID
                self.cart!.timestampCreated = "\(NSDate())"
                self.ref.child("Carts").child(self.cart!.cartToken!).setValue(["superCartToken": "\(self.cart!.superCartToken!)", "vendorID": "\(self.cart!.vendorID!)", "timestampCreated": "\(self.cart!.timestampCreated!)", "itemCount": "\(self.cart!.itemCount)", "cartSubTotal": "\(self.cart!.cartSubTotal)", "cartShippingTotal": "\(self.cart!.cartShippingTotal)", "cartTotal": "\(self.cart!.cartTotal)"])
            }
            self.addLineItem()
        })
    }
    
    func addLineItem() {
        var exists = false
        self.product.quantity += 1
        for option in self.options{
            if(option.selected == true) {
                self.product.option = option
            }
        }
        self.ref.child("CartItems").queryOrdered(byChild: "cartToken").queryEqual(toValue: self.cart?.cartToken!).observeSingleEvent(of: .value, with: { (snapshot) in
           // for item in snapshot.children{
               // let data = (item as! FIRDataSnapshot).value! as! NSDictionary
                if let snapDict = snapshot.value as? [String:AnyObject]{
                    for item in snapDict{
                        
                if(item.value["variantID"] as? String == self.product.option?.ID) {
                  //  let x = item as! FIRDataSnapshot
                    let quantity = Int((item.value["quantity"] as? String)!)
                    self.product.quantity = quantity! + 1
                    let uid = item.key as String
                    self.ref.child("CartItems").child(uid).child("quantity").setValue(String(self.product.quantity))
                    exists = true
                        }
                }
            }
            if(exists == false){
                self.ref.child("CartItems").childByAutoId().setValue(["productID": "\(self.product.id!)", "imageURL": "\(self.product.image[0]!)", "title": "\(self.product.title!)", "vendor": "\(self.product.vendor!)", "vendorID": "\(self.product.vendorID!)", "price": "\(self.product.price!)", "quantity": "\(self.product.quantity)", "variantID": "\(self.product.option!.ID!)", "vairantTitle": "\(self.product.option!.title!)", "cartToken": "\(self.cart!.cartToken!)", "superCartToken": "\(self.supercart!.superCartID!)"])
            }
            self.ref.child("Carts").queryOrdered(byChild: "superCartToken").queryEqual(toValue: self.supercart!.superCartID).observeSingleEvent(of: .value, with: { (snapshot) in
})
 })
        
    }
    */


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func animateInfoIn() {
        
        self.view.addSubview(infoView)
        infoView.center = self.view.center
        
        infoView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        infoView.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            self.blurEffect.effect = self.effect
            self.infoView.alpha = 1
            self.infoView.transform = CGAffineTransform.identity
            
            
        }
        
        
        
    }
    
    func animateSize() {
        
        self.view.addSubview(sizeView)
        sizeView.center = self.view.center
        
        sizeView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        sizeView.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            self.blurEffect.effect = self.effect
            self.sizeView.alpha = 1
            self.sizeView.transform = CGAffineTransform.identity
            
            
        }
        
        
        
    }

    
    func animateInfoOut() {
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.infoView.transform = CGAffineTransform.init(translationX: 1.3, y: 1.3)
            self.infoView.alpha = 0
            
            self.blurEffect.effect = nil
            
            
        }) { (success: Bool) in
            self.infoView.removeFromSuperview()
            
            
        }
      
    }
    
    
    func animateSizeOut() {
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.sizeView.transform = CGAffineTransform.init(translationX: 1.3, y: 1.3)
            self.sizeView.alpha = 0
            
            self.blurEffect.effect = nil
            
            
        }) { (success: Bool) in
            self.sizeView.removeFromSuperview()
            
            
        }
        
    }

    
    // initiate info view
    
    func initInfoView() {

        self.infoDesigner.text = self.product.vendor?.capitalized
        self.infoTitle.text = self.product.title
        self.infoPrice.text = ("$\(self.product.price!)")
        self.infoDescription.font = UIFont.init(name: "MavenProRegular", size: 12)
        self.infoDescription.attributedText = self.product.body_html!.html2AttributedString
        self.infoDescription.textColor = UIColor(colorLiteralRed: 163/255, green: 167/255, blue: 182/255, alpha: 1)
        self.infoDescription.textAlignment = NSTextAlignment.left
        self.infoDescription.flashScrollIndicators()
        
        
    }
    
    // initiate size view
    
    func initSizeView() {
        
        
        self.sizeList.backgroundColor = UIColor.white
        self.sizeList.layer.borderColor = UIColor.clear.cgColor
        self.sizeList.separatorStyle = .none
        self.sizeList.allowsSelection = true
        //self.sizeList.allowsMultipleSelection = false
    }
    
    
    // handle the user swipe right to remove the view
    
    func handleSwipeDown(sender: UISwipeGestureRecognizer) {
        
        if (sender.direction == .down) {
            
            
            let transition = CATransition()
            transition.duration = 0.25
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            transition.type = kCATransition
            transition.subtype = kCATransitionFromBottom
            self.navigationController?.view.layer.add(transition, forKey: nil)
            _ = self.navigationController?.popToRootViewController(animated: false)
            
            
            print("down")
            
        }
        
        
        
    }


    // load product images
 
        func loadImages() {
            var x = [UIImageView]()
            for string in self.product.image {
                let url: NSURL = NSURL(string: string!)!
                let image = UIImageView()
                image.sd_setImage(with: url as URL!, placeholderImage: #imageLiteral(resourceName: "whiteSQR"), options: .refreshCached)
             
                
                x.append(image)
            }
            
            
            self.images = x
            self.pageControll.numberOfPages = self.images.count
            self.productCollectionView.reloadData()
            }
    
    
    // create super cart - cart and line items in cart 

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: productCollectionView.frame.width, height: productCollectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CustomProductCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomProduct", for: indexPath as IndexPath) as! CustomProductCollectionViewCell
        //cell.frame.size = CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        if(self.imageDisplay == "fill") {
            cell.productImage.contentMode = UIViewContentMode.scaleAspectFill
        }
        else if(self.imageDisplay == "fit") {
            cell.productImage.contentMode = UIViewContentMode.scaleAspectFit
        }
        cell.productImage.image = self.images[indexPath.row].image
        

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
   print("Doing")
        
  
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        pageControll.currentPage = Int(productCollectionView.contentOffset.x / pageWidth)
    }
    

    
    func getSizes() {
        var x = [Option]()
        for variant in (product.variants!.array)! {
            let option = Option(t: variant["title"].string!.uppercased(), count: variant["inventory_quantity"].int!, i: String(describing: variant["id"]))
            x.append(option)
        }
        self.options = x
        DispatchQueue.main.async {
            self.sizeList.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return self.options.count
   
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for x in self.options {
            x.selected = false
        }
        self.options[indexPath.row].selected = true
        self.sizeList.reloadData()
        
        print("doing")
        //let cells = self.sizeList.visibleCells as! [CustomSizeCell]
        //cells[indexPath.row].background.backgroundColor = UIColor.blackColor()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CustomSizeCell = self.sizeList.dequeueReusableCell(withIdentifier: "SizeCell") as! CustomSizeCell
        //cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.size.text = self.options[indexPath.row].title
        if(self.options[indexPath.row].inventoryCount  == 0) {
            cell.isUserInteractionEnabled = false
            cell.background.backgroundColor = UIColor(hex: "#f2f2f2")
            cell.size.textColor = UIColor(hex: "#cccccc")
            cell.stock.text = "out of stock"
            cell.stock.textColor = UIColor(hex: "#cccccc")
        }
        else{
            cell.isUserInteractionEnabled = true
            cell.stock.text = ""
            if(self.options[indexPath.row].selected == true) {
                print("true")
                cell.background.backgroundColor = UIColor.black
                cell.size.textColor = UIColor.white
            }
            else{
                cell.background.backgroundColor = UIColor(hex: "#F2F2F2")
                cell.size.textColor = UIColor(hex: "#404040")
            }
        }
        cell.background.layer.masksToBounds = true
        cell.background.layer.borderWidth = 0.05
        
        return cell
    }

    
    // Go back to store profile

    @IBAction func backButton(sender: AnyObject) {
        
        let transition = CATransition()
        transition.duration = 0.1
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        transition.type = kCATransitionFade
        self.navigationController?.view.layer.add(transition, forKey: nil)
        _ = self.navigationController?.popToRootViewController(animated: false)
        
        
    }
    
    
    
    // open info view
    
    @IBAction func infoButton(_ sender: Any) {
        
        
        animateInfoIn()
        
    }
    
    // close info view
  
    @IBAction func closeInfo(_ sender: Any) {
        
        
        animateInfoOut()
        animateSizeOut()
        
    }
    
    // open size view
    
    @IBAction func sizeButton(_ sender: Any) {
        
        animateSize()
    }

    // close size view 
    
    
    @IBAction func closeSize(_ sender: Any) {
        
        animateSizeOut()
        animateInfoOut()
      
            }
                
            
    }



