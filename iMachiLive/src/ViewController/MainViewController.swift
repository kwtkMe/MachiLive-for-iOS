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

enum SlideViewState {
    case normal
    case selected
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

    // ビューを再設定したい
    @objc func handleLoginstateChangedNotification(_ notification: Notification) {
        if let currentUser = userData.authUI.auth?.currentUser {
            let image = currentUser.photoURL?.toUIImage()
            loginButton.setImage(image, for: UIControl.State())
        } else {
            self.dismiss(animated: true) {let image = UIImage(named: "ic_account_circle")
                self.loginButton.setImage(image, for: .normal)
                let authViewController = self.userData.authUI.authViewController()
                self.present(authViewController, animated: true, completion: nil)
            }
        }
    }
    
    // マップの長押しで発火(EditAnnotationViewController 経由)
    @objc func handleAnnotationAddedNotification(_ notification: Notification){
        self.dismiss(animated: true)
        // ピンを打つ(新規)
        self.nowEditAnnotation.title = self.editAnnotationData.editAnnotationInfo.songTitle
        self.nowEditAnnotation.subtitle = self.editAnnotationData.editAnnotationInfo.songArtist
        self.mainMapView.addAnnotation(self.nowEditAnnotation)
        
        // post to realtime database
        if let currentUser = userData.authUI.auth?.currentUser {
            let childPath = "users/\(currentUser.uid)/pin"
            // childByAutoId() のリファレンス
            let autoId = userData.ref.child(childPath).childByAutoId().key
            let nowDate = NSDate()
            let post
                = ["locationName": editAnnotationData.editAnnotationInfo.locationName!,
                   "songTitle": editAnnotationData.editAnnotationInfo.songTitle!,
                   "songArtist": editAnnotationData.editAnnotationInfo.songArtist!,
                   "songArtwork": editAnnotationData.editAnnotationInfo.songArtwork?.toString() ?? "",
                   "location":
                        "\(String(describing: editAnnotationData.editAnnotationInfo.coordinate!.latitude))"
                        + ","
                        + "\(String(describing: editAnnotationData.editAnnotationInfo.coordinate!.longitude))",
                   "contributeUid": currentUser.uid,
                   "contributeDate": "\(String(describing: nowDate))",
                   "pinId": "\(autoId!)"]
            userData.ref.child(childPath).child(autoId!).setValue(post)
        }
    }
    
    // 編集ボタンで発火(EditAnnotationViewController 経由)
    @objc func handleAnnotationEditedNotification(_ notification: Notification) {
        // 削除して handleAnnotationAddedNotification() を呼ぶ
        self.dismiss(animated: true)
        
        self.notification.post(name: .AnnotationRemoved, object: nil)
        
        self.notification.post(name: .AnnotationAdded, object: nil)
    }
    
    // 削除ボタンで発火
    @objc func handleAnnotationRemovedNotification(_ notification: Notification) {
        self.mainMapView.removeAnnotation(self.nowEditAnnotation)
        
        if let currentUser = userData.authUI.auth?.currentUser {
            let childPath = "users/\(currentUser.uid)/pin"
            var targetPinId = ""
            userData.ref.child(childPath).observeSingleEvent(of: .value, with: { (snapshot) in
                for item in snapshot.children {
                    let child = STPin(snapshot: item as! DataSnapshot)
                    let annotationCoordinate = CLLocationCoordinate2DMake((child?.location?.x)!,(child?.location!.y)!)
                    if(annotationCoordinate.latitude == self.nowEditAnnotation.coordinate.latitude) {
                        targetPinId = (child?.pinId)!
                        break
                    } else {
                        //
                    }
                }
            })
            userData.ref.child(childPath).child(targetPinId).removeValue()
        }
    }
    
    func initObservers() {
        notification.addObserver(self,
                                 selector: #selector(handleLoginstateChangedNotification(_:)),
                                 name: .LoginstateChanged,
                                 object: nil)
        notification.addObserver(self,
                                 selector: #selector(handleAnnotationAddedNotification(_:)),
                                 name: .AnnotationAdded,
                                 object: nil)
        notification.addObserver(self,
                                 selector: #selector(handleAnnotationEditedNotification(_:)),
                                 name: .AnnotationEdited,
                                 object: nil)
        notification.addObserver(self,
                                 selector: #selector(handleAnnotationRemovedNotification(_:)),
                                 name: .AnnotationRemoved,
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
    let slideView_collapsed_Height: CGFloat = 80.0
    let slideView_expanded_Height: CGFloat = 500.0
    let animatorDuration: TimeInterval = 1
    // UI
    var slideView = UIView()
    var slideNormalView = NormalView()
    var slideSelectedView = SelectedView()
    var slideSelectedExView = SelectedExView()
    var nowEditAnnotation: MKPointAnnotation!
    var nowEditAnnotationPoint: CLLocationCoordinate2D!
    // Tracks all running aninmators
    var state: SlideViewState = .normal
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
        slideView.layer.cornerRadius = 10
        slideView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        slideView.layer.masksToBounds = true
        slideNormalView.backgroundColor = .white
        slideView.frame = collapsedFrame()
        self.view.addSubview(slideView)
        
        // スライダービューの子要素ビューの初期設定
        slideNormalView.layer.cornerRadius = 10
        slideNormalView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        slideNormalView.layer.masksToBounds = true
        slideNormalView.frame
            = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 80)
        
        slideSelectedView.layer.cornerRadius = 10
        slideSelectedView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        slideSelectedView.layer.masksToBounds = true
        slideSelectedView.frame
            = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 80)
        
