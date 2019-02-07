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
        editedAnnotationViewInfo = STAnnotationViewData()
        editedSliderViewInfo = STSliderViewData()
        
        super.init()
    }
    
    /** ----------------------------------------------------------------------
     # annotationView
     ---------------------------------------------------------------------- **/
    var editedAnnotationViewInfo: STAnnotationViewData
    var editedSliderViewInfo: STSliderViewData
    
    var coordinate: CLLocationCoordinate2D?
}
