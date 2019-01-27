//
//  PlayerViewController.swift
//  iMachiLive
//
//  Created by RIVER on 2019/01/27.
//  Copyright © 2019 Reverse. All rights reserved.
//

import UIKit
import MediaPlayer


class PlayerViewController:
    UIViewController,
    MPMediaPickerControllerDelegate
{
    /** ----------------------------------------------------------------------
     # sharedInstance
     ---------------------------------------------------------------------- **/
    // Model
    var userData = UserData.sharedInstance
    var musicPlayerData = MusicPlayerData.sharedInstance
    // NotificationCenter
    let notification = NotificationCenter.default
    
    deinit {
        notification.removeObserver(self)
    }
    
    @objc func handlePlayingItemChangedNotification(_ notification: Notification) {
        if let mediaItem = musicPlayerData.player.nowPlayingItem {
            updateSongInformationUI(mediaItem: mediaItem)
        }
    }
    
    func initObservers() {
        notification.addObserver(self,
                                 selector: #selector(handlePlayingItemChangedNotification(_:)),
                                 name: .PlayingItemChanged,
                                 object: nil)
    }
    
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
        
        initObservers()
    }
    
    // 再生中の音源の変更をUIに反映させる
    func updateSongInformationUI(mediaItem: MPMediaItem) {
        playerSongtitleLabel.text = mediaItem.title ?? "不明な曲"
        playerSubtitleLabel.text = mediaItem.artist ?? "不明なアーティスト"
        
        // アートワーク表示
        if let artwork = mediaItem.artwork {
            let image = artwork.image(at: playerImageView.bounds.size)
            playerImageView.image = image
        } else {
            playerImageView.image = nil
            playerImageView.backgroundColor = .gray
        }
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
