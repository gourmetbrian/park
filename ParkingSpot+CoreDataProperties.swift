//
//  ParkingSpot+CoreDataProperties.swift
//  Park
//
//  Created by Brian Lane on 10/23/16.
//  Copyright © 2016 Brian Lane. All rights reserved.
//

import Foundation
import CoreData
 

extension ParkingSpot {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ParkingSpot> {
        return NSFetchRequest<ParkingSpot>(entityName: "ParkingSpot");
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var carId: String?
    @NSManaged public var created: NSDate?
    @NSManaged public var toCar: Car?

}
