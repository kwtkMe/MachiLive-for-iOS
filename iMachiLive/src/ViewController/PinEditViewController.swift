//
//  PinViewController.swift
//  iMachiLive
//
//  Created by RIVER on 2019/01/26.
//  Copyright © 2019 Reverse. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

class PinEditViewController:
    UIViewController,
    UITextFieldDelegate
{
    
    /** ----------------------------------------------------------------------
     # sharedInstance
     ---------------------------------------------------------------------- **/
    // Model
    var userData = UserData.sharedInstance
    // NotificationCenter
    let notification = NotificationCenter.default
    
    /** ----------------------------------------------------------------------
     UI settings
     ---------------------------------------------------------------------- **/
    @IBOutlet weak var locationnameField: UITextField!
    @IBOutlet weak var songTItleLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    @IBOutlet weak var songAlbumLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationnameField.delegate = self
    }
    
    /** ----------------------------------------------------------------------
     # locationnameField
     ---------------------------------------------------------------------- **/
    // 入力でリターンした時キーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        locationnameField.resignFirstResponder()
        return true
    }
    
    // キーボード以外の部分をタップするとキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    /** ----------------------------------------------------------------------
     UI actions
     ---------------------------------------------------------------------- **/
    @IBAction func tapSongselectButton(_ sender: UIButton) {
        // (未実装)アラートを表示して音源リソースを選択(デフォルトのライブラリ or iTunes視聴ライブラリ)
        
        // デフォルトのミュージックライブラリを開く
        
        
    }
    
    @IBAction func tapCompleteButton(_ sender: UIButton) {
        // バリデーションしてアノテーションとピンの情報(Firebase)を付与
        
        // 戻る
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapCancelButton(_ sender: UIButton) {
        // 戻る
        self.dismiss(animated: true, completion: nil)
    }
    
}
