//
//  AppDelegate.swift
//  AutoTextFiledDemoGoogle
//
//  Created by apple on 11/23/19.
//  Copyright © 2019 Zerones. All rights reserved.
//

import UIKit
import GooglePlaces
let USERDEFAULT = UserDefaults.standard
let appDelegate : AppDelegate = AppDelegate.sharedAppDelegate()
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var locationManager : CLLocationManager!
    var currentLocation : CLLocation!
    var latitude : Double!
    var longitude : Double!
    var googleApiKey = "AIzaSyAs85RaUPwU0ahI-xEARVO1bz1Tvfn0xIU"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        GoogleApi.shared.initialiseWithKey("AIzaSyAs85RaUPwU0ahI-xEARVO1bz1Tvfn0xIU")
        DispatchQueue.main.async {
            self.getInitialLocation()
        }
        return true
    }
    
    func getInitialLocation()
    {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        locationManager.requestWhenInUseAuthorization()
        
        if !CLLocationManager.locationServicesEnabled() || CLLocationManager.authorizationStatus() == .denied
        {
            let alert = UIAlertController.init(title: "Location Services Disabled!", message: "Please enable Location Based Services for better results! We promise to keep your location private", preferredStyle: .alert)
            
            let ok = UIAlertAction.init(title: "Settings", style: .default)
            { (action) in
                if !CLLocationManager.locationServicesEnabled()
                {
                    self.openAppLocationSetting()
                }
                else
                {
                    self.openAppLocationSetting()
                }
            }
            
            let cancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(ok)
            alert.addAction(cancel)
            
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        else
        {
            locationManager.startUpdatingLocation()
        }
    }
    
    func stopUpdatingLiveLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func openAppLocationSetting()
    {
        UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        self.currentLocation = locations.last
        
        let latitude = String(self.currentLocation.coordinate.latitude)
        let longitude = String(self.currentLocation.coordinate.longitude)
        
        USERDEFAULT.set(latitude, forKey: "latitude")
        USERDEFAULT.set(longitude, forKey: "longitude")
        USERDEFAULT.synchronize()
    }
    
    func locationPermissionIsValid() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            }
        } else {
                return false
        }
    }
    
    class func sharedAppDelegate() -> AppDelegate
       {
           return UIApplication.shared.delegate as! AppDelegate
       }


}

