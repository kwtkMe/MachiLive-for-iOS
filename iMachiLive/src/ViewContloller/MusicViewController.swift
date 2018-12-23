////
////  File.swift
////  iMachiLive
////
////  Created by RIVER on 2018/12/22.
////  Copyright © 2018 Reverse. All rights reserved.
////
//
//import UIKit
//import CoreLocation
//import MapKit
//import MediaPlayer
//
//protocol MusicViewControllerDelegate
//{
//    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
//}
//
//class MusicViewController:
//    UIViewController,
//    CLLocationManagerDelegate,
//    MKMapViewDelegate,
//    MPMediaPickerControllerDelegate
//{
//
//    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
//
//        player.stop()
//        // 選択した曲情報がmediaItemCollectionに入っているので、これをplayerにセット。
//        player.setQueueWithItemCollection(mediaItemCollection)
//        // 選択した曲から最初の曲の情報を表示
//        if let mediaItem = mediaItemCollection.items.first {
//            updateSongInformationUI(mediaItem)
//        }
//        // ピッカーを閉じ、破棄
//        dismissViewControllerAnimated(true, completion: nil)
//
//    }
//
//    //選択がキャンセルされた場合に呼ばれる
//    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
//        // ピッカーを閉じ、破棄する
//        dismissViewControllerAnimated(true, completion: nil)
//    }
//
//}
