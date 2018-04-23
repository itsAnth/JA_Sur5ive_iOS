//
//  UserViewController.swift
//  SOSMS
//
//  Created by SAP008 on 2018-02-10.
//  Copyright © 2018 jasap. All rights reserved.
//

import UIKit
import Validator
import SwiftKeychainWrapper

class UserViewController: UIViewController {
    
    // Controller Variables
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    // Storyboard Variables
    @IBOutlet weak var firstNameInput: UITextField!
    @IBOutlet weak var lastNameInput: UITextField!
    @IBOutlet weak var phoneNumberInput: UITextField!
    @IBOutlet weak var saveUserChangeButton: CustomButton!
    
    
    // Storyboard Methods
    @IBAction func saveUserButtonPressed(_ sender: CustomButton) {
        guard let firstName = UserDefaults.standard.string(forKey: "first_name"), let lastName = UserDefaults.standard.string(forKey: "last_name"), let phoneNumber = UserDefaults.standard.string(forKey: "phone_number") else {
            return
        }
        guard let newFirstName = firstNameInput.text, let newLastName = lastNameInput.text, let newPhoneNumber = phoneNumberInput.text else {
            return
        }
        
        if (newFirstName == "" || newLastName == "" || newPhoneNumber == "") {
            openEmptyFieldAlert()
        } else if (newFirstName == firstName && newLastName == lastName && newPhoneNumber == phoneNumber ){
            openNoFieldChangeAlert()
            saveUserChangeButton.isEnabled = false
            saveUserChangeButton.backgroundColor = UIColor(red: 154/255.0, green: 154/255.0, blue: 154/255.0, alpha: 1.0)
        } else {
            // Validate input
            let firstNameLength = ValidationRuleLength(min:2, max: 20, error: ValidationError(message: "First name field should be 2 to 20 characters."))
            let lastNameLength = ValidationRuleLength(min:2, max: 20, error: ValidationError(message: "Last name field should be 2 to 20 characters."))
            let phoneNumberLength = ValidationRuleLength(min:10, max: 10, error: ValidationError(message: "Phone number must be 10 digits."))
            
            var validationErr: [String] = []
            
            // First name validation
            let firstNameResult = newFirstName.validate(rule: firstNameLength)
            switch firstNameResult {
            case .valid:
                print("😀")
            case .invalid(let failures):
                var errs = failures as! [ValidationError]
                validationErr.append(errs[0].message)
            }
            
            // Last name validation
            let lastNameResult = newLastName.validate(rule: lastNameLength)
            switch lastNameResult {
            case .valid:
                print("it was valid")
                print("😀")
            case .invalid(let failures):
                var errs = failures as! [ValidationError]
                validationErr.append(errs[0].message)
            }
            
            // Phone number validation
            let phoneNumberResult = newPhoneNumber.validate(rule: phoneNumberLength)
            switch phoneNumberResult {
            case .valid:
                print("😀")
            case .invalid(let failures):
                var errs = failures as! [ValidationError]
                validationErr.append(errs[0].message)
            }
            
            guard Int(newPhoneNumber) != nil else {
                validationErr.append("Phone number must be numbers only.")
                openErrorWithMessageArray(errorMessageArray: validationErr)
                return
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
                
                // Send to User Service
                UserDefaults.standard.set(newFirstName, forKey: "first_name");
                UserDefaults.standard.set(newLastName, forKey: "last_name");
                UserDefaults.standard.set(newPhoneNumber, forKey: "phone_number");
                
                // turn off activity indicator and turn on interactions
                activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                saveUserChangeButton.isEnabled = false
                saveUserChangeButton.backgroundColor = UIColor(red: 154/255.0, green: 154/255.0, blue: 154/255.0, alpha: 1.0)
            }
        }
    }
    @IBAction func eraseDataFromPhoneButtonPressed(_ sender: CustomButton) {
        openConfirmDelete()
    }
    
    // Helper Functions
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
    
    func openConfirmDelete() {
        let alert = UIAlertController(title: "Alert", message: "Are you sure you want to delete the data in this app?", preferredStyle: UIAlertControllerStyle.alert)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        let delete = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive) { (action) in
            self.eraseDataFromDevice()
        }
        alert.addAction(cancel)
        alert.addAction(delete)
        self.present(alert, animated: true, completion: nil)
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
    
    func eraseDataFromDevice() {
        // Credentials
        KeychainWrapper.standard.removeObject(forKey: "token")
        
        // User
        UserDefaults.standard.removeObject(forKey: "first_name")
        UserDefaults.standard.removeObject(forKey: "last_name")
        UserDefaults.standard.removeObject(forKey: "phone_number")
        UserDefaults.standard.removeObject(forKey: "message")
        UserDefaults.standard.removeObject(forKey: "timer")
        UserDefaults.standard.removeObject(forKey: "pin")
        
        // Contacts
        UserDefaults.standard.removeObject(forKey: "contacts")
        
        // History
        UserDefaults.standard.removeObject(forKey: "history")
        
        performSegue(withIdentifier: "isLoggedOut", sender: self)
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        saveUserChangeButton.isEnabled = true
        saveUserChangeButton.backgroundColor = UIColor(red: 215/255.0, green: 64/255.0, blue: 57/255.0, alpha: 1.0)
    }
    
    // Standard Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstNameInput.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        lastNameInput.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        phoneNumberInput.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        
        self.hideKeyboardWhenTappedAround()
        
        // Set the input fields
        if let first_name = UserDefaults.standard.string(forKey: "first_name") {
            firstNameInput?.text = first_name
        }
        if let last_name = UserDefaults.standard.string(forKey: "last_name") {
            lastNameInput?.text = last_name
        }
        if let phone_number = UserDefaults.standard.string(forKey: "phone_number") {
            phoneNumberInput?.text = phone_number
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
