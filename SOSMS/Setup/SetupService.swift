//
//  SetupService.swift
//  SOSMS
//
//  Created by SAP008 on 2018-02-14.
//  Copyright © 2018 jasap. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftKeychainWrapper

protocol SetupServiceDelegate {
    func codeSent()
    func errorWithMessage(message: String)
}

class SetupService {
    let headers: HTTPHeaders = [
        "Content-Type":"application/json",
        "Accept": "application/json"
    ]
    var delegate: SetupServiceDelegate?
    
    func sendCode(phoneNumber: String) {

        Alamofire.request("https://mysterious-sierra-76065.herokuapp.com/validate/code/\(phoneNumber)", method: .get).responseJSON { (responseData) -> Void in
            
            // Check if there the response
            if let status = responseData.response?.statusCode {
                switch(status){
                case 200:
                    
                    if self.delegate != nil {
                        DispatchQueue.main.async {
                            self.delegate?.codeSent()
                        }
                    }
                    
                case 401:
                    if self.delegate != nil {
                        DispatchQueue.main.async {
                            self.delegate?.errorWithMessage(message: "Could not send code. Please let us know at sur5iveinfo@gmail.com")
                        }
                    }
                    
                default:
                    if self.delegate != nil {
                        DispatchQueue.main.async {
                            self.delegate?.errorWithMessage(message: "Something went wrong in the signup request. Please let us know at sur5iveinfo@gmail.com")
                        }
                    }
                }
            }
        }
    }
}
