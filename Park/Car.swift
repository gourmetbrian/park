//
//  Car.swift
//  Park
//
//  Created by Brian Lane on 10/31/16.
//  Copyright © 2016 Brian Lane. All rights reserved.
//

import UIKit

struct Car {
    private var _nickname: String
    private var _latitude: Double?
    private var _longitude: Double?
    private var _licensePlate: String
    
    var nickname: String {
        return _nickname
    }
    
    var latitude: Double? {
        set(newLatitude) {
            _latitude = newLatitude
        }
        get {
            return _latitude
        }
    }
    
    var longitude: Double? {
        set(newLongitude) {
            _longitude = newLongitude
        }
        get {
            return _longitude
        }
    }
    
    var licensePlate: String {
        return _licensePlate
    }
    
    init(nickname: String, licensePlate: String) {
        _nickname = nickname
        _licensePlate = licensePlate
        _longitude = nil
        _latitude = nil
    }

}
