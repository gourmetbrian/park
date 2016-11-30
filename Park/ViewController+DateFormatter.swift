//
//  ViewController+DateFormatter.swift
//  Park
//
//  Created by Brian Lane on 11/29/16.
//  Copyright © 2016 Brian Lane. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func createTimeStamp() -> String
    {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.short
        formatter.timeStyle = DateFormatter.Style.short
        
        return formatter.string(from: date)
    }
    
    func createTimeStampWithDashes() -> String
    {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH''mm''ss'"
        
        return formatter.string(from: date)
    }
}
