//
//  EditAnnotationData.swift
//  iMachiLive
//
//  Created by RIVER on 2019/01/28.
//  Copyright © 2019 Reverse. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

class EditAnnotationData: NSObject {

    /** ----------------------------------------------------------------------
     # EditAnnotationData()
     ---------------------------------------------------------------------- **/
    static let sharedInstance = EditAnnotationData()
    
    
    /** ----------------------------------------------------------------------
     # init()
     ---------------------------------------------------------------------- **/
    private override init() {
        editAnnotationInfo = STAnnotationData()
        
        super.init()
    }
    
    /** ----------------------------------------------------------------------
     # annotationView
     ---------------------------------------------------------------------- **/
    var editAnnotationInfo: STAnnotationData
    
    var coordinate: CLLocationCoordinate2D?
}
