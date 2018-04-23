//
//  EmergencyService.swift
//  SOSMS
//
//  Created by SAP008 on 2018-02-11.
//  Copyright © 2018 jasap. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftKeychainWrapper

protocol EmergencyServiceDelegate {
    func sentSMS()
    func errorWithMessage(message: String)
}

class EmergencyService {
    
    var delegate: EmergencyServiceDelegate?
    
    func sendSMS(location: String?) {
        guard let token = KeychainWrapper.standard.string(forKey: "token"), let contactsArray = UserDefaults.standard.array(forKey: "contacts"), let firstName = UserDefaults.standard.string(forKey: "first_name"), let lastName = UserDefaults.standard.string(forKey: "last_name"), let phoneNumber = UserDefaults.standard.string(forKey: "phone_number"), let message = UserDefaults.standard.string(forKey: "message") else {
            if self.delegate != nil {
                DispatchQueue.main.async {
                    self.delegate?.errorWithMessage(message: "Something went sending the emergency message.")
                }
            }
            return
        }
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": token
        ]
        let user: Dictionary<String, String> = ["FIRST_NAME": firstName,
                                      "LAST_NAME": lastName,
                                      "PHONE_NUMBER": phoneNumber,
                                      "MESSAGE": message]
        let parameters: Parameters = [
            "USER": user,
            "CONTACTS": contactsArray
        ]
        
        var url: String = "https://mysterious-sierra-76065.herokuapp.com/sms/send"
        if let location = location {
            url = url + "?location=" + location
        }
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseData) -> Void in
            
            // Check if there is data
            if((responseData.result.value) != nil) {
                let jsonResponse = JSON(responseData.result.value!)
                //Check the status Code
                if let status = responseData.response?.statusCode {
                    switch(status){
                    case 200:
                        if self.delegate != nil {
                            DispatchQueue.main.async {
                                self.delegate?.sentSMS()
                            }
                        }

                    case 406:
                        if self.delegate != nil, let errorMessage = jsonResponse["payload"]["error"].string {
                            DispatchQueue.main.async {
                                self.delegate?.errorWithMessage(message: errorMessage)
                            }
                        }
                    
                    default:
                        if self.delegate != nil {
                            DispatchQueue.main.async {
                                self.delegate?.errorWithMessage(message: "Something went wrong with the emergency message request. Please let us know at sur5iveinfo@gmail.com")
                            }
                        }
                    }
                }
                
            } else {
                if self.delegate != nil {
                    DispatchQueue.main.async {
                        self.delegate?.errorWithMessage(message: "Something went wrong with your request. Please let us know at sur5iveinfo@gmail.com")
                    }
                }
            }
        }
    }
}
