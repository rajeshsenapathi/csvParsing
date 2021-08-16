//
//  ViewController.swift
//  csvParsing
//
//  Created by Rajesh Senapathi on 24/05/1400 AP.
//

import UIKit
import Foundation
import Contacts
struct Contact {
    let name: String
    let mobileNumber: String
}

class ViewController: UIViewController {
    var columnAstrings  = [String]()
    var some = [String]()
    var phArry = [String]()
    var contactDict: [String: String] = [:]
    var store  = CNContactStore()
    var somearr = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var data = readDataFromCSV(fileName: "Book", fileType: "csv")
        data = cleanRows(file: data!)
        let csvRows = csv(data: data!)
        let flattenArr = csvRows.flatMap({$0.split(separator: ",")})
        var contactArr =  flattenArr.compactMap({$0}).flatMap({$0})
        contactArr.removeLast()
        for val in contactArr{
            let flattenConatctArr = val.components(separatedBy: ",")
            columnAstrings.append(flattenConatctArr[0])
            phArry.append(flattenConatctArr[1])
        }
        addContactstoIphoneContacts()
    }
    
    func readDataFromCSV(fileName:String, fileType: String)-> String!{
        guard let filepath = Bundle.main.path(forResource: fileName, ofType: fileType)
        else {
            return nil
        }
        do {
            var contents = try String(contentsOfFile: filepath, encoding: .utf8)
            contents = cleanRows(file: contents)
            return contents
        } catch {
            print("File Read Error for file \(filepath)")
            return nil
        }
    }
    
    func cleanRows(file:String)->String{
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        //        cleanFile = cleanFile.replacingOccurrences(of: ";;", with: "")
        //        cleanFile = cleanFile.replacingOccurrences(of: ";\n", with: "")
        return cleanFile
    }
    
    func csv(data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ";")
            result.append(columns)
        }
        return result
    }
    
    func isContactExistsInContactStore(contactMobilenumber: String) -> Bool{
        var isContactExists = false
        let storeContacts = getContactsfFromStore()
        var contactArray = [String]()
        for contact in storeContacts{
            let flattenConatct = contact.withoutPunctuations.filter{$0 != " "}
            contactArray.append(flattenConatct)
        }
        
        if contactArray.contains(contactMobilenumber)
        {
            isContactExists = true
        }
        else{
            isContactExists = false
        }
        
        return isContactExists
    }
    
    func saveContact(name :String,phonenumber: String){
        let newContact = CNMutableContact()
        newContact.givenName = name
        if newContact.givenName == "abcd"{
            newContact.givenName = ""
        }
        newContact.phoneNumbers.append(CNLabeledValue(
                                        label: "mobile", value: CNPhoneNumber(stringValue: phonenumber)))
        let saveRequest = CNSaveRequest()
        saveRequest.add(newContact, toContainerWithIdentifier: nil)
        do {
            try store.execute(saveRequest)
        } catch {
            print("Saving contact failed, error: \(error)")
        }
    }
    
    func addContactstoIphoneContacts(){
        for (index, element) in columnAstrings.enumerated() {
            let phoneelemen = phArry[index]
            let count = phoneelemen.count
            if index == 0 || count < 10  || (element == "abcd" && (count < 10)) {
                continue
            }
            else{
                let contactData = Contact(name: (element), mobileNumber: (phoneelemen ))
                if isContactExistsInContactStore(contactMobilenumber: phoneelemen ) == true {
                    print("existed")
                }
                else{
                    saveContact(name: contactData.name, phonenumber: contactData.mobileNumber)
                }
            }
        }
        
    }
    
    func getContactsfFromStore() -> [String]{
        var phoneNumberArry =  [String]()
        let contactStore = CNContactStore()
        var contacts = [CNContact]()
        let keys = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey
        ] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        do {
            try contactStore.enumerateContacts(with: request){
                (contact, stop) in
                // Array containing all unified contacts from everywhere
                contacts.append(contact)
                for phoneNumber in contact.phoneNumbers {
                    let number = phoneNumber.value
                    phoneNumberArry.append(number.stringValue)
                }
            }
            
        } catch {
            print("unable to fetch contacts")
        }
        return phoneNumberArry
    }
}

extension String {
    var withoutPunctuations: String {
        return self.components(separatedBy: CharacterSet.punctuationCharacters).joined(separator: "")
    }
}
