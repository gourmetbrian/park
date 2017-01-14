//
//  AuthService.swift
//  Park
//
//  Created by Brian Lane on 10/30/16.
//  Copyright © 2016 Brian Lane. All rights reserved.
//

import Foundation
import FirebaseAuth

typealias Completion = (_ errMsg: String?, _ data: Any?) -> Void


class AuthService {
    private static let _instance = AuthService()
    
    static var instance: AuthService {
        return _instance
    }
    
    func login(email: String, password: String, state: Int, onComplete: Completion?)
    {
        if state == 0 {
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                if error != nil {
                    self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
                } else {
                    if user?.uid != nil {
                        
                        DataService.instance.saveUser(uid: user!.uid)
                        //Sign in
                        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                            if error != nil {
                                self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
                            } else {
                                onComplete?(nil, user)
                            }
                        })
                    }
                }
            })
            
        } else {
            
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                
                if error != nil {
                        self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
                } else {
                    //Successfully logged in
                    onComplete?(nil, user)
                }
                
            })
            
        }

    }
    
    func handleFirebaseError(error: NSError, onComplete: Completion?) {
        print(error.debugDescription)
        if let errorCode = FIRAuthErrorCode(rawValue: error._code) {
            switch (errorCode) {
            case .errorCodeInvalidEmail:
                onComplete?("Invalid email address", nil)
                break
            case .errorCodeWrongPassword:
                onComplete?("The password is invalid or the user does not have a password", nil)
                break
            case .errorCodeEmailAlreadyInUse, .errorCodeAccountExistsWithDifferentCredential:
                onComplete?("Could not create account, email already in use.", nil)
                break
            default:
                onComplete?("An unknown error occurred. Please try again.", nil)
                break
            }
        }
    }
}
