//
//  DataService.swift
//  Park
//
//  Created by Brian Lane on 10/31/16.
//  Copyright © 2016 Brian Lane. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class DataService {
    private static let _instance = DataService()
    
    static var instance: DataService {
        return _instance
    }
    
    var mainRef: FIRDatabaseReference {
        return FIRDatabase.database().reference()
    }
    
    var usersRef: FIRDatabaseReference {
        return mainRef.child("users")
    }
    
    var carsRef: FIRDatabaseReference {
        return mainRef.child("cars")
    }
    
    let uid = FIRAuth.auth()?.currentUser?.uid
    
    var currentUserId: FIRDatabaseReference {
        return usersRef.child(uid!)
    }
    
    
//    var usersCarRef: FIRDatabaseReference {
//        //this doesn't work right now, we need the child to only get the user's cars
//        if let uid = self.uid {
//            
//        return mainRef.child("users").child(uid).child(<#T##pathString: String##String#>)
//        }
//    }
    
    func saveUser(uid: String) {
        let profile: Dictionary<String, Any> = ["firstName": "", "lastName": ""]
        
        /*
        #   the following code will create these children if they don't exist,
        #   per standard Firebase behavior. The creation of the nested children 
        #   likewise creates their parents
        */
        
        mainRef.child("users").child(uid).child("profile").setValue(profile)
        
    }

    
}
