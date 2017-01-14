//
//  CarParkManager.swift
//  Park
//
//  Created by Brian Lane on 1/14/17.
//  Copyright © 2017 Brian Lane. All rights reserved.
//

import Foundation
import MapKit
import CoreData

class CarParkManager {
    
    static let sharedInstance = CarParkManager()
    
    private init() {
        //prevent our Singleton from being initialized multiple times
    }
    
    var container: NSPersistentContainer!
    
    var userParkingSpots = [BLParkingSpot]()
    
//    var streetAddressMark: CLPlacemark?


    
    func initializeCoreDataStack()
    {
        container = NSPersistentContainer(name: "Park")
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
    }
    
    func clearCoreDataPersistentStore()
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BLParkingSpot")
        
        // Create Batch Delete Request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try container.viewContext.execute(batchDeleteRequest)
            print("Items deleted")
            
        } catch {
            // Error Handling
        }
    }
    
    func loadParkingSpotFromCoreData()
    {
        let request = BLParkingSpot.createFetchRequest()
        let sort = NSSortDescriptor(key: "dateParked", ascending: false)
        request.sortDescriptors = [sort]
        
        do {
            userParkingSpots = try container.viewContext.fetch(request)
            if userParkingSpots.count > 0 {
//                userParkingSpotBL = userParkingSpots[0]
            }
        } catch {
            print("Fetch failed")
        }
    }
    
    func addUserLocationToContext(location: CLLocation)
    {
        if userParkingSpots.count > 0 {
            if let currentParkingSpot = userParkingSpots[0] as BLParkingSpot?  {
                currentParkingSpot.isActive = false
                saveContext()
                
            }
        }
        //mapview.userLocation.location
        let latitude: Double = (location.coordinate.latitude)
        let longitude: Double = (location.coordinate.longitude)
        let parkingSpot = BLParkingSpot(context: container.viewContext)
        parkingSpot.latitude = latitude
        parkingSpot.longitude = longitude
        parkingSpot.dateParked = Date() as NSDate?
        parkingSpot.isActive = true
        
        saveContext()
    }
    
    func dropPinOnMap(map: MKMapView)
    {
        loadParkingSpotFromCoreData()
        let currentParkingSpot = userParkingSpots[0]
        if currentParkingSpot.isActive {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: currentParkingSpot.latitude , longitude: currentParkingSpot.longitude)
            map.addAnnotation(annotation)
            let location: CLLocation = CLLocation(latitude: (annotation.coordinate.latitude), longitude: (annotation.coordinate.longitude))
        }
    }
    
    func convertParkingSpotToAddress(location: CLLocation, map: MKMapView) -> CLPlacemark
    {
        var streetAddressMark = CLPlacemark()
        let placemarks = map.annotations
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            placemarks
            
            if (placemarks?.count)! > 0 {
                let pm = placemarks?[0] as CLPlacemark!
                streetAddressMark = pm!
                print("####################\n####################\n##########")
                print(streetAddressMark.debugDescription)
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
        return streetAddressMark
    }
    
    func deleteParkingSpotFromCoreData()
    {
        let parkingSpotToDelete = userParkingSpots[0]
        container.viewContext.delete(parkingSpotToDelete)
        userParkingSpots.remove(at: 0)
        saveContext()
        print("Parking spot deleted")
    }
    
    func saveContext()
    {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }
    
    


}
