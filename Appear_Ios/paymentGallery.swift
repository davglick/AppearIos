//
//  paymentGallery.swift
//  Appear_Ios
//
//  Created by Davin Glick on 28/11/16.
//  Copyright © 2016 Appear. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import AVFoundation


class paymentGallery: UIViewController {
    
    @IBOutlet var creditCardGallery: UITableView!

    @IBOutlet var addCard: UIButton!
    
    @IBOutlet var paymentGallery: UIView!
    
    @IBOutlet var close: UIButton!
    
    var gravity: UIGravityBehavior!
    var animator: UIDynamicAnimator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // give background an opacity 
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        // Make add button rounded 
        
        
        self.addCard.layer.cornerRadius = self.addCard.frame.size.width/2
        self.addCard.layer.borderColor = UIColor(red: 160/255, green: 160/255, blue: 159/255, alpha: 1).cgColor
        self.addCard.layer.borderWidth = 0.05
        self.addCard.clipsToBounds = true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func animateOut () {
        
        UIView.animate(withDuration: 0.5, animations: {
            //self.view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0
            
            self.animator = UIDynamicAnimator(referenceView: self.paymentGallery)
            self.gravity = UIGravityBehavior(items: [self.paymentGallery])
            self.animator.addBehavior(self.gravity)
            
        }) { (success: Bool) in
            self.paymentGallery.removeFromSuperview()
            
        }
        
    }

   
    @IBAction func paymentGallery(_ sender: Any) {
        
        animateOut()
        
    }


}
