//
//  DatePickerVC.swift
//  Park
//
//  Created by Brian Lane on 11/21/16.
//  Copyright © 2016 Brian Lane. All rights reserved.
//

import UIKit

class DatePickerVC: UIViewController {
    @IBOutlet weak var datePicker: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    @IBAction func saveBtnPressed(_ sender: Any) {
        let now = Date()
        if (datePicker.date < now) {
            warnUserOfImproperDateSelection()
        } else {
        print(datePicker.date)
        performSegue(withIdentifier: "segueToMainVC", sender: nil)
        }
    }
    
    func warnUserOfImproperDateSelection()
    {
        let alertController = UIAlertController(title: "Unusable Time", message: "You must select a time in the future", preferredStyle: UIAlertControllerStyle.alert)
        
        let submitAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {
            alert -> Void in
        })
        
        alertController.addAction(submitAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToMainVC" {
            let mainVC = segue.destination as! MainVC
            
            mainVC.meterExpirationDate = datePicker.date
        }
    }


}
