//
//  ParkAnnotationModel.swift
//  Park
//
//  Created by Brian Lane on 10/22/16.
//  Copyright © 2016 Brian Lane. All rights reserved.
//

import UIKit
import MapKit

class ParkAnnotationModel: NSObject {
    
    var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D, pokemonNumber: Int)
    {
        self.coordinate = coordinate
    }

}
