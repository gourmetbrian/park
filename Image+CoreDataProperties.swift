//
//  Image+CoreDataProperties.swift
//  Park
//
//  Created by Brian Lane on 10/23/16.
//  Copyright © 2016 Brian Lane. All rights reserved.
//

import Foundation
import CoreData

extension Image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image");
    }

    @NSManaged public var image: NSObject?
    @NSManaged public var toCar: Car?

}
