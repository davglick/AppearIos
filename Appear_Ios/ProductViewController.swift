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

class ProductViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate {
    
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
 

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
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
            cell.background.backgroundColor = UIColor(hex: "#fff2f2")
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
        cell.background.layer.borderWidth = 0.3
        
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

