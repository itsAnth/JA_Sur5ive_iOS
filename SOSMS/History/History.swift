//
//  History.swift
//  SOSMS
//
//  Created by SAP008 on 2018-02-11.
//  Copyright © 2018 jasap. All rights reserved.
//

import Foundation

class History {
    var smsDate: String!
    
    init(d: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm:ss"
        self.smsDate = dateFormatter.string(from: d)
    }
}
