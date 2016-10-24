//
//  SettingsVCViewController.swift
//  Park
//
//  Created by Brian Lane on 10/22/16.
//  Copyright © 2016 Brian Lane. All rights reserved.
//

import UIKit

class SettingsVCViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var profilePic: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @IBAction func settingsDone(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }


}
