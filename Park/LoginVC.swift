//
//  LoginVC.swift
//  Park
//
//  Created by Brian Lane on 10/27/16.
//  Copyright © 2016 Brian Lane. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginVC: UIViewController {

    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var passwordField: CustomTextField!
    @IBOutlet weak var emailField: CustomTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }


    @IBAction func loginPressed(_ sender: AnyObject) {
        if let email = emailField.text, let pass = passwordField.text, (email.characters.count > 0 && pass.characters.count > 0 ) {
            
            AuthService.instance.login(email: email, password: pass, state: segment.selectedSegmentIndex, onComplete: { (errMsg, data) in
                guard errMsg == nil else {
                    let alert = UIAlertController(title: "Error Authentication", message: errMsg, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                self.dismiss(animated: true, completion: nil)
                
            })
            
            
        } else {
            let alert = UIAlertController(title: "Username and Password Required", message: "You must enter a username and password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            

        }
    }

}
