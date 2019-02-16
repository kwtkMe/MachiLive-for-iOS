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

//struct STAnnotationViewData {
//    var locationName: String?
//    var songTitle: String?
//    var songArtist: String?
//    var songArtwork: UIImage?
//}

class EditAnnotationViewController:
    UIViewController,
    UITextFieldDelegate,
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
    
    
    
    func initObservers() {
        
    }
    
    /** ----------------------------------------------------------------------
     # UI settings
     ---------------------------------------------------------------------- **/
    @IBOutlet weak var locationnameLabel: UILabel!
    @IBOutlet weak var songinfoLabel: UILabel!
    @IBOutlet weak var locationnameField: UITextField!
    @IBOutlet weak var songAlbumWorkImageView: UIImageView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initObservers()
        
        locationnameField.delegate = self
        picker.delegate = self
    }
    
    /** ----------------------------------------------------------------------
     # MPMediaPickerController()
     ---------------------------------------------------------------------- **/
    let picker = MPMediaPickerController()
    var songIdAsString: String?
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        if let mediaItem = mediaItemCollection.items.first {
            
            songTitleLabel.text = mediaItem.title ?? "不明な楽曲"
            songArtistLabel.text = mediaItem.artist ?? "不明なアーティスト"
            if let artwork = mediaItem.artwork {
                let image = artwork.image(at: songAlbumWorkImageView.bounds.size)
                songAlbumWorkImageView.image = image
            } else {
                songAlbumWorkImageView.image = nil
                songAlbumWorkImageView.backgroundColor = .lightGray
            }
            // 楽曲情報の取得(審議？)
            let songId = mediaItem.toNSNumber()!
            songIdAsString = "\(songId)"
        }
        dismiss(animated: true, completion: nil)
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    /** ----------------------------------------------------------------------
     # locationnameField
     ---------------------------------------------------------------------- **/
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        locationnameField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    /** ----------------------------------------------------------------------
     UI actions
     ---------------------------------------------------------------------- **/
    @IBAction func tapSongselectButton(_ sender: UIButton) {
        // 曲を１つ選択すると画面が戻るようにする(trueなら複数選択)
        picker.allowsPickingMultipleItems = false
        present(picker, animated: true, completion: nil)
    }
    
    // 原則アノテーションを追加するのでバリデーションしっかり
    let defaultAction = UIAlertAction(title: "OK",
                                      style: UIAlertAction.Style.default,
                                      handler:{
                                        (action: UIAlertAction!) in
                                        return
    })
    
    @IBAction func tapCompleteButton(_ sender: UIButton) {
        // バリデーション完了
        if let currentUser = userData.authUI.auth?.currentUser {
            let childPath = "users/\(currentUser.uid)/annotation"
            let post
                = ["locationName": locationnameField.text,
                   "songTitle": songTitleLabel.text,
                   "songArtist": songArtistLabel.text,
                   "songArtwork": songAlbumWorkImageView.image?.toString(),
                   "songId": songIdAsString]
            userData.ref.child(childPath).updateChildValues(post as [AnyHashable : Any])
        }
        notification.post(name: .AnnotationAddedOrEdited, object: nil)
    }
    
    @IBAction func tapCancelButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
