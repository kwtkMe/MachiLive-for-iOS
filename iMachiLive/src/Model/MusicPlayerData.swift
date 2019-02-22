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
    
    /** ----------------------------------------------------------------------
     # player
     ---------------------------------------------------------------------- **/
    var player: MPMusicPlayerController!
    var handler: MPMusicPlaybackState!
    
    
    /** ----------------------------------------------------------------------
     # init()
     ---------------------------------------------------------------------- **/
    private override init() {
        super.init()
        
        player = MPMusicPlayerController.systemMusicPlayer
        player.beginGeneratingPlaybackNotifications()
        player.repeatMode = .none
    }
    
}
