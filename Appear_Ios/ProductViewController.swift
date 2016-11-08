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


class ProductViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    var product:Product!
    var images = [UIImageView]()
    var valueFromProductZoom: NSIndexPath?
    var blur = UIVisualEffectView()
    var options = [Option]()
    var selectedRow: Int?
    var imageDisplay: String?
    let ref = FIRDatabase.database().reference()
    var vendorID: String!
    var cartCount: Int?

    @IBOutlet var productCollectionView: UICollectionView!
    @IBOutlet var pageControll: UIPageControl!
    @IBOutlet var AddToCart: UIButton!
    @IBOutlet var closeX: UIButton!
    
    
 

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "CustomproductView", bundle: nil)
        productCollectionView.register(nib, forCellWithReuseIdentifier: "CustomProduct")
        productCollectionView.backgroundColor = UIColor.white
        let x = UINib(nibName: "CustomSizeCell", bundle: nil)
        loadImages()
        productCollectionView.updateConstraints()
        
        
      
  
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = valueFromProductZoom {
            productCollectionView.scrollToItem(at: index as IndexPath, at: .centeredHorizontally, animated: false)
            pageControll.currentPage = index.row
            
              AddToCart.titleLabel!.font =  UIFont(name: "Montserrat-Regular", size: 20)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
 
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        pageControll.currentPage = Int(productCollectionView.contentOffset.x / pageWidth)
    }
    
    @IBAction func backButton(sender: AnyObject) {
        
        let transition = CATransition()
        transition.duration = 0.1
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        transition.type = kCATransitionFade
        self.navigationController?.view.layer.add(transition, forKey: nil)
        _ = self.navigationController?.popToRootViewController(animated: false)
        
        //navigationController?.popViewController(animated: true)
    }
    
    
    

}

