//
//  ValidationError.swift
//  SOSMS
//
//  Created by SAP008 on 2018-02-22.
//  Copyright © 2018 jasap. All rights reserved.
//

import Foundation

struct ValidationError: Error {
    
    var message: String
    var wt = 5
    
    init(message m: String) {
        message = m
    }
}
