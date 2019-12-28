//
//  LocationManager.swift
//  Intrigued
//
//  Created by daniel helled on 29/09/17.
//  Copyright © 2017 daniel helled. All rights reserved.
//

import UIKit
import CoreLocation
import SVGeocoder

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    static let sharedInstance = LocationManager()
    
    
    private override init() {
        super.init()
         isAuthorizedtoGetUserLocation()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            
        }
    }
    func startUpdatingLocation() {
        print("Starting Location Updates")
     
        self.locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation()
    {
        print("Stop Location Updates")
        self.locationManager.stopUpdatingLocation()
        
    }
    
    //if we have no permission to access user location, then ask user for permission.
    func isAuthorizedtoGetUserLocation() {
        
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse     {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    
    //this method will be called each time when a user change his location access preference.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            print("User allowed us to access location")
            //do whatever init activities here.
        }
    }
    
    
    //this method is called by the framework on         locationManager.requestLocation();
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Did location updates is called")
        guard let newLocation = locations.last else {return}
        APPDELEGATE.currentAddress = ""
        let coord = newLocation.coordinate
        print(coord.latitude)
        print(coord.longitude)
        APPDELEGATE.currectLatitude =  String(coord.latitude)
        APPDELEGATE.currentLongitude = String(coord.longitude)
        
        CLGeocoder().reverseGeocodeLocation(newLocation, completionHandler: { (placemarks, error) -> Void in
            var addressString : String = ""
            // Place details
            var placemark: CLPlacemark!
            placemark = placemarks?[0]
            
            if placemark == nil {
                return
            }
            if placemark.subThoroughfare != nil {
                addressString = placemark.subThoroughfare! + " "
            }
            if placemark.thoroughfare != nil {
                addressString = addressString + placemark.thoroughfare! + ", "
            }
            if placemark.postalCode != nil {
                addressString = addressString + placemark.postalCode! + " "
            }
            if placemark.locality != nil {
                addressString = addressString + placemark.locality! + ", "
            }
            if placemark.administrativeArea != nil {
                addressString = addressString + placemark.administrativeArea! + " "
            }
            if placemark.country != nil {
                addressString = addressString + placemark.country!
            }
             APPDELEGATE.currentAddress = addressString
        
              self.stopUpdatingLocation()
        })
        
//        SVGeocoder.reverseGeocode(newLocation.coordinate, completion:{(placemarks, urlResponse, error: Error?) -> Void in
//
//            if (error != nil){
//                print("ERROR =======", error?.localizedDescription as Any)
//                return
//                
//            }
//
//            if placemarks == nil
//            {return}
//
//            if (placemarks?.count !=  nil)
//            {
//                do
//                {
//                    // self.address = try UBRAddress(dictionary: [NSObject : AnyObject]())
//                }
//
//                print("urlResponse",urlResponse ?? "")
//                let array: NSArray  = placemarks as AnyObject as! NSArray
//
//                if (array.count != 0)
//                {
//                    let mark: SVPlacemark = array[0] as! SVPlacemark
//                    APPDELEGATE.currentLocationSVplacemark = mark
//                }
//            }
//        })
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Did location updates is called but failed getting location \(error)")
    }
    //********************************* Location Stuff *************************************
    
    
}
