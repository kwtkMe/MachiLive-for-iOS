//
//  ExchangeType.swift
//  iMachiLive
//
//  Created by RIVER on 2019/02/07.
//  Copyright © 2019 Reverse. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension UIImage {
    
    func toString() -> String? {
        let data: Data? = self.pngData()
        return data?.base64EncodedString(options: .endLineWithLineFeed)
    }
}

extension String {
    
    func toImage() -> UIImage? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters){
            return UIImage(data: data)
        }
        return nil
    }
    
    func toCLLocationCoordinate2D() -> CLLocationCoordinate2D? {
        let separated = self.split(separator: ",")
        let strLattitude = separated[0]
        let strLongitude = separated[1]
        let point: MKMapPoint
            = MKMapPoint(x: (strLattitude as NSString).doubleValue,
                         y: (strLongitude as NSString).doubleValue)
        let coordinate
            = CLLocationCoordinate2DMake(point.coordinate.latitude,
                                                    point.coordinate.longitude)
        return coordinate
    }
}
