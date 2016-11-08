//
//  ParkingSpot.swift
//  Park
//
//  Created by Brian Lane on 11/7/16.
//  Copyright © 2016 Brian Lane. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class ParkingSpot: NSObject, MKAnnotation {
    var car: String?
    var owner: String?
    var timeStamp: String
    var coordinate: CLLocationCoordinate2D
    
    init(car: String, owner: String, timeStamp: String, coordinate: CLLocationCoordinate2D)
    {
        self.car = car
        self.owner = owner
        self.timeStamp = timeStamp
        self.coordinate = coordinate
    }
    
    
//    init(snapshot: FIRDataSnapshot) {
//        key = snapshot.key
//        let snapshotValue = snapshot.value as! [String: AnyObject]
//        nickname = snapshotValue["nickname"] as! String
//        licensePlate = snapshotValue["license"] as! String
//        owner = snapshotValue["owner"] as! String
//        ref = snapshot.ref
//    }
    
    init(snapshot: FIRDataSnapshot)
    {
        let snapshotValue = snapshot.value as! [String: Any]
        car = snapshotValue["nickname"] as! String?
        owner = snapshotValue["owner"] as! String?
        timeStamp = (snapshotValue["timeParked"] as! String?)!
        let latitude = CLLocationDegrees((snapshotValue["latitude"] as! Double?)!)
        let longitude = CLLocationDegrees((snapshotValue["longitude"] as! Double?)!)
        let FIRcoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        coordinate = FIRcoordinate

    }
    
    
    
    
    
    
    
    
    
    
    

}
