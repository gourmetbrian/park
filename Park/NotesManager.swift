//
//  NotesManager.swift
//  Park
//
//  Created by Brian Lane on 1/15/17.
//  Copyright © 2017 Brian Lane. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class NotesManager {
    
    static let sharedInstance = NotesManager()
    
    private init() {
        //prevents our Singleton from being initialized multiple times
    }
    
    var notes = [BLNote]()
    var fetchedResultsController: NSFetchedResultsController<BLNote>!
    var container: NSPersistentContainer = CarParkManager.sharedInstance.container

    
    func loadNotesFromCoreData() -> Bool
    {
        let notesRequest = BLNote.createFetchRequest()
        let sort = NSSortDescriptor(key: "dateCreated", ascending: false)
        notesRequest.sortDescriptors = [sort]
        do {
             notes = try container.viewContext.fetch(notesRequest)
            if notes.count > 0 {
                return true
            } else {
                return false
            }
        } catch {
            print("Fetch failed")
            return false
        }
    }
    
    func addNoteToContext(note: String, tableView: UITableView)
    {
        let newNote = BLNote(context: container.viewContext)
        newNote.dateCreated = Date() as NSDate
        newNote.noteText = note
        newNote.parkingSpot = CarParkManager.sharedInstance.userParkingSpots[0]
        
        saveContext(tableView: tableView)
    }
    
    func saveContext(tableView: UITableView)
    {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
                tableView.reloadData()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }
    
}
