//
//  PinInputViewController.swift
//  SOSMS
//
//  Created by SAP008 on 2018-02-19.
//  Copyright © 2018 jasap. All rights reserved.
//

import UIKit

class PinInputViewController: UIViewController, UITextFieldDelegate {

    // Controller Variables
    var timer = Timer()
    var seconds = 15
    
    // Storboard Variables
    @IBOutlet weak var pinValue1: UITextField!
    @IBOutlet weak var pinValue2: UITextField!
    @IBOutlet weak var pinValue3: UITextField!
    @IBOutlet weak var pinValue4: UITextField!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    
    // Storyboard Methods
    @IBAction func deactivateButtonPressed(_ sender: CustomButton) {
        guard let pin = UserDefaults.standard.string(forKey: "pin") else {
            return
        }

        guard let pV1 = pinValue1.text, let pV2 = pinValue2.text, let pV3 = pinValue3.text, let pV4 = pinValue4.text else {
            return
        }
        let pinEntered = pV1 + pV2 + pV3 + pV4
        
        if (pV1 == "" || pV2 == "" || pV3 == "" || pV4 == "") {
            sender.shake()
        } else if (pin != pinEntered ){
            sender.shake()
        } else {
            self.dismiss(animated: true, completion: nil)
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
            case pinValue1:
                pinValue2.becomeFirstResponder()
            case pinValue2:
                pinValue3.becomeFirstResponder()
            case pinValue3:
                pinValue4.becomeFirstResponder()
            case pinValue4:
                pinValue4.resignFirstResponder()
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
            case pinValue2:
                pinValue1.becomeFirstResponder()
                self.pinValue1.text = " "
            case pinValue3:
                pinValue2.becomeFirstResponder()
                self.pinValue2.text = " "
            case pinValue4:
                pinValue3.becomeFirstResponder()
                self.pinValue3.text = " "
            default:
                break
            }
        } else if(text.count == 1 && text != " " && string != " " && string.count == 1) {
            // Entering value on value
            switch textField {
            case pinValue1:
                pinValue2.becomeFirstResponder()
            case pinValue2:
                pinValue3.becomeFirstResponder()
            case pinValue3:
                pinValue4.becomeFirstResponder()
            case pinValue4:
                pinValue4.resignFirstResponder()
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
            case pinValue2:
                pinValue1.becomeFirstResponder()
            case pinValue3:
                pinValue2.becomeFirstResponder()
            case pinValue4:
                pinValue3.becomeFirstResponder()
            default:
                break
            }
        } else if text?.utf16.count == 1 {
            switch textField {
            case pinValue1:
                pinValue2.becomeFirstResponder()
            case pinValue2:
                pinValue3.becomeFirstResponder()
            case pinValue3:
                pinValue4.becomeFirstResponder()
            case pinValue4:
                pinValue4.resignFirstResponder()
            default:
                break
            }
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(PinInputViewController.counter), userInfo: nil, repeats: true)
    }
    
    @objc func counter() {
        seconds -= 1
        timeRemainingLabel.text = String(seconds) + " Seconds"
        
        if (seconds == 0) {
            timer.invalidate()
            self.dismiss(animated: true, completion: {
                EmergencyDataManager.shared.firstVC.callSMSService()
            })
        }
    }
    
    // Standard Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pinValue1.delegate = self
        pinValue2.delegate = self
        pinValue3.delegate = self
        pinValue4.delegate = self

        //view.setGradientBackground(colorOne: Colors.white, colorTwo: Colors.sosmsRed)
        
//        pinValue1.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
//        pinValue2.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
//        pinValue3.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
//        pinValue4.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pinValue1.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let pinTime =  UserDefaults.standard.integer(forKey: "timer")
        if pinTime == 0 {
            self.dismiss(animated: true, completion: nil)
        } else {
            switch (pinTime) {
            case 0:
                seconds = 0
            case 1:
                seconds = 5
            case 2:
                seconds = 10
            case 3:
                seconds = 15
            default:
                seconds = 0
            }
            startTimer()
        }
    }
    
}
