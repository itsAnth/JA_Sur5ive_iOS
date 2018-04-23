//
//  MessageViewController.swift
//  SOSMS
//
//  Created by SAP008 on 2018-02-12.
//  Copyright © 2018 jasap. All rights reserved.
//

import UIKit
import Validator

class MessageViewController: UIViewController, UITextViewDelegate {
    
    // Controller Variables
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var scrollViewContainer: UIScrollView = {
        var scrollView = UIScrollView()
        return scrollView
    }()
    
    // Storyboard Variables
    @IBOutlet weak var messageInput: UITextView!
    @IBOutlet weak var pinInput: UITextField!
    @IBOutlet weak var pinTimeSelection: UISegmentedControl!
    @IBOutlet weak var beaconSwitch: UISwitch!
    @IBOutlet weak var saveMessageChangeButton: CustomButton!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var headerView: UIView!
    
    // Storyboard Methods
    @IBAction func saveMessageInformationButtonPressed(_ sender: CustomButton) {
        guard let message = UserDefaults.standard.string(forKey: "message"), let pin = UserDefaults.standard.string(forKey: "pin") else {
            return
        }
        let pinTimeIndex =  UserDefaults.standard.integer(forKey: "timer")
        
        guard let newMessage = messageInput.text, let newPin = pinInput.text else {
            return
        }
        let newPinTimeIndex = pinTimeSelection.selectedSegmentIndex
        
        if (newMessage == "" || newPin == "") {
            openEmptyFieldAlert()
        } else if (newMessage == message && newPin == pin && newPinTimeIndex == pinTimeIndex ){
            openNoFieldChangeAlert()
            saveMessageChangeButton.isEnabled = false
            saveMessageChangeButton.backgroundColor = UIColor(red: 154/255.0, green: 154/255.0, blue: 154/255.0, alpha: 1.0)
        } else {
            
             let pinLength = ValidationRuleLength(min:4, max: 4, error: ValidationError(message: "Pin must be 4 digits."))
            let pinNumeric = ValidationRuleComparison<Int>(min: 0, max: 9999, error: ValidationError(message: "Invalid pin"))
            
            var validationErr: [String] = []
            
            // Pin validation
            let pinResult = newPin.validate(rule: pinLength)
            switch pinResult {
            case .valid:
                print("😀")
            case .invalid(let failures):
                var errs = failures as! [ValidationError]
                validationErr.append(errs[0].message)
            }
            
            guard let pinAsInt = Int(newPin) else {
                // call error
                validationErr.append("Pin must be numbers only.")
                openErrorWithMessageArray(errorMessageArray: validationErr)
                return
            }
            
            let pinResult2 = pinAsInt.validate(rule: pinNumeric)
            switch pinResult2 {
            case .valid:
                print("😀")
            case .invalid(let failures):
                var errs = failures as! [ValidationError]
                validationErr.append(errs[0].message)
            }
            
            if (validationErr.count > 0) {
                openErrorWithMessageArray(errorMessageArray: validationErr)
            } else {
                // Change UI to stop interaction
                activityIndicator.center = self.view.center
                activityIndicator.hidesWhenStopped = true
                activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
                view.addSubview(activityIndicator)
                activityIndicator.startAnimating()
                UIApplication.shared.beginIgnoringInteractionEvents()
                
                UserDefaults.standard.set(newMessage, forKey: "message");
                UserDefaults.standard.set(newPin, forKey: "pin");
                UserDefaults.standard.set(newPinTimeIndex, forKey: "timer");
                
                // turn off activity indicator and turn on interactions
                activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                saveMessageChangeButton.isEnabled = false
                saveMessageChangeButton.backgroundColor = UIColor(red: 154/255.0, green: 154/255.0, blue: 154/255.0, alpha: 1.0)
            }
        }
    }
    
    @IBAction func messageTriggerBeaconSwitched(_ sender: UISwitch) {
        if sender.isOn {
            UserDefaults.standard.set(true,forKey:"switchOn");
        }
        else {
            UserDefaults.standard.set(false,forKey:"switchOn");
        }
    }
    
    // Helper Functions
    func updatedMessageInformation() {
        
        // turn off activity indicator and turn on interactions
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
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
    
    func openErrorWithMessageArray(errorMessageArray: [String]) {
        
        var messageString: String = ""
        for err in errorMessageArray {
            messageString = messageString + err + " "
        }
        let alert = UIAlertController(title: "Error", message: messageString, preferredStyle: UIAlertControllerStyle.alert)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func openEmptyFieldAlert() {
        let alert = UIAlertController(title: "Alert", message: "Fields cannot be blank", preferredStyle: UIAlertControllerStyle.alert)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func openNoFieldChangeAlert() {
        let alert = UIAlertController(title: "Alert", message: "No changes detected", preferredStyle: UIAlertControllerStyle.alert)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func viewSetup() {
        if UserDefaults.standard.bool(forKey: "switchOn") == true {
            beaconSwitch.setOn(true, animated: false)
        } else {
            beaconSwitch.setOn(false, animated: false)
        }
        
        guard let message = UserDefaults.standard.string(forKey: "message"), let pin = UserDefaults.standard.string(forKey: "pin") else {
            return
        }
        let pinTimeIndex =  UserDefaults.standard.integer(forKey: "timer")
        guard let newMessage = messageInput.text, let newPin = pinInput.text else {
            return
        }
        let newPinTimeIndex = pinTimeSelection.selectedSegmentIndex

        if (newMessage != message || newPin != pin || newPinTimeIndex != pinTimeIndex ){
            messageInput.text = message
            pinInput.text = pin
            switch (pinTimeIndex) {
            case 0:
                pinTimeSelection.selectedSegmentIndex = 0
            case 1:
                pinTimeSelection.selectedSegmentIndex = 1
            case 2:
                pinTimeSelection.selectedSegmentIndex = 2
            case 3:
                pinTimeSelection.selectedSegmentIndex = 3
            default:
                pinTimeSelection.selectedSegmentIndex = 0
            }
        }
    }
    
    @objc func willEnterForeground() {
        viewSetup()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        saveMessageChangeButton.isEnabled = true
        saveMessageChangeButton.backgroundColor = UIColor(red: 215/255.0, green: 64/255.0, blue: 57/255.0, alpha: 1.0)
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        saveMessageChangeButton.isEnabled = true
        saveMessageChangeButton.backgroundColor = UIColor(red: 215/255.0, green: 64/255.0, blue: 57/255.0, alpha: 1.0)
    }
    
    @objc func segmentControlDidChange(segmentedControl: UISegmentedControl) {
        saveMessageChangeButton.isEnabled = true
        saveMessageChangeButton.backgroundColor = UIColor(red: 215/255.0, green: 64/255.0, blue: 57/255.0, alpha: 1.0)
    }
    
    // Standard Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        self.hideKeyboardWhenTappedAround()
        
        messageInput.delegate = self
        pinTimeSelection.addTarget(self, action: #selector(self.segmentControlDidChange(segmentedControl:)), for: UIControlEvents.valueChanged)
        pinInput.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        
        if let message = UserDefaults.standard.string(forKey: "message") {
            messageInput?.text = message
        }
        if let pin = UserDefaults.standard.string(forKey: "pin") {
            pinInput?.text = pin
        }
        let pinTimeIndex = UserDefaults.standard.integer(forKey: "timer")
        pinTimeSelection.selectedSegmentIndex = pinTimeIndex

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewSetup()
    }
    
}
