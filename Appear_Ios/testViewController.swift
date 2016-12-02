//
//  testViewController.swift
//  Appear_Ios
//
//  Created by Davin Glick on 1/12/16.
//  Copyright © 2016 Appear. All rights reserved.
//

/*

import UIKit
import SDWebImage
import FirebaseAuth
import Firebase
import FBSDKLoginKit

//protocol SuperCartProtocol {
//    func getSuperCartCount(valueSent: String)
//}

class testViewController: UIViewController {
    
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
   // var delegate: SuperCartProtocol?
    var vendorID: String!
    var cartCount: Int?
    

    override func viewDidLoad() {
        super.viewDidLoad()

       
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createSuperCart(user: String) {
        self.ref.child("Supercarts").queryOrdered(byChild: "UID").queryEqualToValue(user).observeSingleEvent(of: .value, with: { (snapshot) in
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
            for item in snapshot.children{
                let data = (item as! FIRDataSnapshot).value! as! NSDictionary
                if(data["vendorID"] as? String == self.product.vendorID) {
                    self.cart = Cart(snapshot: snapshot.children.nextObject() as! FIRDataSnapshot)
                    exists = true
                }
            }
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
        self.ref.child("CartItems").queryOrderedByChild("cartToken").queryEqualToValue(self.cart?.cartToken!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            for item in snapshot.children{
                if(item.value["variantID"] as? String == self.product.option?.ID) {
                    let x = item as! FIRDataSnapshot
                    let quantity = Int(x.value!["quantity"] as! String)
                    self.product.quantity = quantity! + 1
                    let uid = x.key as String
                    self.ref.child("CartItems").child(uid).child("quantity").setValue(String(self.product.quantity))
                    exists = true
                }
            }
            if(exists == false){
                self.ref.child("CartItems").childByAutoId().setValue(["productID": "\(self.product.id!)", "imageURL": "\(self.product.image[0]!)", "title": "\(self.product.title!)", "vendor": "\(self.product.vendor!)", "vendorID": "\(self.product.vendorID!)", "price": "\(self.product.price!)", "quantity": "\(self.product.quantity)", "variantID": "\(self.product.option!.ID!)", "vairantTitle": "\(self.product.option!.title!)", "cartToken": "\(self.cart!.cartToken!)", "superCartToken": "\(self.supercart!.superCartID!)"])
            }
            self.ref.child("Carts").queryOrderedByChild("superCartToken").queryEqualToValue(self.supercart!.superCartID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                for item in snapshot.children{
                    let x = item as! FIRDataSnapshot
                    var subTotal: Float
                    var shippingTotal: Float
                    var total: Float
                    //a = Float(x.value!["cartSubTotal"] as! String)! + Float(self.product.price!)!
                    //b = a + Float(x.value!["cartShippingTotal"] as! String)!
                    if(x.value!["vendorID"] as? String == self.product.vendorID) {
                        let x = item as! FIRDataSnapshot
                        subTotal = Float(x.value!["cartSubTotal"] as! String)! + Float(self.product.price!)!
                        total = subTotal + Float(x.value!["cartShippingTotal"] as! String)!
                        let uid = x.key as String
                        var itemCount = Int(x.value!["itemCount"] as! String)
                        itemCount = itemCount! + 1
                        self.ref.child("Carts").child(uid).child("cartSubTotal").setValue(String(subTotal))
                        self.ref.child("Carts").child(uid).child("itemCount").setValue(String(itemCount!))
                        self.ref.child("Carts").child(uid).child("cartTotal").setValue(String(total))
                    }
                }
                self.ref.child("Supercarts").child(self.supercart!.superCartID!).observeSingleEventOfType(.Value, withBlock: { snapshot in
                    let st = Float(snapshot.value!["subTotal"] as! String)! + Float(self.product.price!)!
                    let t = Float(snapshot.value!["total"] as! String)! + Float(self.product.price!)!
                    let count = Int(snapshot.value!["productCount"] as! String)! + 1
                    self.ref.child("Supercarts").child(self.supercart!.superCartID!).child("productCount").setValue(String(count))
                    self.ref.child("Supercarts").child(self.supercart!.superCartID!).child("subTotal").setValue(String(st))
                    self.ref.child("Supercarts").child(self.supercart!.superCartID!).child("total").setValue(String(t))
                })
            })
        })
    }


   
}
 
 */
