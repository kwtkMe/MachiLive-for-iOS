//
//  Structs.swift
//  iMachiLive
//
//  Created by RIVER on 2019/02/06.
//  Copyright © 2019 Reverse. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit
import Firebase

//public struct STAnnotationData {
//    var locationName: String?
//    var songTitle: String?
//    var songArtist: String?
//    var songArtwork: UIImage?
//    var songId: NSNumber?
//    var coordinate: CLLocationCoordinate2D?
//}

public struct STAnnotation {
    let locationName: String?
    let songTitle: String?
    let songArtist: String?
    let songArtwork: UIImage?
    let songId: NSNumber?
    
    init? (snapshot: DataSnapshot) {
        let dictionary = snapshot.value as! NSDictionary
        guard let locationName = dictionary["locationName"] as? String else { return nil }
        guard let songTitle = dictionary["songTitle"] as? String else { return nil }
        guard let songArtist = dictionary["songArtist"] as? String else { return nil }
        guard let songArtwork = dictionary["songArtwork"] as? String else { return nil }
        guard let strSongArtwork = dictionary["songArtwork"] as? String else { return nil }
        guard let strSongId = dictionary["songId"] as? String else { return nil }

        self.locationName = locationName
        self.songTitle = songTitle
        self.songArtist = songArtist
        self.songArtwork = strSongArtwork.toImage()
        self.songId = Int(strSongId)! as NSNumber
    }
}

public struct STUser {
    let uid: String?
    let userName: String?
    let userIcon: UIImage?
    
    init? (snapshot: DataSnapshot) {
        let dictionary = snapshot.value as! NSDictionary
        guard let uid = dictionary["uid"] as? String else { return nil }
        guard let userName = dictionary["userName"] as? String else { return nil }
        guard let userIcon = dictionary["userIcon"] as? String else { return nil }
        
        self.uid = uid
        self.userName = userName
        self.userIcon = userIcon.toImage()
    }
}

public struct STPin {
    let locationName: String?
    let songTitle: String?
    let songArtist: String?
    let songArtwork: UIImage?
    let songId: NSNumber?
    let coordinate: CLLocationCoordinate2D?
    let contributeUid: String?
    let contributeDate: String?
    let pinId: String?
    
    init? (snapshot: DataSnapshot) {
        let dictionary = snapshot.value as! NSDictionary
        guard let locationName = dictionary["locationName"] as? String else { return nil }
        guard let songTitle = dictionary["songTitle"] as? String else { return nil }
        guard let songArtist = dictionary["songArtist"] as? String else { return nil }
        guard let strSongArtwork = dictionary["songArtwork"] as? String else { return nil }
        guard let strSongId = dictionary["songId"] as? String else { return nil }
        guard let strLocation = dictionary["location"] as? String else { return nil }
        guard let contributeUid = dictionary["contributeUid"] as? String else { return nil }
        guard let contributeDate = dictionary["contributeDate"] as? String else { return nil }
        guard let pinId = dictionary["pinId"] as? String else { return nil }
        
        self.locationName = locationName
        self.songTitle = songTitle
        self.songArtist = songArtist
        self.songArtwork = strSongArtwork.toImage()
        self.songId = Int(strSongId)! as NSNumber
        self.coordinate = strLocation.toCLLocationCoordinate2D()
        self.contributeUid = contributeUid
        self.contributeDate = contributeDate
        self.pinId = pinId
    }
}