        slideSelectedExView.frame
            = CGRect(x: 0, y: 60, width: self.view.frame.width, height: 500)
        
        slideView.addSubview(slideNormalView)
    }
    
    private func initSubviewConfiguration() {
        // locationManager
        locationManager = CLLocationManager()
        locationManager.delegate = self
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
        // ピンを打つ(読み込み)
        if let currentUser = userData.authUI.auth?.currentUser {
            let childPath = "users/\(currentUser.uid)/pin"
            userData.ref.child(childPath).observeSingleEvent(of: .value, with: { (snapshot) in
                for item in snapshot.children {
                    let child = STPin(snapshot: item as! DataSnapshot)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate
                        = CLLocationCoordinate2DMake((child?.location!.x)!, (child?.location!.y)!)
                    annotation.title = child?.songTitle
                    annotation.subtitle = child?.songArtist
                    self.mainMapView.addAnnotation(annotation)
                }
            })
        }
        
    }
    
    private func addGestures() {
        // Tap gesture
        slideView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTapGesture(_:))))
        
        // Pan gesutre
        slideView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:))))
    }
    
    private func collapsedFrame() -> CGRect {
        return CGRect(
            x: 0,
            y: self.view.frame.height - slideView_collapsed_Height,
            width: self.view.frame.width,
            height: slideView_collapsed_Height)
    }
    
    private func expandedFrame() -> CGRect {
        return CGRect(
            x: 0,
            y: self.view.frame.height - slideView_expanded_Height,
            width: self.view.frame.width,
            height: slideView_expanded_Height
        )
    }
    
    func replaseSlideViewContents() {
        
    }
    
    //！()
    func changeNextState() -> SlideViewState {
        switch self.state {
        case .normal:
            return .selected
        case .selected:
            return .normal
        }
    }
    
    // MARK: Gesture
    @objc private func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        
    }
    
    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        
    }
    
    /** ----------------------------------------------------------------------
     # PinView settings
     ---------------------------------------------------------------------- **/
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {return nil}
        
        let annotationID = "ohYhea"
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationID)
        
        let artworkImageView = UIImageView()
        artworkImageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        
        if let currentUser = userData.authUI.auth?.currentUser {
            let childPath = "users/\(currentUser.uid)/pin"
            userData.ref.child(childPath).observeSingleEvent(of: .value, with: { (snapshot) in
                for item in snapshot.children {
                    let child = STPin(snapshot: item as! DataSnapshot)
                    let annotationCoordinate = CLLocationCoordinate2DMake((child?.location?.x)!,(child?.location!.y)!)
                    if(annotationCoordinate.latitude == annotation.coordinate.latitude) {
                        artworkImageView.image = child?.songArtwork
                        break
                    } else {
                        artworkImageView.image = nil
                        artworkImageView.backgroundColor = .red
                    }
                }
            })
            annotationView.image = currentUser.photoURL?.toUIImage()
        }
        annotationView.leftCalloutAccessoryView = artworkImageView
        annotationView.canShowCallout = true
        annotationView.animatesDrop = true
        
        return annotationView
    }
    
    // ビューの処理に専念する
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("hello")
        
        slideNormalView.removeFromSuperview()
        slideView.addSubview(slideSelectedView)
    }
    
    // ビューの処理に専念する
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print("bye")
        
        slideSelectedView.removeFromSuperview()
        slideView.addSubview(slideNormalView)
    }
    
    // ピンの削除ボタンを押下した時
    // ！(未実装)SliderViewの削除ボタンで発火(したい)
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
    // マップを長押しした際の処理
    @IBAction func longpressMap(_ sender: UILongPressGestureRecognizer) {
        let location:CGPoint = sender.location(in: mainMapView)
        let mapPoint:CLLocationCoordinate2D
            = mainMapView.convert(location, toCoordinateFrom: mainMapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate
            = CLLocationCoordinate2DMake(mapPoint.latitude, mapPoint.longitude)
        
        nowEditAnnotation = annotation
        nowEditAnnotationPoint = mapPoint
        editAnnotationData.coordinate = mapPoint
        
        let cancelAction = UIAlertAction(title: "キャンセル",
                                         style: UIAlertAction.Style.cancel,
                                         handler:{(action: UIAlertAction!) in
        })
        let defaultAction = UIAlertAction(title: "OK",
                                          style: UIAlertAction.Style.default,
                                          handler:{(action: UIAlertAction!) in
                                            let mainStoryboard = UIStoryboard(name: "EditAnnotation", bundle: nil)
                                            let builtStoryboard = mainStoryboard.instantiateViewController(withIdentifier: "edit")
                                            self.present(builtStoryboard, animated: true, completion: nil)
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
    
    // ログインボタン(ログイン中はユーザアイコン)を押した際の処理
    @IBAction func tapLoginButton(_ sender: UIButton) {
        if (userData.authUI.auth?.currentUser) != nil {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let builtStoryboard = mainStoryboard.instantiateViewController(withIdentifier: "user")
            self.present(builtStoryboard, animated: true, completion: nil)
        }
        else {
            let authViewController = self.userData.authUI.authViewController()
            self.present(authViewController, animated: true, completion: nil)
        }
    }
    
}
