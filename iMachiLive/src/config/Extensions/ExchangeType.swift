//
//  ExchangeType.swift
//  iMachiLive
//
//  Created by RIVER on 2019/02/07.
//  Copyright © 2019 Reverse. All rights reserved.
//

import Foundation
import UIKit

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
}
