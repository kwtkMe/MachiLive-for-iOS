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
    CLLocationManagerDelegate,
    MKMapViewDelegate,
    MPMediaPickerControllerDelegate
{
    
    enum TrakingMode {
        case moving
        case staying
    }
    
    // MARK: UI
    // View
    @IBOutlet weak var leftContainerView: UIView! {
        didSet {
            guard let viewController = UIStoryboard(name: "Music", bundle: nil).instantiateInitialViewController() else { return }
            leftContainerView.frame = leftContainerViewInitFrame
            leftContainerView.addSubview(viewController.view)
        }
    }
    @IBOutlet weak var rightContainerView: UIView! {
        didSet {
            guard let viewController = UIStoryboard(name: "List", bundle: nil).instantiateInitialViewController() else { return }
            rightContainerView.frame = leftContainerViewInitFrame
            rightContainerView.addSubview(viewController.view)
        }
    }
    // etc.
    @IBOutlet weak var trakingModeLabel: UILabel!
    @IBOutlet weak var trakingModeSwitch: UISwitch!
    @IBOutlet weak var mainMapView: MKMapView!

    // Frame
    private let leftContainerViewInitFrame = CGRect(
        x: -UIScreen.main.bounds.width, y: 0,
        width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height
    )
    private let rightContainerViewInitFrame = CGRect(
        x: UIScreen.main.bounds.width, y: 0,
        width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height
    )
    private let containerViewDispFrame = CGRect(
        x: 0, y: 0,
        width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height
    )
    // other field
    var mode: TrakingMode = .staying
    var myLocationManager: CLLocationManager!
    var player: MPMusicPlayerController!

    
    // MARK: methods
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // プレイヤーの開始
//        player.prepareToPlay { (Error?) in
//
//        }
        // 位置情報の許可
        setupLocationManager()
        // mainMapViewの初期化
        mainMapView.delegate = self
        let mapViewCenterDefault = CLLocationCoordinate2DMake(35.5, 139.8)
        let coordinateSpanDefault = MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        let regionDefault = MKCoordinateRegion(center: mapViewCenterDefault, span: coordinateSpanDefault)
        mainMapView.setRegion(regionDefault, animated:true)
    }
    
    // 現在のビューコントローラを返す
    func getTopViewController() -> UIViewController? {
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            var topViewControlelr: UIViewController = rootViewController
            
            while let presentedViewController = topViewControlelr.presentedViewController {
                topViewControlelr = presentedViewController
            }
            return topViewControlelr
        } else {
            return nil
        }
    }
    
    // for side view(MusicView,ListView)
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch in touches {
            if let view = touch.view {
                transitionSlideViewController(tag: view.tag)
            }
        }
    }
    func transitionSlideViewController(tag: Int) {
        if tag == 100 {
            UIView.animate(withDuration: 0.3, animations: {
                self.rightContainerView.frame = self.rightContainerViewInitFrame
            })
        } else if tag == 200 {
            UIView.animate(withDuration: 0.3, animations: {
                self.leftContainerView.frame = self.leftContainerViewInitFrame
            })
        }
    }
    
    // for traking view
    func setupLocationManager() {
        if myLocationManager != nil { return }
        myLocationManager = CLLocationManager()
        myLocationManager.delegate = self
        myLocationManager.requestWhenInUseAuthorization()
        mainMapView.userTrackingMode = MKUserTrackingMode.follow
        mainMapView.showsUserLocation = true
    }
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
    
    // for map view
    // アノテーションの独自ビューを作成
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // ピンではない
        // ユーザの現在位置をデフォルトのシステムビューを使って表示
        if annotation is MKUserLocation {return nil}
        
        let annotationId = "selected"
        var annotationView: MKAnnotationView?
            = mapView.dequeueReusableAnnotationView(withIdentifier: annotationId) ?? nil
        // UI
        let button = UIButton.init(type: .detailDisclosure)
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationId)
            annotationView?.rightCalloutAccessoryView = button
            annotationView?.canShowCallout = true
        }
        
        return annotationView
    }
    // 未登録のピンについてボタンが押下されたとき
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // MPMediaPickerController
        let picker = MPMediaPickerController()
        picker.delegate = self
        picker.allowsPickingMultipleItems = false
        present(picker, animated: true, completion: nil)
        // デリゲート
//        topViewController.ViewController(picker, animated: true, completion: nil)
//        //アノテーションを消す
//        if let annotation = view.annotation {
//            mapView.deselectAnnotation(annotation, animated: true)
//        }
//        //ストーリーボードの名前を指定
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        //viewにつけた名前を指定
//        let vc = storyboard.instantiateViewController(withIdentifier: "locationDetail")
//        //popoverを指定する
//        vc.modalPresentationStyle = UIModalPresentationStyle.popover
//
//        presentViewController(vc, animated: true, completion: nil)
//
//        let popoverPresentationController = vc.popoverPresentationController
//        popoverPresentationController?.sourceView = view
//        popoverPresentationController?.sourceRect = view.bounds
        
    }
    
    // callback from MPMediaPickerController
    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
        player.stop()
        // 選択した曲情報がmediaItemCollectionに入っている
        player.setQueue(with: mediaItemCollection)
        
//        // 選択した曲から最初の曲の情報を表示
//        if let mediaItem = mediaItemCollection.items.first {
//            updateSongInformationUI(mediaItem)
//        }
        
        // ピッカーを閉じ、破棄する
        dismiss(animated: true, completion: nil)
    }
    
    //選択がキャンセルされた場合に呼ばれる
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        // ピッカーを閉じ、破棄する
        dismiss(animated: true, completion: nil)
    }
    
    
    // Map tapped Action
    @IBAction func longpressMap(_ sender: UILongPressGestureRecognizer) {
        let location:CGPoint = sender.location(in: mainMapView)
        let mapPoint:CLLocationCoordinate2D
            = mainMapView.convert(location, toCoordinateFrom: mainMapView)
    
        if sender.state == UIGestureRecognizer.State.ended {
            let annotation = MKPointAnnotation()
            annotation.coordinate
                = CLLocationCoordinate2DMake(mapPoint.latitude, mapPoint.longitude)
            annotation.title = "nothig_selected"
            annotation.subtitle = "guest_user"
            mainMapView.addAnnotation(annotation)
        }
    }
    
    // Button tapped Action
    @IBAction func switchTrackingMode(_ sender: UISwitch) {
        changeTrakingMode()
    }
    @IBAction func tapListButton(_ sender: UIButton) {
        rightContainerView.frame = rightContainerViewInitFrame
        UIView.animate(withDuration: 0.3, animations: {
            self.rightContainerView.frame = self.containerViewDispFrame
        })
    }
    @IBAction func tapMusicButton(_ sender: UIButton) {
        leftContainerView.frame = leftContainerViewInitFrame
        UIView.animate(withDuration: 0.3, animations: {
            self.leftContainerView.frame = self.containerViewDispFrame
        })
    }
    
    @IBAction func letsMusic(_ sender: UIButton) {
        // MPMediaPickerController
        let picker = MPMediaPickerController()
        picker.delegate = self
        picker.allowsPickingMultipleItems = false
        present(picker, animated: true, completion: nil)
    }
    
}

