//
//  CustomCell.swift
//  Park
//
//  Created by Brian Lane on 10/23/16.
//  Copyright © 2016 Brian Lane. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {

    @IBOutlet weak var thumbnail: UIImageView!
    
    @IBOutlet weak var nickname: UILabel!
    
    @IBOutlet weak var licensePlate: UILabel!
    
    func configureCell(car: Car)
    {
        nickname.text = car.nickname
        licensePlate.text = car.licensePlate
    }

}
