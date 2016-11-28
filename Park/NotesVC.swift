//
//  NotesVC.swift
//  Park
//
//  Created by Brian Lane on 11/28/16.
//  Copyright © 2016 Brian Lane. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class NotesVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var newNote: UITextView!
    @IBOutlet weak var tableView: UITableView!
    var activeRow: Int = 0
    let DEFAULT_NOTE_TEXT = "Enter note here..."
    
    var notes = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        notes.append("This is a fake note.")
        notes.append("Another fake note.")
        notes.append("So fake!.")
        //TODO: - implement custom text view so text deletes on selection
        
        loadFirebaseNotes()
        tableView.reloadData()

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
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
        
        cell.textLabel?.text = "\(notes[indexPath.row])"
        
        return cell
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        let textToSave = newNote.text
        if (textToSave != DEFAULT_NOTE_TEXT && textToSave != nil && textToSave != "") {
            guard let uid = DataService.instance.uid else {
                print("Cannot save data to Firebase at this time.")
                return
            }
            let currentUsersCarKey = "\(uid)car"
            
            let newFBNote = [textToSave! : true ] as [String : Bool]
    
            DataService.instance.carsRef.child("\(currentUsersCarKey)/notes").updateChildValues(newFBNote)
            notes.append(textToSave!)
            tableView.reloadData()
            newNote.text = DEFAULT_NOTE_TEXT
        }
    }

    @IBAction func backBtnPressed(_ sender: Any) {
    }
    
    func launchNoteDetailAlert(indexPath: IndexPath) {
        
        let alertController = UIAlertController(title: "Note", message: "\(notes[indexPath.row])", preferredStyle: UIAlertControllerStyle.alert)
        
        let OK = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
        let delete = UIAlertAction(title: "Delete", style: .default) { (UIAlertAction) in
            self.deleteNote(indexPath: indexPath)
            self.tableView.reloadData()
        }
        
        alertController.addAction(OK)
        alertController.addAction(delete)

        self.present(alertController, animated: true, completion: nil)
    }
    
    func deleteNote(indexPath: IndexPath)
    {
        notes.remove(at: indexPath.row)
    }
    
    func loadFirebaseNotes()
    {
        guard let uid = DataService.instance.uid else {
            print("Cannot retrieve Firebase data at this time.")
            return
        }
        let currentUsersCarKey = "\(uid)car"
        DataService.instance.carsRef.child("\(currentUsersCarKey)/notes").observe(.value, with: { (snapshot) in
            if snapshot.exists() {
                let snapshotValue = snapshot.value as! [String: String]
                for note in snapshotValue {
                    self.notes.append(note.value)
                }
            }
        })
    }
}
