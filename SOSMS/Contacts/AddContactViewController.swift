//
//  AddContactViewController.swift
//  SOSMS
//
//  Created by SAP008 on 2018-02-08.
//  Copyright © 2018 jasap. All rights reserved.
//

import UIKit
import Validator

class AddContactViewController: UIViewController {

    // Controller Variables
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    // Storyboard Variables
    @IBOutlet weak var firstNameInput: UITextField!
    @IBOutlet weak var lastNameInput: UITextField!
    @IBOutlet weak var phoneNumberInput: UITextField!
    
    // Storyboard Methods
    @IBAction func addContactSaveButtonPressed(_ sender: CustomButton) {
        guard let firstName = firstNameInput.text, let lastName = lastNameInput.text, let phoneNumber = phoneNumberInput.text, var contactsArray = UserDefaults.standard.array(forKey: "contacts") as? [Dictionary<String, String>] else {
            errorWithMessage(message: "Error saving contact.")
            return
        }
        if (firstName == "" || lastName == "" || phoneNumber == "") {
            openEmptyFieldAlert()
        }  else if(contactsArray.count >= 5) {
            errorWithMessage(message: "Max number of contacts is 5.")
        } else {
            // Validate input
            let firstNameLength = ValidationRuleLength(min:2, max: 20, error: ValidationError(message: "First name field should be 2 to 20 characters."))
            let lastNameLength = ValidationRuleLength(min:2, max: 20, error: ValidationError(message: "Last name field should be 2 to 20 characters."))
            let phoneNumberLength = ValidationRuleLength(min:10, max: 10, error: ValidationError(message: "Phone number must be 10 digits."))
            
            var validationErr: [String] = []
            
            // First name validation
            let firstNameResult = firstName.validate(rule: firstNameLength)
            switch firstNameResult {
            case .valid:
                print("😀")
            case .invalid(let failures):
                var errs = failures as! [ValidationError]
                validationErr.append(errs[0].message)
            }
            
            // Last name validation
            let lastNameResult = lastName.validate(rule: lastNameLength)
            switch lastNameResult {
            case .valid:
                print("it was valid")
                print("😀")
            case .invalid(let failures):
                var errs = failures as! [ValidationError]
                validationErr.append(errs[0].message)
            }
            
            // Phone number validation
            let phoneNumberResult = phoneNumber.validate(rule: phoneNumberLength)
            switch phoneNumberResult {
            case .valid:
                print("😀")
            case .invalid(let failures):
                var errs = failures as! [ValidationError]
                validationErr.append(errs[0].message)
            }
            
            guard Int(phoneNumber) != nil else {
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
                
                // Add contact
                let newContact:[String: String] = ["FIRST_NAME": firstName,
                                                   "LAST_NAME": lastName,
                                                   "PHONE_NUMBER": phoneNumber]
                contactsArray.append(newContact)
                UserDefaults.standard.set(contactsArray, forKey: "contacts")
                contactCreated()
            }
        }
    }
    
    @IBAction func cancelAddContactButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Helper Functions
    func contactCreated() {
        
        // turn off activity indicator and turn on interactions
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        self.dismiss(animated: true) {
            DataManager.shared.firstVC.refreshContactTable()
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
    
    // Standard Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
