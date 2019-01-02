//
//  Application.swift
//  iMachiLive
//
//  Created by RIVER on 2019/01/01.
//  Copyright © 2019 Reverse. All rights reserved.
//

/**
 ## 債務について
 - Applicationクラスでオブジェクトの状態を保持する
 ## オブジェクトについて
 - ユーザのオブジェクト
    - ユーザ情報読み出し or ユーザ生成
    - ピン情報のリストを管理
        - ピン情報の追加
        - ピン情報の削除
 - 音楽の再生状況オブジェクト
    - プレイヤー
 ## 初期化でやること
 - ユーザの状態をフェッチ
 - ユーザの情報をインスタンス
    - ユーザ名
    - ユーザのアイコン
    - ピンのリスト
 - FireBaseをインスタンス
 - FireBaseとユーザの情報を同期
 - プレイヤーのインスタンス
 **/

import Foundation
import UIKit

class Application: UIApplication {
    
    enum userLogin {
        case logout
        case login
    }
    
//    static let application = Application()
//    let userObject: String?
//    let pinList: String?
//    let firebase_userObject: String?
//    let firebase_pinList: String?
    
    
}
