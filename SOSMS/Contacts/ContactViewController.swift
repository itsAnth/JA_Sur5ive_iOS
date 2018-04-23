//
//  ContactViewController.swift
//  SOSMS
//
//  Created by SAP008 on 2018-02-08.
//  Copyright © 2018 jasap. All rights reserved.
//

import UIKit

class ContactViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Controller Variables
    var array = [Contact]()
    var refreshControl: UIRefreshControl?
    
    // Storyboard Variables
    @IBOutlet weak var tableView: UITableView!
    
    // Storyboard Methods
    @IBAction func addContactButtonPressed(_ sender: Any) {
        guard let contactsArray = UserDefaults.standard.array(forKey: "contacts") as? [Dictionary<String, String>] else {
            errorWithMessage(message: "Error adding new contact.")
            return
        }
        if contactsArray.count < 5 {
            performSegue(withIdentifier: "addAContact", sender: self)
        } else {
            errorWithMessage(message: "Max number of contacts is 5.")
        }
    }
    
    
    // Helper Functions
    func errorWithMessage(message: String) {
        
        // Stop refresh indicator
        self.refreshControl?.endRefreshing()
        
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func reloadContacts() {
        if let contactsArray = UserDefaults.standard.array(forKey: "contacts") as? [Dictionary<String, String>] {
            array.removeAll()
            for item in contactsArray {
                if let firstName = item["FIRST_NAME"], let lastName = item["LAST_NAME"], let phoneNumber = item["PHONE_NUMBER"] {
                    array.append(Contact(firstName: firstName, lastName: lastName, phoneNumber: phoneNumber))
                }
            }
        }
        guard isViewLoaded else {
            self.refreshControl?.endRefreshing()
            return
        }
        tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    // MARK: - Tablview Data Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") {
            cell.textLabel?.text = array[indexPath.row].firstName + " " + array[indexPath.row].lastName
            cell.detailTextLabel?.text = array[indexPath.row].phoneNumber
            return cell
        } else {
            let blankCell = UITableViewCell()
            blankCell.textLabel?.text = "Add Contact"
            return blankCell
        }
    }
    
    // MARK: - TableView Delegate Methods
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete, var contactsArray = UserDefaults.standard.array(forKey: "contacts") {
            array.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
            contactsArray.remove(at: indexPath.row)
            UserDefaults.standard.set(contactsArray, forKey: "contacts")
        }
    }
    
    // Standard Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        DataManager.shared.firstVC = self
        
        if let contactsArray = UserDefaults.standard.array(forKey: "contacts") as? [Dictionary<String, String>] {
            for item in contactsArray {
                if let firstName = item["FIRST_NAME"], let lastName = item["LAST_NAME"], let phoneNumber = item["PHONE_NUMBER"] {
                    array.append(Contact(firstName: firstName, lastName: lastName, phoneNumber: phoneNumber))
                }
            }
        }
        
        // Pull to refresh the table data
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.backgroundColor = .purple
        self.refreshControl?.tintColor = .white
        self.refreshControl?.addTarget(self, action: #selector(reloadContacts), for: .valueChanged)
        tableView.addSubview(self.refreshControl!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // External Helper Functions
    func refreshContactTable() {
        if let contactsArray = UserDefaults.standard.array(forKey: "contacts") as? [Dictionary<String, String>] {
            array.removeAll()
            for item in contactsArray {
                if let firstName = item["FIRST_NAME"], let lastName = item["LAST_NAME"], let phoneNumber = item["PHONE_NUMBER"] {
                    array.append(Contact(firstName: firstName, lastName: lastName, phoneNumber: phoneNumber))
                }
            }
        }
        guard isViewLoaded else {
            return
        }
        tableView.reloadData()
    }
    
    func deleteContact(indexPath: IndexPath) {
        if var contactsArray = UserDefaults.standard.array(forKey: "contacts") {
            array.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
            contactsArray.remove(at: indexPath.row)
            UserDefaults.standard.set(contactsArray, forKey: "contacts")
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditContactView" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destVC = segue.destination as! EditContactViewController
                destVC.contactToEdit = array[indexPath.row]
                destVC.contactIndex = indexPath
            }
        }
    }
}
