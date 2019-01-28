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

extension Notification.Name {
    static let LogOut = Notification.Name("logout")
    static let LogIn = Notification.Name("login")
    static let AnnotationEdited = Notification.Name("annotation_edited")
    static let PlayingItemChanged = Notification.Name("playing_item_changed")
}

class MainViewController:
    UIViewController,
    MKMapViewDelegate,
    CLLocationManagerDelegate,
    MPMediaPickerControllerDelegate,
    FUIAuthDelegate
{
    /** ----------------------------------------------------------------------
     # sharedInstance
     ---------------------------------------------------------------------- **/
    // UserData
    var userData = UserData.sharedInstance
    var musicPlayerData = MusicPlayerData.sharedInstance
    var editAnnotationData = EditAnnotationData.sharedInstance
    // NotificationCenter
    let notification = NotificationCenter.default
    
    deinit {
        notification.removeObserver(self)
    }

    // ログインした場合
    // 認証したアカウントのユーザーアイコンを表示
    @objc func handleLoginNotification(_ notification: Notification) {
        if let currentUser = userData.authUI.auth?.currentUser {
            // アイコンの表示
            let avatarUrl = currentUser.photoURL
            do {
                let data = try Data(contentsOf: avatarUrl!)
                let image = UIImage(data: data)
                loginButton.setImage(image, for: UIControl.State())
                print("login")
            }catch let err {
                print("Error : \(err.localizedDescription)")
            }
        }
    }
    
    // ログアウトした場合
    // ログイン画面の表示
    @objc func handleLogoutNotification(_ notification: Notification) {
        self.dismiss(animated: true) {
            self.showLoginViewController()
        }
    }
    
    // アノテーションの編集が行われた場合
    @objc func handleAnnotationEditedNotification(_ notification: Notification){
        self.dismiss(animated: true) {
            self.nowEditAnnotationView.title = self.editAnnotationData.editedAnnotationViewInfo.locationName
            self.mainMapView.addAnnotation(self.nowEditAnnotationView)
        }
    }
    
    func initObservers() {
        notification.addObserver(self,
                                 selector: #selector(handleLoginNotification(_:)),
                                 name: .LogIn,
                                 object: nil)
        notification.addObserver(self,
                         selector: #selector(handleLogoutNotification(_:)),
                         name: .LogOut,
                         object: nil)
        notification.addObserver(self,
                                 selector: #selector(handleAnnotationEditedNotification(_:)),
                                 name: .AnnotationEdited,
                                 object: nil)
    }
    
    /** ----------------------------------------------------------------------
     # UI settings
    ---------------------------------------------------------------------- **/
    // main
    @IBOutlet weak var mainMapView: MKMapView!
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var trackingModeSwitch: UISwitch!
    @IBOutlet weak var loginButton: UIButton!
    // delegatations
    var locationManager: CLLocationManager!
    var player: MPMusicPlayerController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initObservers()
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
        // マップ中心地を東京に設定
        let mapViewCenterDefault = CLLocationCoordinate2DMake(35.5, 139.8)
        let coordinateSpanDefault = MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        let regionDefault = MKCoordinateRegion(center: mapViewCenterDefault, span: coordinateSpanDefault)
        mainMapView.setRegion(regionDefault, animated:true)
        // PinView
    }
    
    
    func showLoginViewController() {
        if userData.authUI.auth?.currentUser == nil {
            let authViewController = userData.authUI.authViewController()
            self.present(authViewController, animated: true, completion: nil)
        } else {
            notification.post(name: .LogIn, object: nil)
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
     ---------------------------------------------------------------------- **/
    var wasViewEditSuccessed = false
    // ピンの登録画面に遷移したときの処理
    func editAnnotation(){
        // 画面遷移
        let mainStoryboard = UIStoryboard(name: "EditAnnotation", bundle: nil)
        let builtStoryboard = mainStoryboard.instantiateViewController(withIdentifier: "edit")
        self.present(builtStoryboard, animated: true, completion: nil)
    }
    
    // 初期状態のアノテーションビューを返す
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {return nil}

        let annotationID = "nothing"
        let annotationView = MKPinAnnotationView(annotation: annotation,
                                                 reuseIdentifier: annotationID)
        let button = UIButton.init(type: .detailDisclosure)
        annotationView.rightCalloutAccessoryView = button
        annotationView.canShowCallout = true
        annotationView.animatesDrop = true

        return annotationView
    }
    
    // ピンの削除ボタンを押下した時
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
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
    var nowEditAnnotationView: MKPointAnnotation!
    
    // マップを長押しした際の処理
    @IBAction func longpressMap(_ sender: UILongPressGestureRecognizer) {
        // タップされた位置情報をもとに、アノテーションを作成
        let location:CGPoint = sender.location(in: mainMapView)
        let mapPoint:CLLocationCoordinate2D
            = mainMapView.convert(location, toCoordinateFrom: mainMapView)
        var annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(mapPoint.latitude, mapPoint.longitude)
        
        let cancelAction = UIAlertAction(title: "キャンセル",
                                         style: UIAlertAction.Style.cancel,
                                         handler:{(action: UIAlertAction!) in
        })
        let defaultAction = UIAlertAction(title: "OK",
                                          style: UIAlertAction.Style.default,
                                          handler:{(action: UIAlertAction!) in
                                            self.nowEditAnnotationView = annotation
                                            self.editAnnotation()
        })
        let alert = UIAlertController(title: "ピンを登録",
                                      message: "楽曲を登録しますか？",
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        
        // マップから指を離した際にアラートを呼ぶ
        if sender.state == UIGestureRecognizer.State.ended {
            present(alert, animated: true, completion: nil)
        }
    }
    
    // (位置情報の追跡モード)スイッチを切り替えた際の処理
    @IBAction func changeTrackingMode(_ sender: UISwitch) {
        if trackingModeSwitch.isOn {
            mainMapView.setCenter(mainMapView.userLocation.coordinate,
                                  animated: true)
            mainMapView.userTrackingMode = MKUserTrackingMode.follow
            headerLabel.textColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
        } else if !trackingModeSwitch.isOn{
            mainMapView.userTrackingMode = MKUserTrackingMode.none
            headerLabel.textColor = .black
        }
    }
    
    // プレイヤーボタンを押した際の処理
    @IBAction func tapPlayerButton(_ sender: UIButton) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let builtStoryboard = mainStoryboard.instantiateViewController(withIdentifier: "player")
        self.present(builtStoryboard, animated: true, completion: nil)
    }
    
    // ログインボタン(ログイン中はユーザアイコン)を押した際の処理
    @IBAction func tapLoginButton(_ sender: UIButton) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let builtStoryboard = mainStoryboard.instantiateViewController(withIdentifier: "user")
        self.present(builtStoryboard, animated: true, completion: nil)
    }
    
}
