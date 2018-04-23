//
//  HistoryViewController.swift
//  SOSMS
//
//  Created by SAP008 on 2018-02-08.
//  Copyright © 2018 jasap. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Controller Variables
    var array = [History]()
    var refreshControl: UIRefreshControl?

    // Storyboard Variables
    @IBOutlet weak var tableView: UITableView!
    
    func errorWithMessage(message: String) {
        
        // Stop refresh indicator
        self.refreshControl?.endRefreshing()
        
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    // Helper Functions
    // MARK: Tablview data source methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell") {
            cell.textLabel?.text = String(describing: array[indexPath.row].smsDate!)
            cell.detailTextLabel?.text = "Sent sms"
            return cell
        } else {
            let blankCell = UITableViewCell()
            blankCell.textLabel?.text = "No History Value"
            return blankCell
        }
        
    }
    
    @objc func reloadHistory() {
        // after getting new data
        if let historyArray = UserDefaults.standard.array(forKey: "history") as? [Date] {
            array.removeAll()
            for item in historyArray {
                array.append(History(d: item))
            }
            tableView.reloadData()
        }
        self.refreshControl?.endRefreshing()
    }
    
    // Standard Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        
        if let historyArray = UserDefaults.standard.array(forKey: "history") as? [Date] {
            for item in historyArray {
                array.append(History(d: item))
            }
        }
        
        // Pull to refresh the table data
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.backgroundColor = .purple
        self.refreshControl?.tintColor = .white
        self.refreshControl?.addTarget(self, action: #selector(reloadHistory), for: .valueChanged)
        tableView.addSubview(self.refreshControl!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let historyArray = UserDefaults.standard.array(forKey: "history") as? [Date] {
            array.removeAll()
            for item in historyArray {
                array.append(History(d: item))
            }
            tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
