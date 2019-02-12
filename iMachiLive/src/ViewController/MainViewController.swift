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
    // NotificationCenter
    let notification = NotificationCenter.default
    
    deinit {
        notification.removeObserver(self)
    }

    @objc func handleLoginstateChangedNotification(_ notification: Notification) {
        if let currentUser = userData.authUI.auth?.currentUser {
            let image = currentUser.photoURL?.toUIImage()
            loginButton.setImage(image, for: UIControl.State())
            initSubviewConfiguration()
            
            self.notification.post(name: .UserInfoUpdate, object: nil)
        } else {
            self.dismiss(animated: true)
            let image = UIImage(named: "ic_account_circle")
            self.loginButton.setImage(image, for: .normal)
            let authViewController = self.userData.authUI.authViewController()
            
            self.present(authViewController, animated: true, completion: nil)
        }
    }
    
    @objc func handleUserInfoUpdateNotification(_ notification: Notification){
        if let currentUser = userData.authUI.auth?.currentUser {
            let childPath = "users/\(currentUser.uid)/userInfo"
            let post = ["uid": currentUser.uid,
                        "userName": currentUser.displayName,
                        "userIcon": currentUser.photoURL?.toUIImage()?.toString() ?? ""]
            userData.ref.child(childPath).updateChildValues(post as [AnyHashable : Any])
        }
    }
    
    @objc func handleAnnotationAddNotification(_ notification: Notification) {
        let cancelAction
            = UIAlertAction(title: "キャンセル",
                            style: UIAlertAction.Style.cancel,
                            handler:{(action: UIAlertAction!) in
            })
        let defaultAction
            = UIAlertAction(title: "OK",
                            style: UIAlertAction.Style.default,
                            handler:{(action: UIAlertAction!) in
                                let mainStoryboard = UIStoryboard(name: "EditAnnotation", bundle: nil)
                                let builtStoryboard = mainStoryboard.instantiateViewController(withIdentifier: "edit")
                                self.present(builtStoryboard, animated: true, completion: nil)
            })
        let alert
            = UIAlertController(title: "ピンを登録",
                                message: "楽曲を登録しますか？",
                                preferredStyle: UIAlertController.Style.alert)
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func handleAnnotationAddedNotification(_ notification: Notification){
        self.dismiss(animated: true)
        
        if let currentUser = self.userData.authUI.auth?.currentUser {
            let childPath = "users/\(currentUser.uid)/annotation"
            self.userData.ref.child(childPath).observeSingleEvent(of: .value, with: { (snapshot) in
                let child = STAnnotation(snapshot: snapshot)
                self.nowEditAnnotation.title = child?.songTitle
                self.nowEditAnnotation.subtitle = child?.songArtist
                self.mainMapView.addAnnotation(self.nowEditAnnotation)
                self.annotationArray.append(self.nowEditAnnotation)
                
                let childPath = "users/\(currentUser.uid)/pin"
                let autoId = self.userData.ref.child(childPath).childByAutoId().key
                let post
                    = ["locationName": child?.locationName,
                       "songTitle": child?.songTitle,
                       "songArtist": child?.songArtist,
                       "songArtwork": child?.songArtwork?.toString(),
                       "location":
                        "\(String(describing: self.nowEditAnnotation.coordinate.latitude))"
                            + ","
                            + "\(String(describing: self.nowEditAnnotation.coordinate.longitude))",
                        "contributeUid": currentUser.uid,
                        "contributeDate": "\(String(describing: NSDate()))",
                        "pinId": "\(autoId!)"]
                self.userData.ref.child(childPath).child(autoId!).setValue(post)
            })
        }
    }
    
    @objc func handleAnnotationEditNotification(_ notification: Notification) {
        let cancelAction
            = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                (action: UIAlertAction!) in
            })
        let defaultAction
            = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                (action: UIAlertAction!) in
                let mainStoryboard = UIStoryboard(name: "EditAnnotation", bundle: nil)
                let builtStoryboard = mainStoryboard.instantiateViewController(withIdentifier: "edit")
                self.present(builtStoryboard, animated: true, completion: nil)
            })
        let alert
            = UIAlertController(title: "ピンを編集", message: "登録したピンを編集しますか？", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func handleAnnotationEditedNotification(_ notification: Notification) {
        self.notification.post(name: .AnnotationRemoved, object: nil)
        self.notification.post(name: .AnnotationAdded, object: nil)
    }
    
    @objc func handleAnnotationAddedOrEditedNotification(_ notification: Notification) {
        self.dismiss(animated: true)

        for annotation in self.annotationArray {
            if(annotation.coordinate.latitude == nowEditAnnotation.coordinate.latitude) {
                self.notification.post(name: .AnnotationEdited, object: nil)
                break
            }
        }
        self.notification.post(name: .AnnotationAdded, object: nil)
    }
    
    @objc func handleAnnotationRemoveNotification(_ notification: Notification) {
        let cancelAction
            = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                (action: UIAlertAction!) in
            })
        let defaultAction
            = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                (action: UIAlertAction!) in
                self.notification.post(name: .AnnotationRemoved, object: nil)
            })
        let alert
            = UIAlertController(title: "ピンを削除", message: "本当に削除しますか？", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func handleAnnotationRemovedNotification(_ notification: Notification) {
        if let currentUser = self.userData.authUI.auth?.currentUser {
            let childPath = "users/\(currentUser.uid)/pin"
            self.userData.ref.child(childPath).observeSingleEvent(of: .value, with: { (snapshot) in
                for item in snapshot.children {
                    let child = STPin(snapshot: item as! DataSnapshot)
                    let targetPinId = (child?.pinId)!
                    let annotationCoordinate = child?.coordinate
                    if(annotationCoordinate?.latitude == self.nowEditAnnotation.coordinate.latitude) {
                        self.mainMapView.removeAnnotation(self.nowEditAnnotation)
                        self.userData.ref.child(childPath).child(targetPinId).removeValue()
                        break
                    }
                }
            })
        }
    }
    
    @objc func handleAnnotationShareNotification(_ notification: Notification) {
        
    }
    
    @objc func handleAnnotationSharedNotification(_ notification: Notification) {
        
    }
    
    func initObservers() {
        notification.addObserver(self,
                                 selector: #selector(handleLoginstateChangedNotification(_:)),
                                 name: .LoginstateChanged, object: nil)
        notification.addObserver(self,
                                 selector: #selector(handleUserInfoUpdateNotification(_:)),
                                 name: .UserInfoUpdate, object: nil)
        notification.addObserver(self,
                                 selector: #selector(handleAnnotationAddNotification(_:)),
                                 name: .AnnotationAdd, object: nil)
        notification.addObserver(self,
                                 selector: #selector(handleAnnotationAddedNotification(_:)),
                                 name: .AnnotationAdded, object: nil)
        notification.addObserver(self,
                                 selector: #selector(handleAnnotationEditNotification(_:)),
                                 name: .AnnotationEdit, object: nil)
        notification.addObserver(self,
                                 selector: #selector(handleAnnotationEditedNotification(_:)),
                                 name: .AnnotationEdited, object: nil)
        notification.addObserver(self,
                                 selector: #selector(handleAnnotationAddedOrEditedNotification(_:)),
                                 name: .AnnotationAddedOrEdited, object: nil)
        notification.addObserver(self,
                                 selector: #selector(handleAnnotationRemoveNotification(_:)),
                                 name: .AnnotationRemove, object: nil)
        notification.addObserver(self,
                                 selector: #selector(handleAnnotationRemovedNotification(_:)),
                                 name: .AnnotationRemoved, object: nil)
        notification.addObserver(self,
                                 selector: #selector(handleAnnotationShareNotification(_:)),
                                 name: .AnnotationShare, object: nil)
        notification.addObserver(self,
                                 selector: #selector(handleAnnotationSharedNotification(_:)),
                                 name: .AnnotationShared, object: nil)
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
    var normalView = NormalView()
    var selectedHeaderView = SelectedHeaderView()
    var selectedContentsView = SelectedContentsView()
    var annotationArray: [MKAnnotation] = []
    var nowEditAnnotation: MKPointAnnotation!
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
    let animatorDuration: TimeInterval = 0.3
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
        
        slideView.layer.cornerRadius = 10
        slideView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        slideView.layer.masksToBounds = true
        slideView.frame = colleapsedFrame()
        
        normalView.layer.cornerRadius = 10
        normalView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        normalView.layer.masksToBounds = true
        normalView.frame
            = CGRect(x: 0, y: 0,
                     width: self.view.frame.width,
                     height: Height_slideView_collapsed)
        
        selectedHeaderView.layer.cornerRadius = 10
        selectedHeaderView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        selectedHeaderView.layer.masksToBounds = true
        selectedHeaderView.frame
            = CGRect(x: 0, y: 0,
                     width: self.view.frame.width,
                     height: Height_slideView_collapsed)

        contentsScrollView.bounces = false
        contentsScrollView.isScrollEnabled = true
        contentsScrollView.contentSize = CGSize(width: self.view.frame.width, height: 380)
        contentsScrollView.frame
            = CGRect(x: 0, y: selectedHeaderView.frame.maxY,
                     width: self.view.frame.width,
                     height: Height_slideView_expanded - Height_slideView_collapsed)
        
        selectedContentsView.frame
            = CGRect(x: 0, y: 0,
                     width: self.view.frame.width,
                     height: Height_selectedContentsView)
        
        slideView.addSubview(normalView)
        self.view.addSubview(slideView)
    }
    
    private func initSubviewConfiguration() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()

        mainMapView.delegate = self
        mainMapView.showsUserLocation = false
        mainMapView.userTrackingMode = MKUserTrackingMode.none

        let mapViewCenterDefault = CLLocationCoordinate2DMake(35.5, 139.8)
        let coordinateSpanDefault = MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        let regionDefault = MKCoordinateRegion(center: mapViewCenterDefault, span: coordinateSpanDefault)
        mainMapView.setRegion(regionDefault, animated:true)
        
        mainMapView.removeAnnotations(annotationArray)

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
                    self.annotationArray.append(annotation)
                }
            })
        }
    }
    
    private func addGestures() {
        slideView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTapGesture(_:))))
        
        slideView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:))))
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
        let translationY = state == .expanded ? -translation.y : translation.y
        return translationY / (self.view.frame.height) + progressWhenInterrupted
    }
    
    func animateOrReverseRunningTransition(state: SlideViewState, duration: TimeInterval) {
        if runningAnimators.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
            runningAnimators.forEach({ $0.startAnimation() })
        } else {
            runningAnimators.forEach({ $0.isReversed = !$0.isReversed })
        }
    }
    
    func startInteractiveTransition(state: SlideViewState, duration: TimeInterval) {
        self.animateTransitionIfNeeded(state: state, duration: duration)
        runningAnimators.forEach({ $0.pauseAnimation() })
        progressWhenInterrupted = runningAnimators.first?.fractionComplete ?? 0
    }
    
    func updateInteractiveTransition(fractionComplete: CGFloat) {
        runningAnimators.forEach({ $0.fractionComplete = fractionComplete })
    }
    
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
                        artworkImageView.backgroundColor = .lightGray
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
        nowEditAnnotation = (view.annotation as! MKPointAnnotation)
        
        for subview in slideView.subviews {
            subview.removeFromSuperview()
        }
        state_SelectedView = .collapsed
        slideView.frame = colleapsedFrame()
        contentsScrollView.addSubview(selectedContentsView)
        slideView.addSubview(selectedHeaderView)
        slideView.addSubview(contentsScrollView)
        
        if let currentUser = userData.authUI.auth?.currentUser {
            let childPath = "users/\(currentUser.uid)/pin"
            userData.ref.child(childPath).observeSingleEvent(of: .value, with: { (snapshot) in
                for item in snapshot.children {
                    let child = STPin(snapshot: item as! DataSnapshot)
                    if(child?.coordinate!.latitude == view.annotation!.coordinate.latitude) {
                        self.selectedHeaderView.locationnameLabel.text = child?.locationName
                        self.selectedContentsView.songtitleLabel.text = child?.songTitle
                        self.selectedContentsView.songartistImageView.text = child?.songArtist
                        self.selectedContentsView.contributedateLabel.text = child?.contributeDate
                        self.selectedContentsView.songartworkImageView.image = child?.songArtwork
                        // STUserで解決したい
                        let childPath = "users/\(child?.contributeUid ?? "")/userInfo"
                        self.userData.ref.child(childPath).observeSingleEvent(of: .value, with: { (snapshot) in
                            let child = STUser(snapshot: snapshot)
                            self.selectedContentsView.contributernameLabel.text = child?.userName
                            self.selectedContentsView.contributeravatarImageView.image = child?.userIcon
                        })
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
        state_SelectedView = .collapsed
        slideView.frame = colleapsedFrame()
        slideView.addSubview(normalView)
    }
    
    /** ----------------------------------------------------------------------
     # UI actions
     ---------------------------------------------------------------------- **/
    // マップを長押しした際の処理
    @IBAction func longpressMap(_ sender: UILongPressGestureRecognizer) {
        let location:CGPoint = sender.location(in: mainMapView)
        let mapPoint:CLLocationCoordinate2D = mainMapView.convert(location, toCoordinateFrom: mainMapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate
            = CLLocationCoordinate2DMake(mapPoint.latitude, mapPoint.longitude)
        
        nowEditAnnotation = annotation
        
        if sender.state == UIGestureRecognizer.State.ended {
            notification.post(name: .AnnotationAdd, object: nil)
        }
    }
    
    @IBAction func changeTrackingMode(_ sender: UISwitch) {
        if trackingModeSwitch.isOn {
            mainMapView.setCenter(mainMapView.userLocation.coordinate,
                                  animated: true)
            mainMapView.userTrackingMode = MKUserTrackingMode.follow
            headerLabel.textColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
        } else if !trackingModeSwitch.isOn {
            mainMapView.userTrackingMode = MKUserTrackingMode.none
            headerLabel.textColor = .black
        }
    }
    
    @IBAction func tapLoginButton(_ sender: UIButton) {
        if (userData.authUI.auth?.currentUser) != nil {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let builtStoryboard = mainStoryboard.instantiateViewController(withIdentifier: "user")
            self.present(builtStoryboard, animated: true, completion: nil)
        } else {
            let authViewController = self.userData.authUI.authViewController()
            self.present(authViewController, animated: true, completion: nil)
        }
    }
    
}
