//
//  BLNote+CoreDataProperties.swift
//  Park
//
//  Created by Brian Lane on 1/15/17.
//  Copyright © 2017 Brian Lane. All rights reserved.
//

import Foundation
import CoreData


extension BLNote {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<BLNote> {
        return NSFetchRequest<BLNote>(entityName: "BLNote");
    }

    @NSManaged public var noteText: String
    @NSManaged public var dateCreated: NSDate
    @NSManaged public var parkingSpot: BLParkingSpot?

}
