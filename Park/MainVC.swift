//
//  MainVC.swift
//  Park
//
//  Created by Brian Lane on 11/11/16.
//  Copyright © 2016 Brian Lane. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseDatabase
import UserNotifications

class MainVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    enum ParkState {
        case CAR_PARKED
        case NO_CAR_PARKED
    }
    
    enum MapState {
        case MAP_STANDARD
        case MAP_SATELLITE
        case MAP_HYBRID
    }
    
    var usercar: Car?
    var userParkingSpot: ParkingSpot?
    var annotation: MKAnnotation?
    var remainingTicks: Int = 0
    var timer: Timer?
    var meterExpirationDate: Date?
    var streetAddressMark: CLPlacemark?
    let locationManager = CLLocationManager()
    var mapHasCenteredOnce = false
    var parkState: ParkState = ParkState.NO_CAR_PARKED
    var mapState: MapState = .MAP_STANDARD
    let meterExpirationDateUserDefaults = "meterExpirationDateUserDefaults"
    var observersSet: Bool = false
    let meterExpirationMsgTitle: String = "Your meter has expired"
    let meterExpirationMsgBody: String = "It's time to go feed the meter or move your car."

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
        mapview.delegate = self
        mapview.userTrackingMode = MKUserTrackingMode.follow
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        //This prevents multiple observers calling userResignedAppWhileCarIsParked from firing
        if observersSet == true {
            removeAppDelegateObservers()
            observersSet = false
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if observersSet == false {
            
            locationAuthStatus()
            
            setFirebaseObserver()
            
            setAppDelegateObserver()
            
            observersSet = true
        }
        
        if meterExpirationDate != nil {
            calculateMeterExpiration()
            startCountdown()
        }
    }

    func locationAuthStatus()
    {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapview.showsUserLocation = true;
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func setFirebaseObserver()
    {
        if let uid = DataService.instance.uid {
            print("The uid is: \(uid)")
            let currentUsersCarKey = "\(uid)car"
            DataService.instance.carsRef.child(currentUsersCarKey).observe(.value, with: { (snapshot)
                in
                if snapshot.exists() {
                    self.usercar = Car(snapshot: snapshot)
                    if snapshot.hasChild("latitude") {
                        self.loadSavedUserCarLocation()
                        self.userParkingSpot = ParkingSpot(snapshot: snapshot)
                        let location: CLLocation = CLLocation(latitude: (self.userParkingSpot?.coordinate.latitude)!, longitude: (self.userParkingSpot?.coordinate.longitude)!)
                        self.convertParkingSpotToAddress(location: location)
                        self.parkState = ParkState.CAR_PARKED
                    } else {
                        if (self.parkState != .NO_CAR_PARKED) {
                            self.parkState = ParkState.NO_CAR_PARKED
                        }
                    }
                    self.updateGUIForMapState()
                }
            }) { (error) in
                print("The error was \(error.localizedDescription)")
            }
        }
    }
    
    func setAppDelegateObserver()
    {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(userResignedAppWhileCarIsParked), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(userReopenedAppWhileCarisParked), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    func removeAppDelegateObservers()
    {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
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
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        //This creates a custom annotation
//        
//        let annoIdentifier = "park"
//        var annotationView: MKAnnotationView?
//        
//        if annotation.isKind(of: MKUserLocation.self) {
//            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
//            annotationView?.image = UIImage(named: "car-outline")
//            annotationView?.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
//        } else
//        {
//            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annoIdentifier)
//            annotationView?.image = UIImage(named: "car-outline")
//            annotationView?.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
//        }
//        return annotationView
//    }
    
    @IBAction func parkCarBtnPressed(_ sender: AnyObject)
    {
        if (userParkingSpot == nil) {
            let userLoc = mapview.userLocation.location
            if let loc = userLoc {
                let latitude: Double = (loc.coordinate.latitude)
                let longitude: Double = (loc.coordinate.longitude)
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: latitude , longitude: longitude)
                mapview.addAnnotation(annotation)
                
                let uid = DataService.instance.uid
                if let uid = uid {
                    
                    let car = [ "owner": uid,
                                "latitude": latitude,
                                "longitude": longitude ] as [String : Any]
                    
                    let key = "\(uid)car"
                    DataService.instance.carsRef.child(key).updateChildValues(car)
                    DataService.instance.usersRef.child(uid).child("cars").setValue(["carID" : key])
                    
                    userParkingSpot = ParkingSpot(car: key, owner: uid, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                }
                parkState = ParkState.CAR_PARKED
                updateGUIForParkState()
            } else {
                locationAuthStatus()
            }
        } else {
            centerMapOnLocation(location: CLLocation(latitude: (userParkingSpot?.coordinate.latitude)!, longitude: (userParkingSpot?.coordinate.longitude)!))
        }
    }
    
    @IBAction func deleteParkingSpotBtnPressed(_ sender: AnyObject)
    {
        userParkingSpot = nil
        streetAddressMark = nil
        if let uid = DataService.instance.uid {
            let key = "\(uid)car"
            DataService.instance.carsRef.child("\(key)/latitude").setValue(nil)
            DataService.instance.carsRef.child("\(key)/longitude").setValue(nil)
            DataService.instance.carsRef.child("\(key)/notes").setValue(nil)

        }
        mapview.removeAnnotations(mapview.annotations)
        setAddressLabels()
        timer?.invalidate()
        timer = nil
        meterExpirationDate = nil
        timerLabel.text = ""
        parkState = .NO_CAR_PARKED
        updateGUIForParkState()
    }
    
    func loadSavedUserCarLocation()
    {
        let latitude = usercar?.latitude
        let longitude = usercar?.longitude
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude! , longitude: longitude!)
        mapview.addAnnotation(annotation)
        
        if let uid = DataService.instance.uid {
        userParkingSpot = ParkingSpot(car: "\(uid)car", owner: uid, coordinate: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!))
        }
    }

//    
//    func calculateSegmentDirections()
//    {
//        let request: MKDirectionsRequest = MKDirectionsRequest()
//        request.source = MKMapItem(placemark: MKPlacemark(coordinate: mapview.userLocation.coordinate))
//        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: (userParkingSpot?.coordinate)!))
//        request.requestsAlternateRoutes = false
//        request.transportType = .walking
//        
//        let directions = MKDirections(request: request)
//        
//        directions.calculate { [unowned self] response, error in
//            guard let unwrappedResponse = response else { return }
//            
//            for route in unwrappedResponse.routes {
//                self.mapview.add(route.polyline)
//                self.mapview.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
//            }
//        }
//    }
//    
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
//        renderer.strokeColor = UIColor.blue
//        return renderer
//    }

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
                self.streetAddressMark = pm
                print("####################\n####################\n##########")
                print(self.streetAddressMark.debugDescription)
                self.setAddressLabels()
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    
    func setAddressLabels()
    {
        if let locality = streetAddressMark?.locality, let street = streetAddressMark?.thoroughfare, let streetnumber = streetAddressMark?.subThoroughfare, let state = streetAddressMark?.administrativeArea, let zip = streetAddressMark?.postalCode {
            streetAddress.text = "\(streetnumber) \(street)"
             cityAddress.text = "\(locality), \(state) \(zip)"
        } else {
            streetAddress.text = "Park your car to use."
            cityAddress.text = ""
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
        default:
            break
        }
    }
    
    //MARK: - Meter Setup and update
    
//    @IBAction func meterBtnPressed(_ sender: AnyObject) {
//        registerLocal()
//        scheduleLocal()
//        calculateMeterExpiration()
//        startCountdown()
//        
//       //The below is all debug stuff
//        let alertController = UIAlertController(title: "Timer Set", message: "", preferredStyle: UIAlertControllerStyle.alert)
//        let submitAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
//            alert -> Void in
//        })
//        alertController.addAction(submitAction)
//        self.present(alertController, animated: true, completion: nil)
//    }
    
    func promptUserForMeterTime()
    {
        let alertController = UIAlertController(title: "Add Meter Time", message: "Set timer for meter", preferredStyle: UIAlertControllerStyle.alert)
        
        let submitAction = UIAlertAction(title: "Set Timer", style: UIAlertActionStyle.default, handler: {
            alert -> Void in
            
            if let task = Int((alertController.textFields?.first?.text)!) {
                self.remainingTicks = task * 60
            }
            self.startCountdown()
            
            alertController.dismiss(animated: true, completion: {
            })
        })
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter time for reminder"
        }
        alertController.addAction(submitAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
//    func createTimeStamp() -> String        {
//            let date = Date()
//            let formatter = DateFormatter()
//            formatter.dateStyle = DateFormatter.Style.long
//            formatter.timeStyle = DateFormatter.Style.medium
//            return formatter.string(from: date)
//        }
    
    func startCountdown()
    {
        if (timer != nil) {
            return
        }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MainVC.decreaseTimer), userInfo: nil, repeats: true)
    }
    
    func decreaseTimer()
    {
        if remainingTicks > 0 {
            remainingTicks -= 1
            updateDisplay()
            print(self.remainingTicks)
        }
        
            
            if remainingTicks <= 0 {
                timerLabel.text = ""
                timer?.invalidate()
                timer = nil
                meterExpirationDate = nil
                alertUserThatMeterExpired()
            }
    }
    
    func alertUserThatMeterExpired()
    {
        let ac = UIAlertController(title: meterExpirationMsgTitle, message: meterExpirationMsgBody, preferredStyle: .alert )
        
        
        let submitAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {
            alert -> Void in
            self.timerLabel.text = ""
        })

        
        ac.addAction(submitAction)
        
        self.present(ac, animated: true, completion: nil)
        
    }


    func updateDisplay()
    {
        let days: Int = remainingTicks / 86400
        let hours: Int = remainingTicks % 86400 / 3600
        let mins: Int = remainingTicks % 3600 / 60
        let secs: Int = (remainingTicks % 3600) % 60
        let timeLeftString: String = String(format: "%02d:%02d:%02d:%02d", days, hours, mins, secs)
        DispatchQueue.main.async {
                self.timerLabel.text = timeLeftString
                self.timerLabel.setNeedsDisplay()
            }
    }
    
    func registerLocal()
    {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
    }
    
    func scheduleLocal()
    {
            let center = UNUserNotificationCenter.current()
            
            let content = UNMutableNotificationContent()
        content.title = meterExpirationMsgTitle
        content.body = meterExpirationMsgBody
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"] //TODO: What is this?
        content.sound = UNNotificationSound.default()
        
//        var dateComponents = DateComponents()
        let newDate = UserDefaults.standard.object(forKey:"meterExpirationDateUserDefaults") as? Date ?? nil
        if (newDate != nil) {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(self.remainingTicks), repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
    }
    
    func saveRemainingMeterTimeToFirebase()
    {
            if let uid = DataService.instance.uid {
            DataService.instance.usersRef.child(uid).child("remainingMeterTime").setValue(remainingTicks)
            }
    }
    
    func testForMeterDate()
    {
        
        //debug-only func
        if let _ = meterExpirationDate {
        let alertController = UIAlertController(title: "Date Worked", message: "The date is \(meterExpirationDate!)", preferredStyle: UIAlertControllerStyle.alert)
        
        let submitAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {
            alert -> Void in
        })
        
        alertController.addAction(submitAction)
        
        self.present(alertController, animated: true, completion: nil)
            
        }
    }
    
    func userResignedAppWhileCarIsParked()
    {
        UserDefaults.standard.set(meterExpirationDate, forKey: meterExpirationDateUserDefaults)
        let meterUserDefaultsDate = UserDefaults.standard.object(forKey: meterExpirationDateUserDefaults)
        print("The meter expiration date is \(meterUserDefaultsDate)")
        scheduleLocal()
        if (timer != nil) {
        timer?.invalidate()
        timer = nil
        }
        
    }
    
    func userReopenedAppWhileCarisParked()
    {
        if (timer == nil) {
            let newDate = UserDefaults.standard.object(forKey:meterExpirationDateUserDefaults) as? Date ?? nil
            print("The new date is \(newDate)")
            
            if newDate != nil {
                meterExpirationDate = newDate
                UserDefaults.standard.set(nil, forKey: meterExpirationDateUserDefaults)
                //            testForMeterDate()
                calculateMeterExpiration()
                startCountdown()
            }
            
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }

    }
    
    func calculateMeterExpiration()
    {
        if let _ = meterExpirationDate {
            let now = Date()
            let calculatedMeterExpirationTime = -(Int(now.timeIntervalSince(meterExpirationDate!)))
            print("The calculated meter expiration time is /(calculatedMeterExpirationTime)!")
            if ( -(Int(now.timeIntervalSince(meterExpirationDate!))) > 0) {
                remainingTicks = -(Int(now.timeIntervalSince(meterExpirationDate!)))
            } else {
                remainingTicks = 0
            }
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
            break
        default:
            break
        }
        setAddressLabels()
    }
}
