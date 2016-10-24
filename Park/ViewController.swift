//
//  ViewController.swift
//  Park
//
//  Created by Brian Lane on 10/22/16.
//  Copyright © 2016 Brian Lane. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate  {

    @IBOutlet weak var mapview: MKMapView!
    let locationManager = CLLocationManager()
    var mapHasCenteredOnce = false


    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapview.delegate = self
        mapview.userTrackingMode = MKUserTrackingMode.follow

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
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 5, 5)
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //This creates a custom annotation
        
        let annoIdentifier = "park"
        var annotationView: MKAnnotationView?
        
        if annotation.isKind(of: MKUserLocation.self) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
            annotationView?.image = UIImage(named: "add")
            annotationView?.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        }
//        } else if let deqAnno = mapView.dequeueReusableAnnotationView(withIdentifier: annoIdentifier) {
//            annotationView = deqAnno
//            annotationView?.annotation = annotation
//        } 
//        else {
//            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annoIdentifier)
//            av.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//            annotationView = av
//        }
//
//        if let annotationView = annotationView, let anno = annotation as? ParkAnnotationModel {
//            annotationView.canShowCallout = true
//            annotationView.image = UIImage(named: "car")
//            let btn = UIButton()
//            btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
//            btn.setImage(UIImage(named: "map"), for: .normal)
//            annotationView.rightCalloutAccessoryView = btn
//        }
        
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Park")
            annotationView?.image = UIImage(named: "car")
            annotationView?.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            
        }
        return annotationView
    }
    
    
    
    
    @IBAction func parkCarBtnPressed(_ sender: AnyObject) {
        
        let location = CLLocation(latitude: mapview.centerCoordinate.latitude, longitude: mapview.centerCoordinate.longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: mapview.centerCoordinate.latitude, longitude: mapview.centerCoordinate.longitude)
        mapview.addAnnotation(annotation)
        
    }
    
    
    
    


}

