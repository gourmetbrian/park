//
//  NotesVC.swift
//  Park
//
//  Created by Brian Lane on 11/28/16.
//  Copyright © 2016 Brian Lane. All rights reserved.
//

import UIKit
import CoreData

class NotesVC: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var newNoteField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var activeRow: Int = 0
    let DEFAULT_NOTE_TEXT = "Enter note here..."
    //Core Data vars
    var fetchedResultsController: NSFetchedResultsController<BLNote>!
    var container: NSPersistentContainer!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup(){
        tableView.dataSource = self
        tableView.delegate = self
        initializeCoreDataStack()
        loadNotesFromCoreData()
    }
    
    func initializeCoreDataStack(){
        
        container = NSPersistentContainer(name: "Park")
        
        container.loadPersistentStores { storeDescription, error in
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        newNoteField.placeholder = DEFAULT_NOTE_TEXT
    }
    
    //MARK:- Table View Source and Delegate
    
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
        let newNote = BLNote(context: container.viewContext)
        newNote.dateCreated = NSDate()
        newNote.noteText = note
        
        let parkingSpots = BLParkingSpot.createFetchRequest()
        
        if let parkingSpots = try? container.viewContext.fetch(parkingSpots) {
            if parkingSpots.count > 0 {
                parkingSpots[0].addToNotes(newNote)
            }
        }
        
        saveContext()

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
        let textIsAcceptable = (textToSave != DEFAULT_NOTE_TEXT && textToSave != nil && textToSave != "")
        if (textIsAcceptable) {
            addNoteToContext(note: textToSave!)
            newNoteField.text = ""
            newNoteField.placeholder = DEFAULT_NOTE_TEXT
            dismissKeyboard()
        }
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
    
    //MARK:- Utility functions

    
    func launchNoteDetailAlert(indexPath: IndexPath) {
        
        let noteForCell = fetchedResultsController.object(at: indexPath)
        
        let alertController = UIAlertController(title: "Note", message: noteForCell.noteText, preferredStyle: UIAlertControllerStyle.alert)
        
        let OK = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
        let delete = UIAlertAction(title: "Delete", style: .default) { (UIAlertAction) in
            self.container.viewContext.delete(noteForCell)
            self.saveContext()
        }
        
        alertController.addAction(OK)
        alertController.addAction(delete)
        
        self.present(alertController, animated: true, completion: nil)
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
