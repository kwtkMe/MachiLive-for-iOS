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
     # ENUM
     ---------------------------------------------------------------------- **/
    // ログインの可否のみを判別してUIを切り替えられるよう、定義
    enum LoginMode {
        case logout
        case login
    }
    // Firebaseの状態を監視して更新
    var loginMode: LoginMode = .logout
    
    
    /** ----------------------------------------------------------------------
     # FirebaseAuth
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
        
        //        // FirebaseData
        //        let firebaseData = FirebaseData()
        //        if firebaseData.isLogin() {
        //            loginMode = .login
        //            // ログイン情報を取得
        ////            loginData =
        //            firebaseData.getUserData()
        //        }else {
        //            loginMode = .logout
        //        }
    }
    
    // FirabaseUIのデリゲートメソッド
    public func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?){
        // 認証に成功した場合
        if error == nil {
            loginMode = .login
        }
        // エラー時
    }
    
    
    /** ----------------------------------------------------------------------
     # FirebaseData
     ---------------------------------------------------------------------- **/
    // ログイン情報を保持
//    private var loginData
    
    // loginData を返す
    func getUserData() {
        
    }
    
}

class FirebaseData {
    var username: String?
    var avatar: String?
    
    init() {
        getUserData()
    }
    
    func getUserData()
    // -> KOUZOUTAI
    {
        // ログインしているサービスごとにメソッドを振り分けて、構造体を返す
    }
    
    // ログイン状態の可否
    func isLogin() -> Bool{
        // ログインしていればtrue
        return true
    }
}
