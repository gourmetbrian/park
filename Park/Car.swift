//
//  Car.swift
//  Park
//
//  Created by Brian Lane on 10/31/16.
//  Copyright © 2016 Brian Lane. All rights reserved.
//

import UIKit
import FirebaseDatabase

struct Car {
    let key: String
    let nickname: String
    let licensePlate: String
    let ref: FIRDatabaseReference?
    let owner: String

    init(nickname: String, licensePlate: String, owner: String, key: String = "") {
        self.key = key
        self.nickname = nickname
        self.licensePlate = licensePlate
        self.ref = nil
        self.owner = owner
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        nickname = snapshotValue["nickname"] as! String
        licensePlate = snapshotValue["license"] as! String
        owner = snapshotValue["owner"] as! String
        ref = snapshot.ref
    }

}
