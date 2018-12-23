//
//  Application.swift
//  iMachiLive
//
//  Created by RIVER on 2018/12/22.
//  Copyright © 2018 Reverse. All rights reserved.
//

import Foundation

class Application {
    
    func getTopViewController() -> UIViewController? {
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            var topViewControlelr: UIViewController = rootViewController
            
            while let presentedViewController = topViewControlelr.presentedViewController {
                topViewControlelr = presentedViewController
            }
            
            return topViewControlelr
        } else {
            return nil
        }
    }
    
}
