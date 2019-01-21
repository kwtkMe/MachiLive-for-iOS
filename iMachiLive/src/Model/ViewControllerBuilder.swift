//
//  StoryboardBuilder.swift
//  iMachiLive
//
//  Created by RIVER on 2019/01/21.
//  Copyright © 2019 Reverse. All rights reserved.
//

import UIKit

class ViewControllerBuilder: NSObject {
    
    /** ----------------------------------------------------------------------
     # UserData()
     ---------------------------------------------------------------------- **/
    static let sharedInstanse = ViewControllerBuilder()
    
    
    override init() {
        super.init()
    }
    
    
    // MainViewController
    func buildMainViewController() -> UIViewController{
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "first")
        
        return viewController
    }
    
    // UserViewController
    func buildUserViewController() -> UIViewController{
        let storyboard = UIStoryboard(name: "UserView", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "first")
        
        return viewController
    }
    
    
}
