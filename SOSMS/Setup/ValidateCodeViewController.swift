//
//  ValidateCodeViewController.swift
//  SOSMS
//
//  Created by SAP008 on 2018-02-23.
//  Copyright © 2018 jasap. All rights reserved.
//

import UIKit

class ValidateCodeViewController: UIViewController, UITextFieldDelegate, ValidateCodeServiceDelegate {

    // Controller Variable
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var phoneNumber: String?
    let validateCodeService = ValidateCodeService()
    
    // Storyboard Variable
    @IBOutlet weak var codeValue1: UITextField!
    @IBOutlet weak var codeValue2: UITextField!
    @IBOutlet weak var codeValue3: UITextField!
    @IBOutlet weak var codeValue4: UITextField!
    @IBOutlet weak var verifyButton: CustomButton!
    
    // Storyboard Methods
    @IBAction func validateCodeButtonPressed(_ sender: CustomButton) {
        guard let phoneNumberToValidate = phoneNumber else {
            errorWithMessage(message: "No phone number provided.")
            return
        }
        
        guard let cV1 = codeValue1.text, let cV2 = codeValue2.text, let cV3 = codeValue3.text, let cV4 = codeValue4.text else {
            return
        }
        let codeEntered = cV1 + cV2 + cV3 + cV4
        
        if (cV1 == "" || cV2 == "" || cV3 == "" || cV4 == "") {
            sender.shake()
        } else {
            // Change UI to stop interaction
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            validateCodeService.validateCode(phoneNumber: phoneNumberToValidate, code: codeEntered)
        }
    }
    
    @IBAction func backButtonPressed(_ sender: CustomButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - ValidateCode Service Delegate
    func codeValidated(token: String) {
        // turn off activity indicator and turn on interactions
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        self.dismiss(animated: true) {
            SetupDataManager.shared.firstVC.createUser(token: token)
        }
        
    }
    
    func errorWithMessage(message: String) {
        
        // turn off activity indicator and turn on interactions
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        
        if (message == "Invalid code.") {
            verifyButton.shake()
        } else {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // Text Field Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        if (text == " " && string != " " && string.count == 1) {
            // Entering value on blank
            // advance responder
            textField.text = string
            switch textField {
            case codeValue1:
                codeValue2.becomeFirstResponder()
            case codeValue2:
                codeValue3.becomeFirstResponder()
            case codeValue3:
                codeValue4.becomeFirstResponder()
            case codeValue4:
                codeValue4.resignFirstResponder()
            default:
                break
            }
        } else if (text != " " && text.count == 1 && string.count == 0) {
            // trying to delete a value
            textField.text = " "
        } else if (text == " " && text.count == 1 && string.count == 0) {
            // trying to delete empty value or value before
            textField.text = " "
            switch textField {
            case codeValue2:
                codeValue1.becomeFirstResponder()
                self.codeValue1.text = " "
            case codeValue3:
                codeValue2.becomeFirstResponder()
                self.codeValue2.text = " "
            case codeValue4:
                codeValue3.becomeFirstResponder()
                self.codeValue3.text = " "
            default:
                break
            }
        } else if(text.count == 1 && text != " " && string != " " && string.count == 1) {
            // Entering value on value
            switch textField {
            case codeValue1:
                codeValue2.becomeFirstResponder()
            case codeValue2:
                codeValue3.becomeFirstResponder()
            case codeValue3:
                codeValue4.becomeFirstResponder()
            case codeValue4:
                codeValue4.resignFirstResponder()
            default:
                break
            }
            textField.text = string
        } else {
            return true
        }
        return false
    }
    
    // Helper Functions
    @objc func textFieldDidChange(textField: UITextField) {
        
        let text = textField.text
        
        if text?.utf16.count == 0 {
            switch textField {
            case codeValue2:
                codeValue1.becomeFirstResponder()
            case codeValue3:
                codeValue2.becomeFirstResponder()
            case codeValue4:
                codeValue3.becomeFirstResponder()
            default:
                break
            }
        } else if text?.utf16.count == 1 {
            switch textField {
            case codeValue1:
                codeValue2.becomeFirstResponder()
            case codeValue2:
                codeValue3.becomeFirstResponder()
            case codeValue3:
                codeValue4.becomeFirstResponder()
            case codeValue4:
                codeValue4.resignFirstResponder()
            default:
                break
            }
        }
    }
    
    // Standard Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        codeValue1.delegate = self
        codeValue2.delegate = self
        codeValue3.delegate = self
        codeValue4.delegate = self
        
        self.validateCodeService.delegate = self
        
//        codeValue1.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
//        codeValue2.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
//        codeValue3.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
//        codeValue4.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        codeValue1.becomeFirstResponder()
    }
}
