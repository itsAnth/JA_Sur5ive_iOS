//
//  EditContactViewController.swift
//  SOSMS
//
//  Created by SAP008 on 2018-02-17.
//  Copyright © 2018 jasap. All rights reserved.
//

import UIKit
import Validator

class EditContactViewController: UIViewController {

    // Controller Variables
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var contactToEdit: Contact?
    var contactIndex: IndexPath?
    
    // Storyboard Variables
    @IBOutlet weak var firstNameInput: UITextField!
    @IBOutlet weak var lastNameInput: UITextField!
    @IBOutlet weak var phoneNumberInput: UITextField!
    @IBOutlet weak var saveEditContactChangeButton: CustomButton!
    
    
    // Storyboard Methods
    @IBAction func saveEditContactButtonPressed(_ sender: CustomButton) {
        guard let firstName = contactToEdit?.firstName, let lastName = contactToEdit?.lastName, let phoneNumber = contactToEdit?.phoneNumber else {
            return
        }
        guard let newFirstName = firstNameInput.text, let newLastName = lastNameInput.text, let newPhoneNumber = phoneNumberInput.text else {
            return
        }
        
        if (newFirstName == "" || newLastName == "" || newPhoneNumber == "") {
            openEmptyFieldAlert()
        } else if (newFirstName == firstName && newLastName == lastName && newPhoneNumber == phoneNumber ){
            openNoFieldChangeAlert()
            saveEditContactChangeButton.isEnabled = false
            saveEditContactChangeButton.backgroundColor = UIColor(red: 154/255.0, green: 154/255.0, blue: 154/255.0, alpha: 1.0)
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
                
                // Save edited contact
                if var contactsArray = UserDefaults.standard.array(forKey: "contacts") {
                    let updatedContact:[String: String] = ["FIRST_NAME": newFirstName,
                                                           "LAST_NAME": newLastName,
                                                           "PHONE_NUMBER": newPhoneNumber]
                    contactsArray[(contactIndex?.row)!] = updatedContact
                    UserDefaults.standard.set(contactsArray, forKey: "contacts")
                    contactUpdated()
                    saveEditContactChangeButton.isEnabled = false
                    saveEditContactChangeButton.backgroundColor = UIColor(red: 154/255.0, green: 154/255.0, blue: 154/255.0, alpha: 1.0)
                }
            }
        }
    }
    
    @IBAction func cancelEditContactButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteEditContactButtonPressed(_ sender: Any) {
        openConfirmDelete()
    }
    
    // Helper Functions
    func contactUpdated() {
        
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
    
    func openNoFieldChangeAlert() {
        let alert = UIAlertController(title: "Alert", message: "No changes detected", preferredStyle: UIAlertControllerStyle.alert)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func openConfirmDelete() {
        let alert = UIAlertController(title: "Alert", message: "Are you sure you want to delete this contact?", preferredStyle: UIAlertControllerStyle.alert)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        let delete = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive) { (action) in
            self.deleteEmergencyContact()
        }
        alert.addAction(cancel)
        alert.addAction(delete)
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteEmergencyContact() {
        guard let contactIndex = contactIndex else {
            return
        }
        self.dismiss(animated: true) {
            DataManager.shared.firstVC.deleteContact(indexPath: contactIndex)
        }
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        saveEditContactChangeButton.isEnabled = true
        saveEditContactChangeButton.backgroundColor = UIColor(red: 215/255.0, green: 64/255.0, blue: 57/255.0, alpha: 1.0)
    }
    
    // Standard Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstNameInput.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        lastNameInput.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        phoneNumberInput.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        
        self.hideKeyboardWhenTappedAround()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let contactToEdit = contactToEdit, contactIndex != nil {
            firstNameInput.text = contactToEdit.firstName
            lastNameInput.text = contactToEdit.lastName
            phoneNumberInput.text = contactToEdit.phoneNumber
        }
    }
}
