//
//  UserData.swift
//  iMachiLive
//
//  Created by RIVER on 2019/01/20.
//  Copyright © 2019 Reverse. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

// Firebaseに保存されているデータを保持
class UserData: NSObject, FUIAuthDelegate {
    /** ----------------------------------------------------------------------
     # UserData()
     ---------------------------------------------------------------------- **/
    static let sharedInstance = UserData()
    
    
    /** ----------------------------------------------------------------------
     # sharedInstance
     ---------------------------------------------------------------------- **/
    // NotificationCenter
    let notification = NotificationCenter.default
    
    
    /** ----------------------------------------------------------------------
     # Firebase
     ---------------------------------------------------------------------- **/
    var authUI: FUIAuth { get { return FUIAuth.defaultAuthUI()!}}
    var handle = Auth.auth()
    let providers: [FUIAuthProvider] = [
        FUIGoogleAuth(),
        FUITwitterAuth(),
        ]
    
    var ref: DatabaseReference!
    
    /** ----------------------------------------------------------------------
     # init()
     ---------------------------------------------------------------------- **/
    private override init() {
        super.init()
        
        authUI.delegate = self
        authUI.providers = providers
        
        ref = Database.database().reference()
        
        handle.addStateDidChangeListener{ (auth, user) in
            self.notification.post(name: .LoginstateChanged, object: nil)
        }
    }
    
    public func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?){
        if error == nil {
        }
    }
    
}
