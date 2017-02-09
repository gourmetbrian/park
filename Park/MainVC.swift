//
//  MainVC.swift
//  Park
//
//  Created by Brian Lane on 11/11/16.
//  Copyright © 2016 Brian Lane. All rights reserved.
//

import UIKit
import MapKit
import UserNotifications
import CoreData

class MainVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, NSFetchedResultsControllerDelegate {
    
    enum ParkState {
        case CAR_PARKED
        case NO_CAR_PARKED
    }
    
    enum MapState {
        case MAP_STANDARD
        case MAP_SATELLITE
        case MAP_HYBRID
    }
    
    var userParkingSpotBL: BLParkingSpot?
    
    var annotation: MKAnnotation?
    
    let locationManager = CLLocationManager()
    var mapHasCenteredOnce = false
    var parkState: ParkState = .NO_CAR_PARKED
    var mapState: MapState = .MAP_STANDARD


    //Core Data vars
    var container: NSPersistentContainer!
    var fetchedResultsController: NSFetchedResultsController<BLParkingSpot>!
    var userParkingSpots = [BLParkingSpot]()
    var parkingSpotPersist: BLParkingSpot?

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var streetAddress: UILabel!
    @IBOutlet weak var mapview: MKMapView!
    @IBOutlet weak var cityAddress: UILabel!

    @IBOutlet weak var mapBtn: CustomButton!
    @IBOutlet weak var notesBtn: CustomButton!
    @IBOutlet weak var meterBtn: CustomButton!
    @IBOutlet weak var trashBtn: CustomButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func loadParkedCarFromCoreData()
    {
        
        let request = BLParkingSpot.createFetchRequest()
        let sort = NSSortDescriptor(key: "dateParked", ascending: false)
        request.sortDescriptors = [sort]
        
        do {
            userParkingSpots = try
            container.viewContext.fetch(request)
            print("Got \(userParkingSpots.count) parkingSpots")
        } catch {
            print("Fetch failed.")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        locationAuthStatus()
        
        setup()
    }
    
    func dropPinOnMap(forParkingSpot: BLParkingSpot)
    {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: forParkingSpot.latitude , longitude: forParkingSpot.longitude)
        mapview.addAnnotation(annotation)
    }

    func locationAuthStatus()
    {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapview.showsUserLocation = true;
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func centerMapOnLocation(location: CLLocation)
    {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 0.01, 0.01)
        mapview.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        //centers the map only if it hasn't been centered before
        if let loc = userLocation.location {
            if !mapHasCenteredOnce {
                centerMapOnLocation(location: loc)
                mapHasCenteredOnce = true
            }
        }
    }


    //MARK: - park and delete parking spot buttons
    @IBAction func parkCarBtnPressed(_ sender: AnyObject)
    {
        if (parkState == .NO_CAR_PARKED) {
            let userLoc = mapview.userLocation.location
            guard let location = userLoc else {
                print("Failed to get user location.")
                return
            }
            
            let userParkingSpot = BLParkingSpot(context: container.viewContext)
            userParkingSpot.dateParked = NSDate()
            userParkingSpot.latitude = location.coordinate.latitude
            userParkingSpot.longitude = location.coordinate.longitude
            userParkingSpot.isActive = true
            
            saveContext()
            
            parkingSpotPersist = userParkingSpot
            dropPinOnMap(forParkingSpot: userParkingSpot)
            print(userParkingSpot.debugDescription)
            parkState = .CAR_PARKED
            updateGUIForParkState()
            
        } else {

            let userParkingSpot = userParkingSpots[0]
            let loc = CLLocation(latitude: userParkingSpot.latitude, longitude: userParkingSpot.longitude)
            centerMapOnLocation(location: loc)
        }
    }
    
    @IBAction func deleteParkingSpotBtnPressed(_ sender: AnyObject)
    {
        
        let alertController = UIAlertController(title: "Delete Parking Spot", message: "Delete your parking spot and all its data?", preferredStyle: UIAlertControllerStyle.alert)
        let submitAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default, handler: {
            alert -> Void in
            
            var notes: [BLNote] = [BLNote]()
            if (self.parkingSpotPersist?.notes.count)! > 0 {
                for note in (self.parkingSpotPersist?.notes)! {
                    notes.append(note as! BLNote)
                }
                for note in notes {
                    self.container.viewContext.delete(note)
                }
            }
            self.container.viewContext.delete(self.parkingSpotPersist!)
            self.parkingSpotPersist = nil
            self.saveContext()
            self.setAddressLabels(streetAddressMark: nil)
            self.mapview.removeAnnotations(self.mapview.annotations)
            
            self.parkState = .NO_CAR_PARKED
            self.updateGUIForParkState()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
        }
        
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }

    func convertParkingSpotToAddress(location: CLLocation)
        
