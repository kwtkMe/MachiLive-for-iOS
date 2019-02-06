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
    
    var handle = Auth.auth()

//    // ログイン画面を返す(未実装)
//    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
//        return FUIAuthPickerViewController(nibName: "FUICustomAuthPickerViewController",
//                                                 bundle: Bundle.main,
//                                                 authUI: authUI)
//    }
    
    /** ----------------------------------------------------------------------
     # init()
     ---------------------------------------------------------------------- **/
    private override init() {
        super.init()
        
        // FirebaseUI
        authUI.delegate = self
        authUI.providers = providers
        
        handle.addStateDidChangeListener{ (auth, user) in
            self.notification.post(name: .LoginstateChanged, object: nil)
        }
    }
    
    // FirabaseUIのデリゲートメソッド
    public func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?){
        // 認証に成功した場合
        if error == nil {
            
        }
        if authUI.auth?.currentUser == nil {
            self.notification.post(name: .LoginstateChanged, object: nil)
        }
    }
    
}
