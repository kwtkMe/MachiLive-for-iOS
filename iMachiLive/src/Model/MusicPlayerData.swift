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
     # MusicPlayerData()
     ---------------------------------------------------------------------- **/
    static let sharedInstance = MusicPlayerData()
    
    
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
    }
    
}
