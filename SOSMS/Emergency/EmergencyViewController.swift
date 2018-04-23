//
//  EmergencyViewController.swift
//  SOSMS
//
//  Created by SAP008 on 2018-02-11.
//  Copyright © 2018 jasap. All rights reserved.
//

import UIKit
import CoreLocation

class EmergencyViewController: UIViewController, EmergencyServiceDelegate, CLLocationManagerDelegate {
    
    // Controller Variables
    var emergencyService = EmergencyService()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var locationManager: CLLocationManager = CLLocationManager()
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    // Storyboard Variables
    @IBOutlet weak var stateVariable: UILabel!
    
    // Storyboard Methods
    @IBAction func emergencyButtonPressed(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: "switchOn") {
            insideFalseAlarm()
        } else {
            countdownHandler()
        }
    }
    
    @IBAction func emergencyTouchOutside(_ sender: CustomButton) {
        if UserDefaults.standard.bool(forKey: "switchOn") {
            countdownHandler()
        } else {
            outsideFalseAlarm()
        }
    }

    // MARK: - Emergency Service Delegate
    func sentSMS() {
        // turn off activity indicator and turn on interactions
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        openSentAlert()
        if var historyArray = UserDefaults.standard.array(forKey: "history") as? [Date] {
            historyArray.append(Date())
            UserDefaults.standard.set(historyArray, forKey: "history")
            
        }
    }
    
    func errorWithMessage(message: String) {
        
        // turn off activity indicator and turn on interactions
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    // Helper Functions
    func countdownHandler() {
        guard let contactsArray = UserDefaults.standard.array(forKey: "contacts") else {
            errorWithMessage(message: "Error getting contacts")
            return
        }
        if contactsArray.count == 0 {
            errorWithMessage(message: "No contacts")
        } else {
            let pinTime =  UserDefaults.standard.integer(forKey: "timer")
            
            if pinTime == 0 {
                callSMSService()
            } else {
                performSegue(withIdentifier: "mustDeactivate", sender: self)
            }
        }

    }
    
    func callSMSService() {
        if let contactsArray = UserDefaults.standard.array(forKey: "contacts") {
            if contactsArray.count != 0 {
                // Change UI to stop interaction
                activityIndicator.center = self.view.center
                activityIndicator.hidesWhenStopped = true
                activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
                view.addSubview(activityIndicator)
                activityIndicator.startAnimating()
                UIApplication.shared.beginIgnoringInteractionEvents()
                
                // Send to Login Service
                emergencyService.sendSMS(location: getCoords())
            } else {
                errorWithMessage(message: "No contacts")
            }
            
        } else {
            errorWithMessage(message: "Error getting contacts")
        }
        
        
    }
    
    func openSentAlert() {
        let alert = UIAlertController(title: "Alert", message: "Message sent to contacts.", preferredStyle: UIAlertControllerStyle.alert)
        let cancel = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func insideFalseAlarm() {
        let alert = UIAlertController(title: "False Alarm", message: "Must release outside of button to send.", preferredStyle: UIAlertControllerStyle.alert)
        let cancel = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func outsideFalseAlarm() {
        let alert = UIAlertController(title: "False Alarm", message: "Must release inside of button to send.", preferredStyle: UIAlertControllerStyle.alert)
        let cancel = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func viewSetup() {
        if (UserDefaults.standard.bool(forKey: "authorizedToGetLocation")) {
            StartupdateLocation()
            print("triggered update")
        }
        if UserDefaults.standard.bool(forKey: "switchOn") {
            stateVariable.text = "Push and slide outside to send."
            stateVariable.textColor = UIColor(red: 215/255.0, green: 64/255.0, blue: 57/255.0, alpha: 1.0)
        } else {
            stateVariable.text = "Push button to send request"
            stateVariable.textColor = UIColor(red: 215/255.0, green: 64/255.0, blue: 57/255.0, alpha: 1.0)
        }
    }
    
    @objc func willEnterForeground() {
        viewSetup()
    }
    
    // Standard Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        EmergencyDataManager.shared.firstVC = self
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        self.emergencyService.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (UserDefaults.standard.bool(forKey: "authorizedToGetLocation") == false) {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewSetup()
    }
    
    // Location Methods
    func getCoords() -> String? {
        if (UserDefaults.standard.bool(forKey: "authorizedToGetLocation") == false) {
            return nil
        } else if self.latitude == 0.0 && self.longitude == 0.0 {
            return nil
        } else {
            return "\(self.latitude),\(self.longitude)"
        }
    }
    
    func StartupdateLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        self.latitude = locValue.latitude
        self.longitude = locValue.longitude
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            // Disable your app's location features
            UserDefaults.standard.set(false, forKey: "authorizedToGetLocation")
            break
            
        case .authorizedWhenInUse:
            // Enable only your app's when-in-use features.
            UserDefaults.standard.set(true, forKey: "authorizedToGetLocation")
            StartupdateLocation()
            break
            
        case .authorizedAlways:
            // Enable any of your app's location services.
            UserDefaults.standard.set(true, forKey: "authorizedToGetLocation")
            StartupdateLocation()
            break
            
        case .notDetermined:
            UserDefaults.standard.set(false, forKey: "authorizedToGetLocation")
            break
        }
    }
    
}
