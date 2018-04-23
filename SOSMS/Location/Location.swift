//
//  Location.swift
//  SOSMS
//
//  Created by SAP008 on 2018-02-19.
//  Copyright © 2018 jasap. All rights reserved.
//

import Foundation
import CoreLocation

struct Location {
    
    static let sharedInstance = Location()
    let locationManager:CLLocationManager = CLLocationManager()
    
}
