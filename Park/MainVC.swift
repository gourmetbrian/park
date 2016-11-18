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
    
    var usercar: Car?
    var userParkingSpot: ParkingSpot?
    var annotation: MKAnnotation?
    @IBOutlet weak var timerLabel: UILabel!
    var remainingTicks: Int = 0
    var timer: Timer?

    var streetAddressMark: CLPlacemark?

    @IBOutlet weak var streetAddress: UILabel!
    @IBOutlet weak var mapview: MKMapView!
    @IBOutlet weak var cityAddress: UILabel!
    let locationManager = CLLocationManager()
    var mapHasCenteredOnce = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapview.delegate = self
        mapview.userTrackingMode = MKUserTrackingMode.follow
        
        setAddressLabels()
        
        if let uid = DataService.instance.uid {
            let currentUsersCarKey = "\(uid)car"
            DataService.instance.carsRef.child(currentUsersCarKey).observe(.value, with: { (snapshot) in
                if snapshot.exists() {
                    self.usercar = Car(snapshot: snapshot)
                    if snapshot.hasChild("latitude") {
                        self.loadSavedUserCarLocation()
                        self.userParkingSpot = ParkingSpot(snapshot: snapshot)
                        let location: CLLocation = CLLocation(latitude: (self.userParkingSpot?.coordinate.latitude)!, longitude: (self.userParkingSpot?.coordinate.longitude)!)
                        self.convertParkingSpotToAddress(location: location)
                    }
                    self.checkParkingStatus()
                }
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationAuthStatus()
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
                    
                    userParkingSpot = ParkingSpot(car: "\(uid)car", owner: uid, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                }
            }
        }
    }
    
    @IBAction func deleteParkingSpotBtnPressed(_ sender: AnyObject)
    {
        userParkingSpot = nil
        if let uid = DataService.instance.uid {
            let key = "\(uid)car"
            DataService.instance.carsRef.child("\(key)/latitude").setValue(nil)
            DataService.instance.carsRef.child("\(key)/longitude").setValue(nil)

        }
        mapview.removeAnnotations(mapview.annotations)
        setAddressLabels()
        timer?.invalidate()
        timer = nil
        timerLabel.text = ""
    }
    
    func checkParkingStatus()
    {

        
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
            streetAddress.text = ""
            cityAddress.text = ""
        }
    }
    
    
    @IBAction func meterBtnPressed(_ sender: AnyObject) {
        //launch alertcontroller to accept time
        registerLocal()
        promptUserForMeterTime()
        
        
    }
    
    func promptUserForMeterTime()
    {
        let alertController = UIAlertController(title: "Add Meter Time", message: "Set timer for meter", preferredStyle: UIAlertControllerStyle.alert)
        
        let submitAction = UIAlertAction(title: "Set Timer", style: UIAlertActionStyle.default, handler: {
            alert -> Void in
            
            if let task = Int((alertController.textFields?.first?.text)!) {
                self.remainingTicks = task * 60
            }
            self.startCountdown()
            self.scheduleLocal()

            alertController.dismiss(animated: true, completion: {
            })
        })
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter time for reminder"
        }
        alertController.addAction(submitAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func createTimeStamp() -> String        {
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateStyle = DateFormatter.Style.long
            formatter.timeStyle = DateFormatter.Style.medium
            return formatter.string(from: date)
        }
    
    func startCountdown()
    {
        if (timer != nil) {
            return
        }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MainVC.decreaseTimer), userInfo: nil, repeats: true)
    }
    
    func decreaseTimer()
    {
        remainingTicks -= 1
        updateDisplay()
        
        if remainingTicks == 0 {
            timerLabel.text = ""
            timer?.invalidate()
            timer = nil
        }
    }

    func updateDisplay()
    {
        let mins: String = String(format: "%02d", remainingTicks / 60)
        let secs: String = String(format: "%02d", remainingTicks % 60)
        timerLabel.text = "\(mins):\(secs)"
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
//        registerCategories()
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Your meter has expired"
        content.body = "It's time to go feed the meter or move your car."
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default()
        
        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 30
        //        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(self.remainingTicks), repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
        
    }



}
