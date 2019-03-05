//
//  ViewController.swift
//  Practice-Contacts
//
//  Created by Tom on 12/18/18.
//  Copyright © 2018 Tom. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class ViewController: UIViewController {
    
    var addStatus: Bool = false
    var deleteStatus: Bool = false
    var exportVCardStatus: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if addStatus == true
        {
            let alert = UIAlertController(title: "Adding Status", message: "Success!", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            addStatus = false
        }
        else if deleteStatus == true
        {
            let alert = UIAlertController(title: "Deleting Status", message: "Success!", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            deleteStatus = false
        }
        else if exportVCardStatus == true
        {
            let alert = UIAlertController(title: "Exporting/Importing Status", message: "Success!", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            exportVCardStatus = false
        }
    }
    
    // MARK: Show contact list
    @IBAction func showContactsTapped(_ sender: Any) {
        let picker = CNContactPickerViewController()
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    // MARK: Add a new contact
    @IBAction func addContactTapped(_ sender: Any) {
        addStatus = true
        let newContact = CNMutableContact()
        let controller = CNContactViewController(forUnknownContact: newContact)
        controller.contactStore = CNContactStore()
        controller.delegate = self
        controller.allowsActions = false
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: Delete a contact
    @IBAction func deleteContactTapped(_ sender: Any) {
        deleteStatus = true
        let picker = CNContactPickerViewController()
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func deleteContact(with contact: CNMutableContact)
    {
        let req = CNSaveRequest()
        let store = CNContactStore()
        req.delete(contact)
        do{
            try store.execute(req)
        }catch{
            print("\(error.localizedDescription)")
        }
    }
    
    // MARK: Export/Import a contact to/from a VCard (.vcf)
    @IBAction func exportVCardTapped(_ sender: Any) {
        exportVCardStatus = true
        let picker = CNContactPickerViewController()
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func exportToVcard(with name: String)
    {
        let toFetch = [CNContactViewController.descriptorForRequiredKeys()]
        let predicate = CNContact.predicateForContacts(matchingName: name)
        
        let store = CNContactStore()
        do
        {
            let fetchedContacts = try store.unifiedContacts(matching: predicate, keysToFetch: toFetch)
            if fetchedContacts.count > 0
            {
                let data = try CNContactVCardSerialization.data(with: fetchedContacts)
                
                if let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                {
                    let fileURL = directoryURL.appendingPathComponent("\(name).vcf")
                    try data.write(to: fileURL)
                    print(fileURL.absoluteString)
                }
            }
        }catch{
            print("\(error.localizedDescription)")
        }
    }
}

extension ViewController: CNContactPickerDelegate, CNContactViewControllerDelegate
{
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        
        let currentContact = contact.mutableCopy() as! CNMutableContact
        
        if deleteStatus == true
        {
            deleteContact(with: currentContact)
        }
        else if exportVCardStatus == true
        {
            exportToVcard(with: currentContact.givenName)
        }
        else
        {
            let controller = CNContactViewController(for: currentContact)
            controller.allowsEditing = true
            controller.contactStore = CNContactStore()
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
