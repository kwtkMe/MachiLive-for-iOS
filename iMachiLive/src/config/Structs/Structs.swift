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

struct STAnnotationViewData {
    var songTitle: String?
    var songArtist: String?
    var songArtwork: UIImage?
}

public struct STSliderViewData {
    var locationName: String?
    var songTitle: String?
    var songArtist: String?
    var songArtwork: UIImage?
    var coordinate: CLLocationCoordinate2D?
}
