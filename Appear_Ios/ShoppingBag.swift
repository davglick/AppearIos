//
//  ShoppingBag.swift
//  Appear_Ios
//
//  Created by Davin Glick on 2/11/16.
//  Copyright © 2016 Appear. All rights reserved.
//

import UIKit

class ShoppingBag: UIViewController {

    @IBOutlet var navbar: UINavigationBar!
    
    @IBOutlet var back: UIBarButtonItem!
    
    
    
    var ThescrollView: UIScrollView!

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        
        // make the nav bar transparent
       
        navbar.setBackgroundImage(UIImage(), for: .default)
        navbar.shadowImage = UIImage()
        self.navbar.backgroundColor = UIColor(red: 0.0, green: 0.3, blue: 0.5, alpha: 0.3)
        self.navbar.backgroundColor = .clear
        self.navbar.isTranslucent = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButton(_ sender: AnyObject) {
  
        let transition = CATransition()
        transition.duration = 0.1
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        transition.type = kCATransitionFade
        self.navigationController?.view.layer.add(transition, forKey: nil)
        _ = self.navigationController?.popToRootViewController(animated: false)
        
        
        
    }
 
    @IBAction func next(_ sender: Any) {
           
    }
}
