//
//  NotesVC.swift
//  Park
//
//  Created by Brian Lane on 11/28/16.
//  Copyright © 2016 Brian Lane. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseAuth
import FirebaseDatabase

class NotesVC: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var newNoteField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var activeRow: Int = 0
    let DEFAULT_NOTE_TEXT = "Enter note here..."
    let nm = NotesManager.sharedInstance
    var fetchedResultsController: NSFetchedResultsController<BLNote>!
    var container: NSPersistentContainer!



    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        container = NSPersistentContainer(name: "Park")

        container.loadPersistentStores { storeDescription, error in
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
        
        loadNotesFromCoreData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        newNoteField.placeholder = DEFAULT_NOTE_TEXT
    }
    
    //MARK: - Table View Source and Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        activeRow = indexPath.row
        
        launchNoteDetailAlert(indexPath: indexPath)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let note = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = note.noteText
        
        return cell
    }
    
    
    
    func addNoteToContext(note: String)
    {
        let newNote = NSEntityDescription.entity(forEntityName: "BLNote", in: container.viewContext)
        
        let record = NSManagedObject(entity: newNote!, insertInto: container.viewContext)
        
        record.setValue(Date() as NSDate, forKey: "dateCreated")
        record.setValue(note, forKey: "noteText")
        
        do {
            try record.managedObjectContext?.save()
        } catch {
            print("There was a problem saving.")
        }

    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
    
    //MARK:- Button functions
    


    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addBtnPressed(_ sender: Any) {
        let textToSave = newNoteField.text
        //TODO convert this to a variable
        if (textToSave != DEFAULT_NOTE_TEXT && textToSave != nil && textToSave != "") {
            addNoteToContext(note: textToSave!)
            newNoteField.text = ""
            newNoteField.placeholder = DEFAULT_NOTE_TEXT
            dismissKeyboard()
        }
//        tableView.reloadData()
    }
    
    func loadNotesFromCoreData()
    {
        if fetchedResultsController == nil {
            let request = BLNote.createFetchRequest()
            let sort = NSSortDescriptor(key: "dateCreated", ascending: false)
            
            request.sortDescriptors = [sort]
            
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController.delegate = self
        }
        
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            print("Fetch failed")
        }
    }
    

    
    func deleteNote(indexPath: IndexPath)
    {
//        guard let uid = DataService.instance.uid else {
//            print("Cannot retrieve Firebase data at this time.")
//            return
//        }
//        let currentUsersCarKey = "\(uid)car"
//        let noteToDelete = notes[indexPath.row]
//        DataService.instance.carsRef.child("\(currentUsersCarKey)/notes").child(noteToDelete.key).setValue(nil)
    }
    
    //MARK:- Utility functions
    
//    func setObserver() {
//        guard let uid = DataService.instance.uid else {
//            return
//        }
//        
//        let currentUsersCarKey = "\(uid)car"
//        
//        DataService.instance.carsRef.child("\(currentUsersCarKey)/notes").observe(.value, with: {(snapshot: FIRDataSnapshot!) in
//            
//            var newItems = [FIRDataSnapshot]()
//            
//            for item in snapshot.children {
//                newItems.append(item as! FIRDataSnapshot)
//            }
//            
//            self.notes = newItems
//            self.tableView.reloadData()
//        })
//    }
    
    func launchNoteDetailAlert(indexPath: IndexPath) {
        
//        let noteForCell = nm.notes[indexPath.row].noteText
//        
//        let alertController = UIAlertController(title: "Note", message: noteForCell, preferredStyle: UIAlertControllerStyle.alert)
//        
//        let OK = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
//        let delete = UIAlertAction(title: "Delete", style: .default) { (UIAlertAction) in
//            self.deleteNote(indexPath: indexPath)
//        }
//        
//        alertController.addAction(OK)
//        alertController.addAction(delete)
//        
//        self.present(alertController, animated: true, completion: nil)
    }

    
    
    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }
}
