//
//  BaseTabBarController.swift
//  SOSMS
//
//  Created by SAP008 on 2018-02-18.
//  Copyright © 2018 jasap. All rights reserved.
//

import UIKit

class BaseTabBarController: UITabBarController {

    @IBInspectable var defaultIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let contactsArray = UserDefaults.standard.array(forKey: "contacts") {
            if contactsArray.count == 0 {
                selectedIndex = 1
            } else {
                selectedIndex = defaultIndex
            }
        } else {
            selectedIndex = defaultIndex
        }
    }
}
