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

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
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
            rightContainerView.frame = rightContainerViewInitFrame
            rightContainerView.addSubview(viewController.view)
        }
    }
    // etc.
    @IBOutlet weak var trakingModeLabel: UILabel!
    @IBOutlet weak var trakingModeSwitch: UISwitch!
    @IBOutlet weak var mapView: MKMapView!
    
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
    
    
    // MARK: methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 位置情報の許可
        myLocationManager = CLLocationManager()
        myLocationManager.requestWhenInUseAuthorization()
        myLocationManager.delegate = self
        
        mapView.delegate = self
    }
    
    // for side view
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
    func changeTrakingMode(){
        switch self.mode {
        case .moving:
            self.trakingModeSwitch.isOn = false
            self.trakingModeLabel.text = "staying"
            self.mode = .staying
        case .staying:
            self.trakingModeSwitch.isOn = true
            self.trakingModeLabel.text = "moving"
            self.mode = .moving
        }
    }
    func startTraking(permission: Bool) {
        if(permission) {
            
        }else {
            return
        }
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation === mapView.userLocation {
            // 現在地を示すアノテーションの場合はデフォルトのまま
            
            //現在地のタイトルをnilにすることでコールアウトを非表示にする
            (annotation as? MKUserLocation)?.title = nil
            return nil //nilを返すことで現在地がピンにならない
        }else {
            let identifier = "annotation"
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier){
                // 再利用できる場合はそのまま返す
                return annotationView
            } else { // 再利用できるアノテーションが無い場合（初回など）は生成する
                let myPinIdentifier = "PinAnnotationIdentifier"
                //ピンをインスタンス化
                let pinByLongPress = MKPointAnnotation()
                //アノテーションビュー生成
                let annotationView = MKPinAnnotationView(annotation: pinByLongPress, reuseIdentifier: myPinIdentifier)
                //ピンが降ってくるアニメーションをつける
                annotationView.animatesDrop = true
                return annotationView
            }
        }
    }
    
    // Map tapped Action
    @IBAction func longpressMap(_ sender: UILongPressGestureRecognizer) {
        //ロングタップの最初の感知のみ受け取る
        if(sender.state != UIGestureRecognizer.State.began){
            return
        }
        
        let pinByLongPress = MKPointAnnotation()
        let location:CGPoint = sender.location(in: mapView)
        let longPressedCoordinate:CLLocationCoordinate2D = mapView.convert(location, toCoordinateFrom: mapView)
        //ロングタップした位置の座標をピンに入力
        pinByLongPress.coordinate = longPressedCoordinate
        
        self.mapView.addAnnotation(pinByLongPress)
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


}

