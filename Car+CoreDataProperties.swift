//
//  Car+CoreDataProperties.swift
//  Park
//
//  Created by Brian Lane on 10/23/16.
//  Copyright © 2016 Brian Lane. All rights reserved.
//

import Foundation
import CoreData


extension Car {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Car> {
        return NSFetchRequest<Car>(entityName: "Car");
    }

    @NSManaged public var carId: String?
    @NSManaged public var toImage: Image?
    @NSManaged public var toParkingSpot: ParkingSpot?

}
