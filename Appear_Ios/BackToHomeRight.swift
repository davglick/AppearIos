//
//  BackToHomeRight.swift
//  Appear_Ios
//
//  Created by Davin Glick on 7/11/16.
//  Copyright © 2016 Appear. All rights reserved.
//

import UIKit

class BackToHomeRight: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {

    private var presenting = true
    private var interactive = false
    private var enterPanGesture: UIScreenEdgePanGestureRecognizer!
    var sourceViewController: UIViewController! {
        didSet {
            self.enterPanGesture = UIScreenEdgePanGestureRecognizer()
            self.enterPanGesture.addTarget(self, action: #selector(handleOnstagePan))
            self.enterPanGesture.edges = UIRectEdge.left
            self.sourceViewController.view.addGestureRecognizer(self.enterPanGesture)
        }
    }
    
    // MARK: UIViewControllerAnimatedTransitioning protocol methods
    
    // animate a change from one viewcontroller to another
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        
        
        // get reference to our fromView, toView and the container view that we should perform the transition in
        let container = transitionContext.containerView
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        let screens : (from:UIViewController, to:UIViewController) = (transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!, transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!)
        
        // assign references to our menu view controller and the 'bottom' view controller from the tuple
        // remember that our menuViewController will alternate between the from and to view controller depending if we're presenting or dismissing
        let menuViewController = !self.presenting ? screens.from as! StoreProfile : screens.to as! StoreProfile
        let bottomViewController = !self.presenting ? screens.to as UIViewController : screens.from as UIViewController
        
        let menuView = menuViewController.view
        let bottomView = bottomViewController.view
        
        
        // add the both views to our view controller
        container.addSubview(toView)
        container.addSubview(fromView)
        
        // get the duration of the animation
        // DON'T just type '0.5s' -- the reason why won't make sense until the next post
        // but for now it's important to just follow this approach
        let duration = self.transitionDuration(using: transitionContext)
        
        if (self.presenting){
            
            // prepare menu to fade in
            menuView?.alpha = 0
            
        }
        
        if (self.presenting){
            // fade in
            menuView?.alpha = 1
            
            
            
        }
        else {
            // fade out
            menuView?.alpha = 0
            
            
        }
        
        // perform the animation!
        // for this example, just slid both fromView and toView to the left at the same time
        // meaning fromView is pushed off the screen and toView slides into view
        // we also use the block animation usingSpringWithDamping for a little bounce
        
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, animations: {
            
            
        }, completion: { finished in
            
            if(transitionContext.transitionWasCancelled){
                
                transitionContext.completeTransition(false)
                // bug: we have to manually add our 'to view' back http://openradar.appspot.com/radar?id=5320103646199808
                UIApplication.shared.keyWindow?.addSubview(screens.from.view)
                
            }
            else {
                
                transitionContext.completeTransition(true)
                // bug: we have to manually add our 'to view' back http://openradar.appspot.com/radar?id=5320103646199808
                UIApplication.shared.keyWindow?.addSubview(screens.to.view)
                
            }
            
        })
        
    }
    
    // return how many seconds the transiton animation will take
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.1
    }
    
    // MARK: UIViewControllerTransitioningDelegate protocol methods
    
    // return the animataor when presenting a viewcontroller
    // remmeber that an animator (or animation controller) is any object that aheres to the UIViewControllerAnimatedTransitioning protocol
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        // these methods are the perfect place to set our `presenting` flag to either true or false - voila!
        self.presenting = true
        return self
    }
    
    // return the animator used when dismissing from a viewcontroller
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = false
        return self
        
    }
    
    func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // if our interactive flag is true, return the transition manager object
        // otherwise return nil
        return self.interactive ? self : nil
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactive ? self : nil
    }
    
    func handleOnstagePan(pan: UIPanGestureRecognizer){
        
        print("swiped left")
        
        // how much distance have we panned in reference to the parent view?
        let translation = pan.translation(in: pan.view!)
        
        // do some math to translate this to a percentage based value
        let d =  translation.x / pan.view!.bounds.width * 0.2
        
        // now lets deal with different states that the gesture recognizer sends
        switch (pan.state) {
            
        case UIGestureRecognizerState.began:
            // set our interactive flag to true
            self.interactive = true
            
            // trigger the start of the transition
            self.sourceViewController.performSegue(withIdentifier: "presentProfile", sender: self)
            break
            
        case UIGestureRecognizerState.changed:
            
            // update progress of the transition
            self.update(d)
            break
            
        default: // .Ended, .Cancelled, .Failed ...
            
            // return flag to false and finish the transition
            self.interactive = false
            self.finish()
            
            if(d > 0.2){
                // threshold crossed: finish
                self.finish()
            }
            else {
                // threshold not met: cancel
                self.cancel()
            }
        }
    }
}

