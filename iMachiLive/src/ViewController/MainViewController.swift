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

enum SliderViewState {
    case normal
    case selected
    case selectedEx
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
    @objc func handleLoginstateChangedNotification(_ notification: Notification) {
        if let currentUser = userData.authUI.auth?.currentUser {
            // アイコンの表示
            let avatarUrl = currentUser.photoURL
            do {
                let data = try Data(contentsOf: avatarUrl!)
                let image = UIImage(data: data)
                loginButton.setImage(image, for: UIControl.State())
                print("login")
            } catch let err {
                print("Error : \(err.localizedDescription)")
            }
            //ログアウトした
        } else {
            self.dismiss(animated: true) {
                let authViewController = self.userData.authUI.authViewController()
                self.present(authViewController, animated: true, completion: nil)
            }
        }
    }
    
    // アノテーションの編集が行われた場合
    @objc func handleAnnotationEditedNotification(_ notification: Notification){
        self.dismiss(animated: true) {
            self.nowEditAnnotationView.title = self.editAnnotationData.editedAnnotationViewInfo.songTitle
            self.nowEditAnnotationView.subtitle =
                self.editAnnotationData.editedAnnotationViewInfo.songArtist
            self.mainMapView.addAnnotation(self.nowEditAnnotationView)
        }
    }
    
    func initObservers() {
        notification.addObserver(self,
                                 selector: #selector(handleLoginstateChangedNotification(_:)),
                                 name: .LoginstateChanged,
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
    // Constant
    let sliderView_collapsed_Height: CGFloat = 80.0
    let sliderView_expanded_Height: CGFloat = 500.0
    let animatorDuration: TimeInterval = 1
    // UI
    var sliderView = UIView()
    var sliderNormalView = NormalView()
    var sliderSelectedView = SelectedView()
    var sliderSelectedExView = SelectedExView()
    // Tracks all running aninmators
    var state: SliderViewState = .normal
    var progressWhenInterrupted: CGFloat = 0
    var runningAnimators = [UIViewPropertyAnimator]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initObservers()
        initSubview()
        initSubviewConfiguration()
    }
    
    private func initSubview() {
        // ログインボタンを丸くする
        loginButton.layer.cornerRadius = 20
        loginButton.layer.masksToBounds = true
        
        // スライダービューの初期設定
        self.view.addSubview(sliderView)
        sliderView.layer.cornerRadius = 10
        sliderView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sliderView.layer.masksToBounds = true
        sliderNormalView.backgroundColor = .white
        sliderView.frame = collapsedFrame()
        
        // スライダービューの子要素ビューの初期設定
        sliderNormalView.layer.cornerRadius = 10
        sliderNormalView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sliderNormalView.layer.masksToBounds = true
        sliderNormalView.frame
            = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 80)
        
        sliderSelectedView.layer.cornerRadius = 10
        sliderSelectedView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sliderSelectedView.layer.masksToBounds = true
        sliderSelectedView.frame
            = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 60)
        
        sliderSelectedExView.frame
            = CGRect(x: 0, y: 60, width: self.view.frame.width, height: 500)
        
        sliderView.addSubview(sliderNormalView)
    }
    
    private func initSubviewConfiguration() {
        // locationManager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        if locationManager != nil { return }
        locationManager.requestWhenInUseAuthorization()
        // mainMapView
        mainMapView.delegate = self
        mainMapView.showsUserLocation = false
        mainMapView.userTrackingMode = MKUserTrackingMode.none
        // マップ中心地を東京に設定
        let mapViewCenterDefault = CLLocationCoordinate2DMake(35.5, 139.8)
        let coordinateSpanDefault = MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        let regionDefault = MKCoordinateRegion(center: mapViewCenterDefault, span: coordinateSpanDefault)
        mainMapView.setRegion(regionDefault, animated:true)
    }
    
    private func addGestures() {
        // Tap gesture
        sliderView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTapGesture(_:))))
        
        // Pan gesutre
        sliderView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:))))
    }
    
    private func collapsedFrame() -> CGRect {
        return CGRect(
            x: 0,
            y: self.view.frame.height - sliderView_collapsed_Height,
            width: self.view.frame.width,
            height: sliderView_collapsed_Height)
    }
    
    private func expandedFrame() -> CGRect {
        return CGRect(
            x: 0,
            y: self.view.frame.height - sliderView_expanded_Height,
            width: self.view.frame.width,
            height: sliderView_expanded_Height
        )
    }
    
    // MARK: Gesture
    @objc private func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        
    }
    
    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {return nil}

        let annotationID = editAnnotationData.editedAnnotationViewInfo.locationName!
                            + editAnnotationData.editedAnnotationViewInfo.songTitle!
        let annotationView = MKPinAnnotationView(annotation: annotation,
                                                 reuseIdentifier: annotationID)
        
        let artworkImageView = UIImageView()
        artworkImageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        if let artwork = editAnnotationData.editedAnnotationViewInfo.songArtwork {
            artworkImageView.image = artwork
        } else {
            artworkImageView.image = nil
            artworkImageView.backgroundColor = .lightGray
        }
        annotationView.leftCalloutAccessoryView = artworkImageView
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
        let annotation = MKPointAnnotation()
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
