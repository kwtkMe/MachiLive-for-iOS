//
//  LoginView.swift
//  iMachiLive
//
//  Created by RIVER on 2019/01/18.
//  Copyright © 2019 Reverse. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {
    
    /** ----------------------------------------------------------------------
     # sharedInstance
     ---------------------------------------------------------------------- **/
    // Model
    var userData = UserData.sharedInstance
    var storyboardBuilder = StoryboardBuilder.sharedInstanse

    
    
    /** ----------------------------------------------------------------------
     UI settings
     ---------------------------------------------------------------------- **/
    
    @IBOutlet weak var menuView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let menuPos = self.menuView.layer.position
        self.menuView.layer.position.x = -self.menuView.frame.width
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.menuView.layer.position.x = menuPos.x
            },
            completion: {
                bool in
            }
        )
    }
    
    
    /** ----------------------------------------------------------------------
     UI actions
     ---------------------------------------------------------------------- **/
    @IBAction func tapLogout(_ sender: UIButton) {
        do {
            try userData.authUI.signOut()
            userData.loginMode = .logout
            // MainViewController で dissmiss
            let notification = Notification(name: Notification.SoftwareRestartNotification)
            NotificationCenter.default.post(notification)
        }catch {
            print("error")
        }
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
