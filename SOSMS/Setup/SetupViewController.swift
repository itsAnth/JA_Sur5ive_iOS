//
//  SetupViewController.swift
//  SOSMS
//
//  Created by SAP008 on 2018-02-12.
//  Copyright © 2018 jasap. All rights reserved.
//

import UIKit
import Validator
import SwiftKeychainWrapper

class SetupViewController: UIViewController, SetupServiceDelegate, UITextFieldDelegate {

    // View Controller Variables
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    let setupService = SetupService()
    
    var activeTextField: UITextField!
    
    // Storyboard Variables
    @IBOutlet weak var firstNameInput: UITextField!
    @IBOutlet weak var lastNameInput: UITextField!
    @IBOutlet weak var phoneNumberInput: UITextField!
    @IBOutlet weak var pinInput: UITextField!
    
    // Storyboard Methods
    @IBAction func submitSetupInformationPressed(_ sender: Any) {
        validateUserInformation()
    }
    
    @IBAction func cancelSetupButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Setup Service Delegate
    func codeSent() {
        
        // turn off activity indicator and turn on interactions
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        performSegue(withIdentifier: "codeWasSent", sender: self)
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
    func validateUserInformation() {
        guard let firstName = firstNameInput.text, let lastName = lastNameInput.text, let phoneNumber = phoneNumberInput.text, let pin = pinInput.text else {
            return
        }
        if (firstName == "" || lastName == "" || phoneNumber == "" || pin == "") {
            openEmptyFieldAlert()
        } else {
            
            // Validate input
            let firstNameLength = ValidationRuleLength(min:2, max: 20, error: ValidationError(message: "First name field should be 2 to 20 characters."))
            let lastNameLength = ValidationRuleLength(min:2, max: 20, error: ValidationError(message: "Last name field should be 2 to 20 characters."))
            let pinLength = ValidationRuleLength(min:4, max: 4, error: ValidationError(message: "Pin length must be 4."))
            let phoneNumberLength = ValidationRuleLength(min:10, max: 10, error: ValidationError(message: "Phone number must be 10 digits."))
            let pinNumeric = ValidationRuleComparison<Int>(min: 0, max: 9999, error: ValidationError(message: "Invalid pin."))
            
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
                print("😀")
            case .invalid(let failures):
                var errs = failures as! [ValidationError]
                validationErr.append(errs[0].message)
            }
            
            // Pin validation
            let pinResult = pin.validate(rule: pinLength)
            switch pinResult {
            case .valid:
                print("😀")
            case .invalid(let failures):
                var errs = failures as! [ValidationError]
                validationErr.append(errs[0].message)
            }
            
            guard let pinAsInt = Int(pin) else {
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
                setupService.sendCode(phoneNumber: phoneNumber)
            }
        }
    }
    
    func openEmptyFieldAlert() {
        let alert = UIAlertController(title: "Alert", message: "Fields cannot be blank", preferredStyle: UIAlertControllerStyle.alert)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func openBadPasswordAlert() {
        let alert = UIAlertController(title: "Alert", message: "Passwords do not match", preferredStyle: UIAlertControllerStyle.alert)
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
    
    
    // Standard Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        SetupDataManager.shared.firstVC = self
        self.hideKeyboardWhenTappedAround()
        self.setupService.delegate = self
        
        firstNameInput.delegate = self
        lastNameInput.delegate = self
        phoneNumberInput.delegate = self
        pinInput.delegate = self

        let center: NotificationCenter = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Keyboard Moving
    @objc func keyboardDidShow(notification: Notification) {
        let info:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
        let keyboardY = self.view.frame.size.height - keyboardSize.height
        
        if let editingTextFieldY:CGFloat = activeTextField?.frame.origin.y {
            if self.view.frame.origin.y >= 0 {
                //Checking if the textfield is really hidden behind the keyboard
                if editingTextFieldY > keyboardY - 80 {
                    UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                        self.view.frame = CGRect(x: 0, y: self.view.frame.origin.y - (editingTextFieldY - (keyboardY - 80)), width: self.view.bounds.width,height: self.view.bounds.height)
                    }, completion: nil)
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.view.frame = CGRect(x: 0, y: 0,width: self.view.bounds.width, height: self.view.bounds.height)
        }, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // External Helper Functions
    
    func createUser(token: String) {
        // Change UI to stop interaction
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        guard let firstName = firstNameInput.text, let lastName = lastNameInput.text, let phoneNumber = phoneNumberInput.text, let pin = pinInput.text else {
            let message = "Something went wrong during the setup"
            errorWithMessage(message: message)
            return
        }
        if (firstName == "" || lastName == "" || phoneNumber == "" || pin == "") {
            openEmptyFieldAlert()
        } else {
            let standardMessage: String = "Please give me  call, I may need your help!"
            KeychainWrapper.standard.set(token, forKey: "token")
            UserDefaults.standard.set(firstName, forKey: "first_name");
            UserDefaults.standard.set(lastName, forKey: "last_name");
            UserDefaults.standard.set(phoneNumber, forKey: "phone_number");
            UserDefaults.standard.set(pin, forKey: "pin");
            UserDefaults.standard.set(standardMessage, forKey: "message");
            UserDefaults.standard.set(1, forKey: "timer");
            let contactsArray: [Dictionary<String, String>] = []
            UserDefaults.standard.set(contactsArray, forKey: "contacts");
            let historyArray: [String] = []
            UserDefaults.standard.set(historyArray, forKey: "history");
            
            // turn off activity indicator and turn on interactions
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            performSegue(withIdentifier: "nowIsSetup", sender: self)
            
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "codeWasSent" {
            if let phoneNumber = phoneNumberInput.text {
                let destVC = segue.destination as! ValidateCodeViewController
                destVC.phoneNumber = phoneNumber
            }
        }
    }
    
}
