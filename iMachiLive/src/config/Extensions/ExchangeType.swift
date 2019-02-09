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
    
    func toMKMapPoint() -> MKMapPoint? {
        let separated = self.split(separator: ",")
        let strLattitude = separated[0]
        let strLongitude = separated[1]
        let point: MKMapPoint
            = MKMapPoint(x: (strLattitude as NSString).doubleValue,
                         y: (strLongitude as NSString).doubleValue)
        return point
    }
}

extension URL {
    func toUIImage() -> UIImage? {
        var image = UIImage()
        if let data = try? Data(contentsOf: self)
        {
            image = UIImage(data: data)!
        }
        return image
    }
}
