//
//  ViewController.swift
//  iMachiLive
//
//  Created by RIVER on 2018/12/20.
//  Copyright © 2018 Reverse. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import MediaPlayer
import Firebase
import FirebaseUI

class ViewController:
    UIViewController,
    MKMapViewDelegate,
    CLLocationManagerDelegate,
    MPMediaPickerControllerDelegate,
    FUIAuthDelegate
{
    
    /** ----------------------------------------------------------------------
     # Models
     ---------------------------------------------------------------------- **/
    var userData = UserData.sharedInstance
    var viewControllerBuilder = ViewControllerBuilder.sharedInstanse
    
    
    /** ----------------------------------------------------------------------
     # ENUM
     ---------------------------------------------------------------------- **/
    enum TrakingMode {
        case moving
        case staying
    }
    var trackingMode: TrakingMode = .staying
    
    
    /** ----------------------------------------------------------------------
     # UI settings
    ---------------------------------------------------------------------- **/
    // main
    @IBOutlet weak var mainMapView: MKMapView!
    @IBOutlet weak var trakingModeSwitch: UISwitch!
    // pinView
    
    // delegatations
    var locationManager: CLLocationManager!
    var player: MPMusicPlayerController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSubview()
        initSubviewLayout()
        initSubviewConfiguration()
        showLoginViewController()
    }
    
    private func initSubview() {
        
    }
    
    private func initSubviewLayout() {
        
    }
    
    private func initSubviewConfiguration() {
        // MapView
        locationManager = CLLocationManager()
        locationManager.delegate = self
        mainMapView.delegate = self
        setupLocationManager()
        let mapViewCenterDefault = CLLocationCoordinate2DMake(35.5, 139.8)
        let coordinateSpanDefault = MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        let regionDefault = MKCoordinateRegion(center: mapViewCenterDefault, span: coordinateSpanDefault)
        mainMapView.setRegion(regionDefault, animated:true)
        // PinView
    }
    
    public func showLoginViewController() {
        switch userData.loginMode {
        case .logout:
            let authViewController = userData.authUI.authViewController()
            self.present(authViewController, animated: true, completion: nil)
        case .login:
            break
        }
    }
    
    // 位置情報の設定を適用
    func setupLocationManager() {
        if locationManager != nil { return }
        locationManager.requestWhenInUseAuthorization()
        mainMapView.showsUserLocation = false
        mainMapView.userTrackingMode = MKUserTrackingMode.none
    }
    
    
    /** ----------------------------------------------------------------------
     # PinView settings
     
     ## ビューの種類について
    
     - ビューの表示形態は
         1. .normal
         2. .selected
         3. .expanded
        の3つを用意したい
     
     - .normal
        - ピンを何も選択していない状態
        - 検索できることを想定
     
     - .selected
        - ピンを選択した状態
        - 以下の情報を表示
            1. 登録した位置情報についての名前
            2. 現在地点からの距離
            3. 共有ボタン(ピンの情報を共有)
            4. 編集ボタン(ピンの登録情報更新)
            5. .normalにもどる(選択解除)ためのボタン
     
     - .expanded
        - ピンを選択した上で、PinViewをタップorスワイプした状態
        - 表示する内容の情報量を想定し、スクロールできるように実装
        - .selected のビューの下部にさらに以下の情報を表示
            1. 登録した楽曲のジャケット写真
            2. iPhoneのプレイヤー準拠の再生ステータス(再生/一時停止)ボタン
            3. 楽曲のタイトル名、アーティスト名、アルバム名
            4. 登録したユーザのアイコン
            5. 登録したユーザの名前、登録日
            6. (ピンの)削除ボタン
     ---------------------------------------------------------------------- **/
    //    // 初期状態のアノテーションビューを返す
    //    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    //
    //        if annotation is MKUserLocation {return nil}
    //
    //        let annotationIdNothingselected = "nothing"
    //
    //        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdNothingselected)
    //        let button = UIButton.init(type: .detailDisclosure)
    //        annotationView.rightCalloutAccessoryView = button
    //        annotationView.canShowCallout = true
    //        annotationView.animatesDrop = true
    //
    //        return annotationView
    //    }
    
    // ピンの削除ボタンを押下した時
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            // アラートを定義
            let cancelAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                (action: UIAlertAction!) in
            })
            let defaultAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                (action: UIAlertAction!) in
                mapView.removeAnnotation(view.annotation!)
            })
            let alert = UIAlertController(title: "ピンを削除", message: "本当に削除しますか？", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    /** ----------------------------------------------------------------------
     # UI actions
     ---------------------------------------------------------------------- **/
    // マップを長押しした際の処理
    @IBAction func longpressMap(_ sender: UILongPressGestureRecognizer) {
        
        // タップされた位置情報をもとに、アノテーションを作成
        let location:CGPoint = sender.location(in: mainMapView)
        let mapPoint:CLLocationCoordinate2D
            = mainMapView.convert(location, toCoordinateFrom: mainMapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(mapPoint.latitude, mapPoint.longitude)
        
        // アラートを作成
        let cancelAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
            (action: UIAlertAction!) in
        })
        let defaultAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) in
            // 画面遷移、ピンのための情報を取得
            
            // アノテーションための最低限のデータを付与
            annotation.title = "nothig_selected"
            annotation.subtitle = "guest_user"
            self.mainMapView.addAnnotation(annotation)
        })
        let alert = UIAlertController(title: "ピンを登録", message: "楽曲を登録しますか？", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        
        // マップから指を離した際にアラートを呼ぶ
        if sender.state == UIGestureRecognizer.State.ended {
            present(alert, animated: true, completion: nil)
        }
    }
    
    // (位置情報の追跡モード)スイッチを切り替えた際の処理
    @IBAction func changeTrackingMode(_ sender: UISwitch) {
        switch self.trackingMode {
        case .moving:
            trakingModeSwitch.isOn = false
            mainMapView.userTrackingMode = MKUserTrackingMode.none
            self.trackingMode = .staying
        case .staying:
            trakingModeSwitch.isOn = true
            mainMapView.setCenter(mainMapView.userLocation.coordinate, animated: true)
            mainMapView.userTrackingMode = MKUserTrackingMode.follow
            self.trackingMode = .moving
        }
    }
    
    // ログインボタン(ログイン中はユーザアイコン)を押した際の処理
    @IBAction func tapLoginButton(_ sender: UIButton) {
        let viewController = viewControllerBuilder.buildUserViewController()
        self.present(viewController, animated: true, completion: nil)
    }
    
}

