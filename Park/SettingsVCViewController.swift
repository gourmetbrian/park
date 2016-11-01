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
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.blue

        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = UITableViewCell()
        
        return cell
    }
    
    func configureCell(cell: CustomCell, indexPath: NSIndexPath)
    {

        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        

        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    @IBAction func settingsDone(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}
