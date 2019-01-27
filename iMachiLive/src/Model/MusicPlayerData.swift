//
//  MusicPlayer.swift
//  iMachiLive
//
//  Created by RIVER on 2019/01/27.
//  Copyright © 2019 Reverse. All rights reserved.
//

import UIKit
import MediaPlayer

class MusicPlayerData:
    NSObject,
    MPMediaPickerControllerDelegate
{
    /** ----------------------------------------------------------------------
     # MusicPlayerData()
     ---------------------------------------------------------------------- **/
    static let sharedInstance = MusicPlayerData()
    
    /** ----------------------------------------------------------------------
     # sharedInstance
     ---------------------------------------------------------------------- **/
    // NotificationCenter
    let notification = NotificationCenter.default
    
    deinit {
        notification.removeObserver(self)
        player.endGeneratingPlaybackNotifications()
    }
    
    // ログインした場合
    // 認証したアカウントのユーザーアイコンを表示
    @objc func handlePlayingItemChangedNotification(_ notification: Notification) {
        
    }
    
    func initObservers() {
        notification.addObserver(self,
                                 selector: #selector(handlePlayingItemChangedNotification(_:)),
                                 name: .LogIn,
                                 object: nil)
    }
    
    
    /** ----------------------------------------------------------------------
     # player
     ---------------------------------------------------------------------- **/
    var player: MPMusicPlayerController!
    
    /** ----------------------------------------------------------------------
     # init()
     ---------------------------------------------------------------------- **/
    private override init() {
        super.init()
        
        player = MPMusicPlayerController.systemMusicPlayer
        player.beginGeneratingPlaybackNotifications()
        
        initObservers()
    }
    
}
