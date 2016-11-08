//
//  AddCarVC.swift
//  Park
//
//  Created by Brian Lane on 10/25/16.
//  Copyright © 2016 Brian Lane. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class AddCarVC: UIViewController {
    
    @IBOutlet weak var licensePlateTextField: CustomTextField!
    @IBOutlet weak var nicknameTextField: CustomTextField!
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
    }
    
    
    @IBAction func saveCarBtnPressed(_ sender: AnyObject) {
        
        nicknameTextField.isEnabled = false
        licensePlateTextField.isEnabled = false
        let nickname = nicknameTextField.text!
        let license = licensePlateTextField.text!
        let uid = DataService.instance.uid
        
        
        if let uid = uid {
            
            let car = ["nickname" : nickname,
                       "license" : license ,
                       "owner" : uid ]
            
            let key = "\(uid)car"
            DataService.instance.carsRef.child(key).updateChildValues(car)
            DataService.instance.usersRef.child(uid).child("cars").setValue(["carID" : key])
            
            nicknameTextField.isEnabled = true
            licensePlateTextField.isEnabled = true
            nicknameTextField.text = ""
            licensePlateTextField.text = ""
        }
    }
    
    @IBAction func carAddedDone(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
   
}
