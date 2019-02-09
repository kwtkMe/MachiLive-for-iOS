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

public struct STAnnotationData {
    var locationName: String?
    var songTitle: String?
    var songArtist: String?
    var songArtwork: UIImage?
    var coordinate: CLLocationCoordinate2D?
}

public struct STPin {
    let locationName: String?
    let songTitle: String?
    let songArtist: String?
    let songArtwork: UIImage?
    let location: MKMapPoint?
    let contributeUid: String?
    let contributeDate: String?
    let pinId: String?
    
    init? (snapshot: DataSnapshot) {
        let dictionary = snapshot.value as! NSDictionary
        guard let locationName = dictionary["locationName"] as? String else { return nil }
        guard let songTitle = dictionary["songTitle"] as? String else { return nil }
        guard let songArtist = dictionary["songArtist"] as? String else { return nil }
        guard let strsongArtwork = dictionary["songArtwork"] as? String else { return nil }
        guard let strLocation = dictionary["location"] as? String else { return nil }
        guard let contributeUid = dictionary["contributeUid"] as? String else { return nil }
        guard let contributeDate = dictionary["contributeDate"] as? String else { return nil }
        guard let pinId = dictionary["pinId"] as? String else { return nil }
        
        self.locationName = locationName
        self.songTitle = songTitle
        self.songArtist = songArtist
        self.songArtwork = strsongArtwork.toImage()
        self.location = strLocation.toMKMapPoint()
        self.contributeUid = contributeUid
        self.contributeDate = contributeDate
        self.pinId = pinId
    }
}

