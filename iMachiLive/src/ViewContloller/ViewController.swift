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

class ViewController:
    UIViewController,
    MKMapViewDelegate,
    CLLocationManagerDelegate,
    MPMediaPickerControllerDelegate
{
    
    enum TrakingMode {
        case moving
        case staying
    }
    
    var mode: TrakingMode = .staying
    
    /**
     Main view
    **/
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var mainMapView: MKMapView!
    @IBOutlet weak var trakingModeLabel: UILabel!
    @IBOutlet weak var trakingModeSwitch: UISwitch!
    
//    let loginView: UIView!
//    let pinViewNormal: UIView!
//    let pinViewSelected: UIView!
//    let pinViewExpanded: UIView!
    
    // constant
    let loginView_marginTop = 100
    let pinView_marginTop = 150
    let animationDuaration: TimeInterval = 1.0
    
    /**
     delegatations
     **/
    var locationManager: CLLocationManager!
    var player: MPMusicPlayerController!
    
    // MARK: methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // pinViewの初期設定
        
        // loginViewの初期設定

        // mapViewの初期設定
        locationManager = CLLocationManager()
        locationManager.delegate = self
        mainMapView.delegate = self
        setupLocationManager()
        let mapViewCenterDefault = CLLocationCoordinate2DMake(35.5, 139.8)
        let coordinateSpanDefault = MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        let regionDefault = MKCoordinateRegion(center: mapViewCenterDefault, span: coordinateSpanDefault)
        mainMapView.setRegion(regionDefault, animated:true)
    }
    
    // 位置情報の設定を適用
    func setupLocationManager() {
        if locationManager != nil { return }
        locationManager.requestWhenInUseAuthorization()
        mainMapView.userTrackingMode = MKUserTrackingMode.follow
        mainMapView.showsUserLocation = true
    }

    
    // for map view
    // マップを長押しした時
    // 楽曲情報を登録(移譲する)
    @IBAction func longpressMap(_ sender: UILongPressGestureRecognizer) {
        // タップされた位置情報を取得
        let location:CGPoint = sender.location(in: mainMapView)
        let mapPoint:CLLocationCoordinate2D
            = mainMapView.convert(location, toCoordinateFrom: mainMapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(mapPoint.latitude, mapPoint.longitude)
        // アラートを定義
        let alert = UIAlertController(title: "ピンを登録", message: "楽曲を登録しますか？", preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
            (action: UIAlertAction!) in
        })
        let defaultAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) in
            annotation.title = "nothig_selected"
            annotation.subtitle = "guest_user"
            self.mainMapView.addAnnotation(annotation)
        })
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        if sender.state == UIGestureRecognizer.State.ended {
            present(alert, animated: true, completion: nil)
        }
    }
    // 初期状態のアノテーションビューを設定
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // ユーザの現在位置をデフォルトのシステムビューを使って表示(ひどい仕様)
        if annotation is MKUserLocation {return nil}
    
        let annotationIdNothingselected = "nothing"
        
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdNothingselected)
        let button = UIButton.init(type: .detailDisclosure)
        annotationView.rightCalloutAccessoryView = button
        annotationView.canShowCallout = true
        annotationView.animatesDrop = true
        
        return annotationView
    }
    // ピンの削除ボタンを押下した時
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            // アラートを定義
            let alert = UIAlertController(title: "ピンを削除", message: "本当に削除しますか？", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                (action: UIAlertAction!) in
            })
            let defaultAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                (action: UIAlertAction!) in
                mapView.removeAnnotation(view.annotation!)
            })
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    // change "TrackingMode"
    // 維持情報の追跡モードスイッチを切り替える
    @IBAction func switchTrackingMode(_ sender: UISwitch) {
        changeTrakingMode()
    }
    // 位置情報の追跡モードを切り替える
    func changeTrakingMode(){
        switch self.mode {
        case .moving:
            trakingModeSwitch.isOn = false
            trakingModeLabel.text = "staying"
            mainMapView.userTrackingMode = MKUserTrackingMode.none
            self.mode = .staying
        case .staying:
            trakingModeSwitch.isOn = true
            trakingModeLabel.text = "moving"
            mainMapView.setCenter(mainMapView.userLocation.coordinate, animated: true)
            mainMapView.userTrackingMode = MKUserTrackingMode.follow
            self.mode = .moving
        }
    }
    
    /**
     ListView
    **/
    
    
    
    // for change view(MusicView,ListView)
    // ハンバーガービューを開く
    @IBAction func tapListButton(_ sender: UIButton) {
        
    }
    // プレイヤービューを開く(アプリ内のもの)
    @IBAction func tapMusicButton(_ sender: UIButton) {
        
    }
    // 左右のビューが展開している時に外をタップ
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
    }
    // 左右のビューを変形
    func transitionSlideViewController(tag: Int) {
        
    }
    
}
