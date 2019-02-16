//
//  MusicPlayer.swift
//  iMachiLive
//
//  Created by RIVER on 2019/01/27.
//  Copyright © 2019 Reverse. All rights reserved.
//

import UIKit
import MediaPlayer

class MusicPlayerData: NSObject {
    /** ----------------------------------------------------------------------
     # sharedInstance
     ---------------------------------------------------------------------- **/
    static let sharedInstance = MusicPlayerData()
    
    // NotificationCenter
    let notification = NotificationCenter.default
    
    deinit {
        notification.removeObserver(self)
        player.endGeneratingPlaybackNotifications()
    }
    
    func initObservers() {
        notification.addObserver(self,
                                 selector: #selector(handlePlayerPlayingStatusChangedNotification(_:)),
                                 name: .PlayerPlayingStatusChanged, object: nil)
        notification.addObserver(self,
                                 selector: #selector(handlePlayerRepeatStatusChangedNotification(_:)),
                                 name: .PlayerRepeatStatusChanged, object: nil)
        notification.addObserver(self,
                                 selector: #selector(handlePlayingItemChangedNotification(_:)),
                                 name: .PlayingItemChanged, object: nil)
    }
    
    @objc func handlePlayerPlayingStatusChangedNotification(_ notification: Notification){
        
    }
    
    @objc func handlePlayerRepeatStatusChangedNotification(_ notification: Notification){
        
    }
    
    @objc func handlePlayingItemChangedNotification(_ notification: Notification){
        // 曲と止めて選択されたアイテムを再生
        player.stop()
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
        
        initObservers()
        
        player = MPMusicPlayerController.systemMusicPlayer
        player.beginGeneratingPlaybackNotifications()
        player.repeatMode = .none
    }
    
}
