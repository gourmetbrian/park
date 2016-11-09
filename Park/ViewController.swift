//
//  ViewController.swift
//  Park
//
//  Created by Brian Lane on 10/22/16.
//  Copyright © 2016 Brian Lane. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseDatabase

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate  {

    @IBOutlet weak var mapview: MKMapView!
    var parkingSpot: ParkingSpot?
    
    let locationManager = CLLocationManager()
    
    var mapHasCenteredOnce = false

    override func viewDidLoad() {
        super.viewDidLoad()
        mapview.delegate = self
//        mapview.userTrackingMode = MKUserTrackingMode.follow
        if let parkingSpotData = parkingSpot {
            loadParkingSpotView()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
//        guard FIRAuth.auth()?.currentUser != nil else {
//            performSegue(withIdentifier: "toLogin", sender: nil)
//            return
//        }
//        force login screen to appear
//        performSegue(withIdentifier: "toLogin", sender: nil)

        locationAuthStatus()
    }
    
    func locationAuthStatus()
    {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
//            mapview.showsUserLocation = true;
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func centerMapOnLocation(location: CLLocation)
    {
        //TODO: This doesn't zoom in as much as we'd like
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 5, 5)
        mapview.setRegion(coordinateRegion, animated: true)
    }
    
//    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//        //centers the map only if it hasn't been centered before
//        if let loc = userLocation.location {
//            if !mapHasCenteredOnce {
//                centerMapOnLocation(location: loc)
//                mapHasCenteredOnce = true
//            }
//        }
//    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //This creates a custom annotation
        
        let annoIdentifier = "park"
        var annotationView: MKAnnotationView?
        
        if annotation.isKind(of: MKUserLocation.self) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
            annotationView?.image = UIImage(named: "add")
            annotationView?.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        } else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Park")
            annotationView?.image = UIImage(named: "car-outline")
            annotationView?.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        }
        return annotationView
    }
    
    @IBAction func parkCarBtnPressed(_ sender: AnyObject) {
        let annotation = MKPointAnnotation()
        
        let latitude = mapview.centerCoordinate.latitude
        let longitude = mapview.centerCoordinate.longitude
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude , longitude: longitude)
        mapview.addAnnotation(annotation)
        
        if let uid = DataService.instance.uid {
            
            let location = [ "latitude" : latitude,
                             "longitude" : longitude]
        DataService.instance.carsRef.child("\(uid)car").updateChildValues(location)
        }
    }
    
    func loadParkingSpotView() {
        let latitude: CLLocationDegrees = (parkingSpot?.coordinate.latitude)!
        
        let longitude: CLLocationDegrees = (parkingSpot?.coordinate.longitude)!
        
        let lanDelta: CLLocationDegrees = 0.1
        
        let lonDelta: CLLocationDegrees = 0.1
        
        let span = MKCoordinateSpan(latitudeDelta: lanDelta, longitudeDelta: lonDelta)
        
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let region = MKCoordinateRegion(center: coordinates, span: span)
        
        mapview.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        
        annotation.title = "Your car is parked here"
        
        annotation.subtitle = "Hold for directions"
        
        annotation.coordinate = (parkingSpot?.coordinate)!
        
        mapview.addAnnotation(annotation)
    }
    
    
    


}

