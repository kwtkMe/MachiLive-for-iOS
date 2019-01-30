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

struct STAnnotationViewData {
    var locationName: String?
    var songTitle: String?
    var songArtist: String?
    var songArtwork: UIImage?
}

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
    var editAnnoatationData = EditAnnotationData.sharedInstance
    // NotificationCenter
    let notification = NotificationCenter.default
    
    deinit {
        notification.removeObserver(self)
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
        
        locationnameField.delegate = self
        picker.delegate = self
    }
    
    /** ----------------------------------------------------------------------
     # Media
     ---------------------------------------------------------------------- **/
    let picker = MPMediaPickerController()
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        musicPlayerData.player.setQueue(with: mediaItemCollection)
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
        }
        dismiss(animated: true, completion: nil)
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        // ピッカーを閉じ、破棄する
        dismiss(animated: true, completion: nil)
    }
    
    /** ----------------------------------------------------------------------
     # AnnotationViewInfo
     ---------------------------------------------------------------------- **/
    var annotationViewInfo = STAnnotationViewData()
    
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
        // (未実装)アラートを表示して音源リソースを選択(デフォルトのライブラリ or iTunes視聴ライブラリ)
        
        // デフォルトのミュージックライブラリを開く
        picker.allowsPickingMultipleItems = false
        present(picker, animated: true, completion: nil)
    }
    
    // 原則アノテーションを追加するのでバリデーションしっかり
    let defaultAction = UIAlertAction(title: "OK",
                                      style: UIAlertAction.Style.default,
                                      handler:{
                                        (action: UIAlertAction!) in
    })
    
    @IBAction func tapCompleteButton(_ sender: UIButton) {
        if (locationnameLabel.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            let alert = UIAlertController(title: "入力エラー",
                                          message: "地名を入力してください",
                                          preferredStyle: UIAlertController.Style.alert)
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
            return
        } else if 20 < (locationnameLabel.text?.characters.count)! {
            let alert = UIAlertController(title: "入力エラー",
                                          message: "地名を20字以内で入力してください",
                                          preferredStyle: UIAlertController.Style.alert)
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
            return
        } else if (songTitleLabel.text?.isEmpty)! {
            let alert = UIAlertController(title: "入力エラー",
                                          message: "楽曲を選択してください",
                                          preferredStyle: UIAlertController.Style.alert)
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
            return
        }
        editAnnoatationData.editedAnnotationViewInfo
            = STAnnotationViewData(locationName: locationnameField.text,
                                   songTitle: songTitleLabel.text,
                                  songArtist: songArtistLabel.text,
                                  songArtwork: songAlbumWorkImageView.image)
        notification.post(name: .AnnotationEdited, object: nil)
    }
    
    @IBAction func tapCancelButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
