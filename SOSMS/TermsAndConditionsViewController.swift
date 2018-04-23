//
//  TermsAndConditionsViewController.swift
//  SOSMS
//
//  Created by SAP008 on 2018-02-27.
//  Copyright © 2018 jasap. All rights reserved.
//

import UIKit
import WebKit

class TermsAndConditionsViewController: UIViewController {

    @IBOutlet weak var webKitView: WKWebView!
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string:"https://termsfeed.com/terms-conditions/539fd87167516926a4d336d1dcef66f3")
        let request = URLRequest(url: url!)
        
        webKitView.load(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
