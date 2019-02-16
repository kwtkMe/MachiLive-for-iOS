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
import MediaPlayer

extension MPMediaItem {
    
    func toNSNumber() -> NSNumber? {
        var itemNumber: NSNumber?
        if let data = self.value(forProperty: MPMediaItemPropertyPersistentID) {
            itemNumber = data as? NSNumber
        }
        return itemNumber
    }
}

extension NSNumber {
    
    func toMediaItem() -> MPMediaItem {
        
        let property: MPMediaPropertyPredicate
            = MPMediaPropertyPredicate( value: self, forProperty: MPMediaItemPropertyPersistentID )
        let query: MPMediaQuery = MPMediaQuery()
        query.addFilterPredicate( property )
        
        var items: [MPMediaItem] = query.items as! [MPMediaItem]
        
        return items[items.count - 1]
        
    }

}

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
        let location: CLLocationCoordinate2D
            = CLLocationCoordinate2DMake(point.x, point.y)
        return location
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
