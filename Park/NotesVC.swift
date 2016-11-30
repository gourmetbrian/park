//
//  NotesVC.swift
//  Park
//
//  Created by Brian Lane on 11/28/16.
//  Copyright © 2016 Brian Lane. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class NotesVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var newNoteField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var activeRow: Int = 0
    let DEFAULT_NOTE_TEXT = "Enter note here..."
    
    var notes = [FIRDataSnapshot]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setObserver()
        newNoteField.placeholder = DEFAULT_NOTE_TEXT
    }
    
    //MARK: - Table View Source and Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        activeRow = indexPath.row
        
        launchNoteDetailAlert(indexPath: indexPath)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        if let noteForCell = notes[indexPath.row].value as? String {
            cell.textLabel?.text = noteForCell
        }
        
        return cell
    }
    
    //MARK:- Button functions
    


    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addBtnPressed(_ sender: Any) {
        let textToSave = newNoteField.text
        if (textToSave != DEFAULT_NOTE_TEXT && textToSave != nil && textToSave != "") {
            guard let uid = DataService.instance.uid else {
                print("Cannot save data to Firebase at this time.")
                return
            }
            let currentUsersCarKey = "\(uid)car"
            let date = createTimeStampWithDashes()
            
            let newFBNote = [ date : textToSave! ] as [String : String]
            print(newFBNote)
            
            DataService.instance.carsRef.child("\(currentUsersCarKey)/notes").updateChildValues(newFBNote)
            //            notes.append(textToSave!)
            tableView.reloadData()
            newNoteField.text = ""
            newNoteField.placeholder = DEFAULT_NOTE_TEXT
            dismissKeyboard()
        }
    }

    
    func deleteNote(indexPath: IndexPath)
    {
        guard let uid = DataService.instance.uid else {
            print("Cannot retrieve Firebase data at this time.")
            return
        }
        let currentUsersCarKey = "\(uid)car"
        let noteToDelete = notes[indexPath.row]
        DataService.instance.carsRef.child("\(currentUsersCarKey)/notes").child(noteToDelete.key).setValue(nil)
    }
    
    //MARK:- Utility functions
    
    func setObserver() {
        guard let uid = DataService.instance.uid else {
            return
        }
        
        let currentUsersCarKey = "\(uid)car"
        
        DataService.instance.carsRef.child("\(currentUsersCarKey)/notes").observe(.value, with: {(snapshot: FIRDataSnapshot!) in
            
            var newItems = [FIRDataSnapshot]()
            
            for item in snapshot.children {
                newItems.append(item as! FIRDataSnapshot)
            }
            
            self.notes = newItems
            self.tableView.reloadData()
        })
    }
    
    func launchNoteDetailAlert(indexPath: IndexPath) {
        
        let noteForCell = notes[indexPath.row].value as? String
        
        let alertController = UIAlertController(title: "Note", message: noteForCell, preferredStyle: UIAlertControllerStyle.alert)
        
        let OK = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
        let delete = UIAlertAction(title: "Delete", style: .default) { (UIAlertAction) in
            self.deleteNote(indexPath: indexPath)
        }
        
        alertController.addAction(OK)
        alertController.addAction(delete)
        
        self.present(alertController, animated: true, completion: nil)
    }
    

}
