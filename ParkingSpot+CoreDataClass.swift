//
//  ParkingSpot+CoreDataClass.swift
//  Park
//
//  Created by Brian Lane on 10/23/16.
//  Copyright © 2016 Brian Lane. All rights reserved.
//

import Foundation
import CoreData


public class ParkingSpot: NSManagedObject {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.created = NSDate()
    }

}
