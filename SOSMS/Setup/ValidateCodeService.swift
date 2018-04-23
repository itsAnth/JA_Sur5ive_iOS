//
//  ValidateCodeService.swift
//  SOSMS
//
//  Created by SAP008 on 2018-02-23.
//  Copyright © 2018 jasap. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftKeychainWrapper

protocol ValidateCodeServiceDelegate {
    func codeValidated(token: String)
    func errorWithMessage(message: String)
}

class ValidateCodeService {
    let headers: HTTPHeaders = [
        "Content-Type":"application/json",
        "Accept": "application/json"
    ]
    var delegate: ValidateCodeServiceDelegate?
    
    func validateCode(phoneNumber: String, code: String) {
        let parameters: [String: String] = [
            "PHONE_NUMBER": phoneNumber,
            "CODE": code
        ]
        Alamofire.request("https://mysterious-sierra-76065.herokuapp.com/validate/validatecode", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { (responseData) -> Void in
            
            // Check if there is data
            if((responseData.result.value) != nil) {
                
                let jsonResponse = JSON(responseData.result.value!)
                
                //Check the status Code
                if let status = responseData.response?.statusCode {
                    switch(status){
                    case 200:
                        
                        if self.delegate != nil, let token = jsonResponse["token"].string {
                            DispatchQueue.main.async {
                                self.delegate?.codeValidated(token: token)
                            }
                        }
                        
                    case 403:
                        // validation error
                        if self.delegate != nil, let errorMessage = jsonResponse["payload"]["error"].string {
                            DispatchQueue.main.async {
                                self.delegate?.errorWithMessage(message: errorMessage)
                            }
                        }
                        
                    default:
                        if self.delegate != nil {
                            DispatchQueue.main.async {
                                self.delegate?.errorWithMessage(message: "Something went wrong with your login request. Please let us know at sur5iveinfo@gmail.com")
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
