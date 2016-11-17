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

class MainVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var usercar: Car?
    var userParkingSpot: ParkingSpot?
    var annotation: MKAnnotation?
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

}
