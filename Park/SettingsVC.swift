//
//  SettingsVC.swift
//  Park
//
//  Created by Brian Lane on 11/7/16.
//  Copyright © 2016 Brian Lane. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        profileImage.layoutIfNeeded()
        profileImage.layer.masksToBounds = true
        self.profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.layer.borderWidth = 3
        profileImage.layer.borderColor = UIColor.white.cgColor

    }



}
