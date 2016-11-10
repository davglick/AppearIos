//
//  AddressMapView.swift
//  Appear_Ios
//
//  Created by Davin Glick on 6/11/16.
//  Copyright © 2016 Appear. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import GooglePlacePicker
import Firebase
import FirebaseAuth
import FirebaseDatabase
import AVFoundation


class AddressMapView: UIViewController,CLLocationManagerDelegate  {
    
    let locationManager = CLLocationManager()
    
    var soundEffect = AVAudioPlayer()
    
    var googleMapView: GMSMapView!
    
    @IBOutlet var mapView: GMSMapView!
    
    @IBOutlet var addButton: UIButton!
    
    @IBOutlet var addAddressView: UIView!
    
    @IBOutlet var addressLabel: UILabel!
    
    @IBOutlet var removeViewX: UIButton!
    
    var selectedAddress = String()
    var GeoCoordinate = String()
    
    var addresses = [addAddress]()
    
    
    
    
    var DBref: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
        
    }
    
    
    @IBAction func closeX(_ sender: Any) {
        
        self.view.removeFromSuperview()
        
    }
    
    
    // Present the Autocomplete view controller when the button is pressed.
    @IBAction func autocompleteClicked(_ sender: AnyObject) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        self.present(autocompleteController, animated: true, completion: nil)
        let filter = GMSAutocompleteFilter()
        filter.country = "AU"
        autocompleteController.autocompleteFilter = filter
    }
    
}

extension AddressMapView: GMSAutocompleteViewControllerDelegate {
    
    
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        
        let name: String = place.name
        let address: String = place.formattedAddress!
        let SelectedAddress: String = place.formattedAddress!
        let geoLocation = place.coordinate
        
        
        
        print("Place name: ", place.name)
        print("Place address: ", place.formattedAddress)
        print("Place attributions: ", place.attributions)
        print("Place Co-Ordinates: ", place.coordinate)
        self.dismiss(animated: true, completion: nil)
        mapView.clear()
        // Print a google marker in the selected location
        
        self.addressLabel.text = address
        self.selectedAddress = SelectedAddress
        self.GeoCoordinate =  "\(geoLocation)"
        
        let position = place.coordinate
        let marker = GMSMarker(position: position)
        marker.title = place.formattedAddress
        marker.map = mapView
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.icon = UIImage(named: "Marker")
        marker.map = mapView
        
        
        
        mapView.animate(toLocation: place.coordinate)
        mapView.animate(toZoom: 12)
        
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        //print("Error: ", error.description)
        
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
    }
    
    
    //  This is the extention code for getting the users location
    
    @objc(locationManager:didChangeAuthorizationStatus:) func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            
            locationManager.startUpdatingLocation()
            
            
            
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 17, bearing: 0, viewingAngle: 0)
            
            locationManager.stopUpdatingLocation()
        }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        // Navigation Controller Design
        
        
        
        self.addButton.layer.cornerRadius = self.addButton.frame.size.width/2
        self.addButton.layer.borderColor = UIColor(red: 160/255, green: 160/255, blue: 159/255, alpha: 1).cgColor
        self.addButton.layer.borderWidth = 0.05
        self.addButton.clipsToBounds = true
        
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.shadowOffset = CGSize(width: 0, height: 3.0)
        addButton.layer.masksToBounds = false
        
        addButton.layer.shadowRadius = 0.5
        addButton.layer.shadowOpacity = 0.5
        
        
        self.view.addSubview(addButton)
        
        
        // add address view set up
        
        self.addAddressView.layer.cornerRadius = 5
        self.addAddressView.backgroundColor = UIColor(colorLiteralRed: 250/255, green: 255/255, blue: 250/250, alpha: 0.95)
        self.addAddressView.layer.borderWidth = 1
        self.addAddressView.layer.borderColor = UIColor(red:222/255.0, green:225/255.0, blue:227/255.0, alpha: 1.0).cgColor
        
        
        
        self.view.addSubview(addAddressView)
        
        
    }
    
    
    
    @IBAction func dismissSecondVC(_ sender: AnyObject) {


        if let user = FIRAuth.auth()?.currentUser {
    
            // DBref = FIRDatabase.database().reference()
            
            
            let address: String!
            if addressLabel.text == "Add a delivery address" {
                addressLabel.text = "no address"
                address = addressLabel.text
                
            } else {
                
                address = addressLabel.text
            }
            
            if case let addressLabel.text! = "no address" {
                
                print ("error")
                
            } else {
            
            let geoLocation: String!
            if  GeoCoordinate == "" {
                GeoCoordinate = "No GeoCoOrdiante"
                geoLocation = GeoCoordinate
            } else {
                
                geoLocation = GeoCoordinate
            }

            
            let uid = user.uid
            
            // Create add address ref in firebase
            let addRef = DBref.child("Delivery-Address").child(uid)
            let AddNewAddress = addAddress(addressName: address, DefaultAddress: "false", number: "0", GeoLocation: GeoCoordinate)
            
            addRef.childByAutoId().setValue(AddNewAddress.toAnyObject())
         

            // Trigger sound effect when the add address button is pressed
            
            let alertSound = Bundle.main.path(forResource: "Pop", ofType: "mp3")
            
            if let alertSound = alertSound {
                
                let alertSoundURL = NSURL(fileURLWithPath: alertSound)
                
                do{
                    
                    try soundEffect = AVAudioPlayer(contentsOf: alertSoundURL as URL)
                    
                    soundEffect.play()
                    
                } catch {
                    
                    print("error")
                }
            }
            
               self.view.removeFromSuperview()

            }

        }
        
    
    func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
    }

    
   }

}
