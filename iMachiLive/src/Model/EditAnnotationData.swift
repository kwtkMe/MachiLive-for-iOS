//
//  EditAnnotationData.swift
//  iMachiLive
//
//  Created by RIVER on 2019/01/28.
//  Copyright © 2019 Reverse. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

class EditAnnotationData: NSObject {
    // EditAnnotationVC to MainVC
    /** ----------------------------------------------------------------------
     # EditAnnotationData()
     ---------------------------------------------------------------------- **/
    static let sharedInstance = EditAnnotationData()
    
    
    /** ----------------------------------------------------------------------
     # init()
     ---------------------------------------------------------------------- **/
    private override init() {
        editedAnnotationViewInfo = STAnnotationViewData()
        
        super.init()
    }
    
    /** ----------------------------------------------------------------------
     # annotationView
     ---------------------------------------------------------------------- **/
    var editedAnnotationViewInfo: STAnnotationViewData
}


public struct STAnnotationInfoViewData {
    
    /** ----------------------------------------------------------------------
     # AnnotationInfoViewData
     
     ## How to
     - MainViewControllerで表示するAnnotationInfoViewの情報
     - Firebaseに保存する
     - ログインユーザが持つannotationはcoordinateの一意性を利用して反映させる
     - ユーザ情報のリアルタイム性を担保するためにUIDのみを取得
     - annotationのタップ時、保有しているcoordinateをキーにアクセス、ビューに反映させる
     
     ## property
     - locationName
     - songTitle
     - songArtist
     - songArtwork
     
     - coordinate
     - originalAuthUID // ピンを作成したユーザのUID、ユーザアイコンとユーザ名を反映
     ---------------------------------------------------------------------- **/
    var locationName: String?
    var songTitle: String?
    var songArtist: String?
    var songArtwork: UIImage?
    var coordinate: MKCoordinateSpan?
    var originalAuthUID: String?
}
