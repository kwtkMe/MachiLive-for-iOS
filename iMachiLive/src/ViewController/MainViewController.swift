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
    case collapsed
    case expanded
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
        if let currentUser = userData.authUI.auth?.currentUser {
            let childPath = "users/\(currentUser.uid)/pin"
            userData.ref.child(childPath).observeSingleEvent(of: .value, with: { (snapshot) in
                for item in snapshot.children {
                    let child = STPin(snapshot: item as! DataSnapshot)
                    let targetPinId = (child?.pinId)!
                    let annotationCoordinate = child?.coordinate
                    if(annotationCoordinate?.latitude == self.nowEditAnnotation.coordinate.latitude) {
                        self.userData.ref.child(childPath).child(targetPinId).removeValue()
                        self.mainMapView.removeAnnotation(self.nowEditAnnotation)
                        break
                    } else {
                        //
                    }
                }
            })
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
    // UI
    var slideView = UIView()
    var contentsScrollView = UIScrollView()
    var normalView = NormalView() // ピン選択外の時のビュー
    var selectedHeaderView = SelectedHeaderView() // ピン選択時のビュー
    var selectedContentsView = SelectedContentsView()
    var nowEditAnnotation: MKPointAnnotation!
    var nowEditAnnotationPoint: CLLocationCoordinate2D!
    // UI Constant
    var state_SelectedView: SlideViewState = .collapsed
    final let Height_slideView_collapsed: CGFloat = 80.0
    final let Height_slideView_expanded: CGFloat = 300.0
    final let Height_selectedContentsView: CGFloat = 500.0
    final func colleapsedFrame() -> CGRect {
        return CGRect(
            x: 0,
            y: self.view.frame.height - Height_slideView_collapsed,
            width: self.view.frame.width,
            height: Height_slideView_collapsed)
    }
    final func expandedFrame() -> CGRect {
        return CGRect(
            x: 0,
            y: self.view.frame.height - Height_slideView_expanded,
            width: self.view.frame.width,
            height: Height_slideView_expanded
        )
    }
    // Tracks all running aninmators
    let animatorDuration: TimeInterval = 0.2
    var progressWhenInterrupted: CGFloat = 0
    var runningAnimators = [UIViewPropertyAnimator]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initObservers()
        initSubview()
        initSubviewConfiguration()
        
        addGestures()
    }
    
    private func initSubview() {
        // ログインボタンを丸くする
        loginButton.layer.cornerRadius = 20
        loginButton.layer.masksToBounds = true
        
        // slideViewを初期化
        slideView.layer.cornerRadius = 10
        slideView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        slideView.layer.masksToBounds = true
        slideView.frame = colleapsedFrame()
        
        // SlideViewの子要素を初期化
        normalView.layer.cornerRadius = 10
        normalView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        normalView.layer.masksToBounds = true
        normalView.frame
            = CGRect(x: 0, y: 0, width: self.view.frame.width, height: Height_slideView_collapsed)
        selectedHeaderView.layer.cornerRadius = 10
        selectedHeaderView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        selectedHeaderView.layer.masksToBounds = true
        selectedHeaderView.frame
            = CGRect(x: 0, y: 0, width: self.view.frame.width, height: Height_slideView_collapsed)
        // .expanded のContents部分を表示させるためのスクロールビューを定義
        contentsScrollView.bounces = false
        contentsScrollView.isScrollEnabled = true
        contentsScrollView.contentSize = CGSize(width: self.view.frame.width, height: 380)
        contentsScrollView.frame
            = CGRect(x: 0, y: selectedHeaderView.frame.maxY, width: self.view.frame.width, height: Height_slideView_expanded - Height_slideView_collapsed)
        selectedContentsView.frame
            = CGRect(x: 0, y: 0, width: self.view.frame.width, height: Height_selectedContentsView)
        
        self.view.addSubview(slideView)
        slideView.addSubview(normalView)
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
                    annotation.coordinate = (child?.coordinate)!
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
    
    func replaseSlideViewContents() {
        
    }
    
    func changeSlideViewState() -> SlideViewState {
        switch self.state_SelectedView {
        case .collapsed:
            return .expanded
        case .expanded:
            return .collapsed
        }
    }
    
    private func addFrameAnimator(state: SlideViewState, duration: TimeInterval) {
        let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            switch state {
            case .collapsed:
                self.slideView.frame = self.colleapsedFrame()
            case .expanded:
                self.slideView.frame = self.expandedFrame()
            }
        }
        frameAnimator.addCompletion({ (position) in
            switch position {
            case .start:
                break
            case .end:
                self.state_SelectedView = self.changeSlideViewState()
            default:
                break
            }
            self.runningAnimators.removeAll()
        })
        runningAnimators.append(frameAnimator)
    }
    
    func animateTransitionIfNeeded(state: SlideViewState, duration: TimeInterval) {
        if runningAnimators.isEmpty {
            self.addFrameAnimator(state: state, duration: duration)
        }
    }
    
    // MARK: Gesture
    @objc private func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        self.animateOrReverseRunningTransition(state: self.changeSlideViewState(), duration: animatorDuration)
    }
    
    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: slideView)
        switch recognizer.state {
        case .began:
            self.startInteractiveTransition(state: self.changeSlideViewState(), duration: animatorDuration)
        case .changed:
            self.updateInteractiveTransition(fractionComplete: self.fractionComplete(state: self.changeSlideViewState(), translation: translation))
        case .ended:
            self.continueInteractiveTransition(fractionComplete: self.fractionComplete(state: self.changeSlideViewState(), translation: translation))
        default:
            break
        }
    }
    
    private func fractionComplete(state: SlideViewState, translation: CGPoint) -> CGFloat {
        // 広げようと(changeSlideViewState()で.expand)しているとき、値を負数にする
        let translationY = state == .expanded ? -translation.y : translation.y
        return translationY
            // 左項：画面高さ - 他パーツ高さの合計値
            // 右項：
            / (self.view.frame.height) + progressWhenInterrupted
    }
    
    // Starts transition if necessary or reverse it on tap
    func animateOrReverseRunningTransition(state: SlideViewState, duration: TimeInterval) {
        if runningAnimators.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
            runningAnimators.forEach({ $0.startAnimation() })
        } else {
            runningAnimators.forEach({ $0.isReversed = !$0.isReversed })
        }
    }
    
    // Starts transition if necessary and pauses on pan .began
    func startInteractiveTransition(state: SlideViewState, duration: TimeInterval) {
        self.animateTransitionIfNeeded(state: state, duration: duration)
        runningAnimators.forEach({ $0.pauseAnimation() })
        progressWhenInterrupted = runningAnimators.first?.fractionComplete ?? 0
    }
    
    // Scrubs transition on pan .changed
    func updateInteractiveTransition(fractionComplete: CGFloat) {
        runningAnimators.forEach({ $0.fractionComplete = fractionComplete })
    }
    
    // Continues or reverse transition on pan .ended
    func continueInteractiveTransition(fractionComplete: CGFloat) {
        let cancel: Bool = fractionComplete < 0.2
        if cancel {
            runningAnimators.forEach({
                $0.isReversed = !$0.isReversed
                $0.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            })
            return
        }
        let timing = UICubicTimingParameters(animationCurve: .easeOut)
        runningAnimators.forEach({ $0.continueAnimation(withTimingParameters: timing, durationFactor: 0) })
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
                    let annotationCoordinate = child?.coordinate
                    if(annotationCoordinate?.latitude == annotation.coordinate.latitude) {
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
    
    // about .selected
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        for subview in slideView.subviews {
            subview.removeFromSuperview()
        }
        // Stateを戻してスライドビューを追加
        state_SelectedView = .collapsed
        slideView.frame = colleapsedFrame()
        slideView.addSubview(selectedHeaderView)
        slideView.addSubview(contentsScrollView)
        contentsScrollView.addSubview(selectedContentsView)
        
        if let currentUser = userData.authUI.auth?.currentUser {
            let childPath = "users/\(currentUser.uid)/pin"
            userData.ref.child(childPath).observeSingleEvent(of: .value, with: { (snapshot) in
                for item in snapshot.children {
                    let child = STPin(snapshot: item as! DataSnapshot)
                    let annotationCoordinate = child?.coordinate
                    if(annotationCoordinate?.latitude == view.annotation!.coordinate.latitude) {
                        // ビューへの反映
                        break
                    }
                }
            })
        }
    }
    
    // about .normal
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        for subview in slideView.subviews {
            subview.removeFromSuperview()
        }
        // Stateを戻してスライドビューを追加
        state_SelectedView = .collapsed
        slideView.frame = colleapsedFrame()
        slideView.addSubview(normalView)
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
