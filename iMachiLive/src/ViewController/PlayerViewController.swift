//
//  PlayerViewController.swift
//  iMachiLive
//
//  Created by RIVER on 2019/01/27.
//  Copyright © 2019 Reverse. All rights reserved.
//

import Foundation
import UIKit

class PlayerViewController: UIViewController {
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
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var playerImageView: UIImageView!
    @IBOutlet weak var playerSongtitleLabel: UILabel!
    @IBOutlet weak var playerSubtitleLabel: UILabel!
    @IBOutlet weak var playerStatusButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    /** ----------------------------------------------------------------------
     UI actions
     ---------------------------------------------------------------------- **/
    @IBAction func tapPlayerStatusButton(_ sender: UIButton) {
        
    }
    
    // エリア外のタップをした際の処理
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch in touches {
            if touch.view?.tag == 1 {
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0,
                    options: .curveEaseIn,
                    animations: {
                        self.menuView.layer.position.x = -self.menuView.frame.width
                },
                    completion: { bool in
                        self.dismiss(animated: true, completion: nil)
                }
                )
            }
        }
    }
}
