//
//  DatePickerVC.swift
//  Park
//
//  Created by Brian Lane on 11/21/16.
//  Copyright © 2016 Brian Lane. All rights reserved.
//

import UIKit
import UserNotifications

class DatePickerVC: UIViewController {
    @IBOutlet weak var datePicker: UIDatePicker!
    let meterExpirationMsgTitle: String = "Your meter has expired"
    let meterExpirationMsgBody: String = "It's time to go feed the meter or move your car."

    override func viewDidLoad() {
        super.viewDidLoad()
    }


    @IBAction func saveBtnPressed(_ sender: Any) {
        let now = Date()
        if (datePicker.date < now) {
            warnUserOfImproperDateSelection()
        } else {
        print(datePicker.date)
        registerLocal()
        scheduleLocal(localNotificationDate: datePicker.date)
        performSegue(withIdentifier: "segueToMainVC", sender: nil)
        }
    }
    
    func warnUserOfImproperDateSelection()
    {
        let alertController = UIAlertController(title: "Unusable Time", message: "You must select a time in the future", preferredStyle: UIAlertControllerStyle.alert)
        
        let submitAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
        alertController.addAction(submitAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func registerLocal()
    {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
    }
    
    func scheduleLocal(localNotificationDate: Date)
    {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = meterExpirationMsgTitle
        content.body = meterExpirationMsgBody
        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound.default()
        
        let calendar = NSCalendar.current
        
        let components = calendar.dateComponents([.month, .day, .hour, .minute], from: localNotificationDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request)
    }
    
    func calculateMeterExpiration(localNotificationDate: Date) -> Int
    {
        
        let now = Date()
        let calculatedMeterExpirationTime = -(Int(now.timeIntervalSince(localNotificationDate)))
        print("The calculated meter expiration time is /(calculatedMeterExpirationTime)!")
        if (calculatedMeterExpirationTime > 0) {
            return calculatedMeterExpirationTime
        } else {
            return 0
        }
    }

    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
