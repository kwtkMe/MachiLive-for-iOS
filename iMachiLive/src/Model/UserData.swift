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
    // FirebaseUIの状態を保持
    var authUI: FUIAuth { get { return FUIAuth.defaultAuthUI()!}}
    // プロバイダの設定
    let providers: [FUIAuthProvider] = [
        FUIGoogleAuth(),
        FUITwitterAuth(),
    ]
    
    /** ----------------------------------------------------------------------
     # init()
     ---------------------------------------------------------------------- **/
    private override init() {
        super.init()
        
        // FirebaseUI
        authUI.delegate = self
        authUI.providers = providers
    }
    
    // FirabaseUIのデリゲートメソッド
    public func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?){
        // 認証に成功した場合
        if error == nil {
            notification.post(name: .LogIn, object: nil)
        }
        // エラー時
    }
    
}
