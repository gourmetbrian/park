//
//  SettingsVCViewController.swift
//  Park
//
//  Created by Brian Lane on 10/22/16.
//  Copyright © 2016 Brian Lane. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SettingsVCViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var profilePic: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var userCar: Car?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.blue
        
        if let uid = DataService.instance.uid {
            let currentUsersCarKey = "\(uid)car"
            DataService.instance.carsRef.child(currentUsersCarKey).observe(.value, with: { (snapshot) in
                //print(snapshot.debugDescription)
                if snapshot.exists() {
                    self.userCar = Car(snapshot: snapshot)
                    print(self.userCar?.nickname)
                    self.tableView.reloadData()
                }
            })
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        //        let cell = UITableViewCell()
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCell
        configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
        return cell
    }
    
    func configureCell(cell: CustomCell, indexPath: NSIndexPath)
    {
        if let car = userCar {
            cell.configureCell(car: car)
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    @IBAction func settingsDone(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
}