    {
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            print(location)
            
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if (placemarks?.count)! > 0 {
                let pm = placemarks?[0] as CLPlacemark!
                let streetAddressMark = pm
                self.setAddressLabels(streetAddressMark: streetAddressMark!)
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    func setAddressLabels(streetAddressMark: CLPlacemark?)
    {
        guard let locality = streetAddressMark?.locality, let street = streetAddressMark?.thoroughfare, let streetnumber = streetAddressMark?.subThoroughfare, let state = streetAddressMark?.administrativeArea, let zip = streetAddressMark?.postalCode else {
            DispatchQueue.main.async {
                self.streetAddress.text = "Park your car to use."
                self.cityAddress.text = ""
            }
            return
        }
        DispatchQueue.main.async {
            self.streetAddress.text = "\(streetnumber) \(street)"
            self.cityAddress.text = "\(locality), \(state) \(zip)"
        }
    }
    
    //MARK: - Map Manipulation
    
    @IBAction func mapBtnPressed(_ sender: Any) {
        let ac = UIAlertController(title: "Choose a map style", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Standard", style: .default, handler: setMapState))
        ac.addAction(UIAlertAction(title: "Satellite", style: .default, handler: setMapState))
        ac.addAction(UIAlertAction(title: "Hybrid", style: .default, handler: setMapState))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func setMapState(action: UIAlertAction!) {
        switch action.title!.lowercased() {
        case "standard":
            mapState = .MAP_STANDARD
            updateGUIForMapState()
            break
        case "satellite":
            mapState = .MAP_SATELLITE
            updateGUIForMapState()
            break
        case "hybrid":
            mapState = .MAP_HYBRID
            updateGUIForMapState()
            break
        default:
            break
        }
    }
    
    func updateGUIForMapState()
    {
        switch self.mapState {
        case .MAP_STANDARD:
            mapview.mapType = MKMapType.standard
            break
        case .MAP_SATELLITE:
            mapview.mapType = MKMapType.satellite
            break
        case .MAP_HYBRID:
            mapview.mapType = MKMapType.hybrid
            break
        }
    }
    
    func updateGUIForParkState()
    {
        switch self.parkState {
        case ParkState.CAR_PARKED:
            
            mapBtn.isEnabled = true
            mapBtn.alpha = 1
            meterBtn.isEnabled = true
            meterBtn.alpha = 1
            notesBtn.isEnabled = true
            notesBtn.alpha = 1
            trashBtn.isEnabled = true
            trashBtn.alpha = 1

            let parkingSpot = parkingSpotPersist
            let loc = CLLocation(latitude: (parkingSpot?.latitude)!, longitude: (parkingSpot?.longitude)!)
            convertParkingSpotToAddress(location: loc)
            
            break
        case ParkState.NO_CAR_PARKED:
            mapBtn.isEnabled = false
            mapBtn.alpha = 0.6
            meterBtn.isEnabled = false
            meterBtn.alpha = 0.6
            notesBtn.isEnabled = false
            notesBtn.alpha = 0.6
            trashBtn.isEnabled = false
            trashBtn.alpha = 0.6
            setAddressLabels(streetAddressMark: nil)
            break
        }
    }
    
    //MARK:- CoreData funcs
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            dropPinOnMap(forParkingSpot: anObject as! BLParkingSpot)
            print("Parking spot added")
            break
            
        case .delete:
            deleteAllNotes()
            print("Delete happened")
        default:
            print("Default happened")
        }
    }
    
    func setup()
    {
        mapview.delegate = self
        mapview.userTrackingMode = MKUserTrackingMode.follow
        initializeCoreDataStack()
        loadParkedCarFromCoreData()
        if userParkingSpots.count > 0 {
            parkingSpotPersist = userParkingSpots[0]
            dropPinOnMap(forParkingSpot: parkingSpotPersist!)
            parkState = .CAR_PARKED
        }
        updateGUIForParkState()
    }
    
    func initializeCoreDataStack(){
        
        container = NSPersistentContainer(name: "Park")
        
        container.loadPersistentStores { storeDescription, error in
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            if let error = error {
                
                let alertController = UIAlertController(title: "There was a problem", message: "There was a problem loading your parking spot: \(error)", preferredStyle: UIAlertControllerStyle.alert)
                
                let submitAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
                alertController.addAction(submitAction)
                self.present(alertController, animated: true, completion: nil)
                
                
            }
        }
    }
    
    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                let alertController = UIAlertController(title: "Error saving parking spot", message: "There was an error saving your parking spot: \(error)", preferredStyle: UIAlertControllerStyle.alert)
                
                let submitAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
                alertController.addAction(submitAction)
                self.present(alertController, animated: true, completion: nil)

            }
        }
    }
    func deleteAllNotes() {
        let notesRequest = BLNote.createFetchRequest()
        if let notes = try? container.viewContext.fetch(notesRequest) {
            if notes.count > 0 {
                for note in notes {
                    container.viewContext.delete(note)
                }
                saveContext()
            }
        }
    }

}
