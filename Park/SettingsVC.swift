//
//  SettingsVC.swift
//  Park
//
//  Created by Brian Lane on 11/7/16.
//  Copyright © 2016 Brian Lane. All rights reserved.
//

import UIKit
import FirebaseDatabase
import MapKit

class SettingsVC: UIViewController {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    var usercar: Car?
    var userParkingSpot: ParkingSpot?
    @IBOutlet weak var parkBtn: UIButton!
    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var licensePlate: UILabel!
    @IBOutlet weak var findBtn: UIButton!
    
      override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.layoutIfNeeded()
        profileImage.layer.masksToBounds = true
        self.profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.layer.borderWidth = 3
        profileImage.layer.borderColor = UIColor.white.cgColor
        
        if let uid = DataService.instance.uid {
            let currentUsersCarKey = "\(uid)car"
            DataService.instance.carsRef.child(currentUsersCarKey).observe(.value, with: { (snapshot) in
                //print(snapshot.debugDescription)
                if snapshot.exists() {
                    self.usercar = Car(snapshot: snapshot)
//                    self.nickname.text = self.usercar?.nickname
//                    self.licensePlate.text = self.usercar?.licensePlate
                    self.userName.text = "brian's car"
                    if snapshot.hasChild("latitude") {
                        self.userParkingSpot = ParkingSpot(snapshot: snapshot)
                    }
                    self.checkParkingStatus()
                }
            })
        }
        
        checkParkingStatus()
        
    }


        @IBAction func parkBtnPressed(_ sender: AnyObject) {

            
            
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapSegue" {
            let mapVC = segue.destination as! ViewController
            mapVC.parkingSpot = userParkingSpot
        }
    }
    
    func checkParkingStatus()
    {
        if let parkedCar = userParkingSpot {
            self.parkBtn.isEnabled = false
            self.parkBtn.alpha = 0.7
            self.findBtn.isEnabled = true
            self.findBtn.alpha = 1
        } else {
            self.parkBtn.isEnabled = true
            self.parkBtn.alpha = 1.0
            self.findBtn.isEnabled = false
            self.findBtn.alpha = 1.0
            
        }
        
    }
    
    



}
