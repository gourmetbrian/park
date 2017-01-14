//
//  BLParkingSpot+CoreDataProperties.swift
//  Park
//
//  Created by Brian Lane on 1/13/17.
//  Copyright © 2017 Brian Lane. All rights reserved.
//

import Foundation
import CoreData


extension BLParkingSpot {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<BLParkingSpot> {
        return NSFetchRequest<BLParkingSpot>(entityName: "BLParkingSpot");
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var dateParked: NSDate?
    @NSManaged public var isActive: Bool

}
