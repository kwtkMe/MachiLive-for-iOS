//
//  PinViewController.swift
//  iMachiLive
//
//  Created by RIVER on 2019/01/26.
//  Copyright © 2019 Reverse. All rights reserved.
//

import Foundation
import UIKit

class PinEditViewController: UIViewController {
    
    // Model
    var userData = UserData.sharedInstance
    // NotificationCenter
    let notification = NotificationCenter.default
    

    @IBOutlet weak var locationnameField: UITextField!
    @IBOutlet weak var songTItleLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    @IBOutlet weak var songAlbumLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initContentsView()
    }
    
    func initContentsView() {
        
    }
    
    
    @IBAction func tapSongselectButton(_ sender: UIButton) {
        // アラートを表示して音源リソースを選択(デフォルトのライブラリ or iTunes視聴ライブラリ)
    }
    
    @IBAction func tapCompleteButton(_ sender: UIButton) {
        // バリデーションしてアノテーションとピンの情報(Firebase)を付与
        
        // 戻る
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapCancelButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
