//
//  Pin.swift
//  iMachiLive
//
//  Created by RIVER on 2019/02/08.
//  Copyright © 2019 Reverse. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import Firebase

class Pin: NSObject {
    let locationName: String?
    let songTitle: String?
    let songArtist: String?
    let songArtwork: UIImage?
    let location: MKMapPoint?
    
    init? (snapshot: DataSnapshot) {
        let dic = snapshot.value as! NSDictionary
        guard let locationName = dic["locationName"] as? String else { return nil }
        guard let songTitle = dic["songTitle"] as? String else { return nil }
        guard let songArtist = dic["songArtist"] as? String else { return nil }
        guard let strsongArtwork = dic["locationName"] as? String else { return nil }
        guard let strLocation = dic["location"] as? String else { return nil }
        
        self.locationName = locationName
        self.songTitle = songTitle
        self.songArtist = songArtist
        self.songArtwork = strsongArtwork.toImage()
        self.location = strLocation.toMKMapPoint()
    }
}
