//
//  StoryboardBuilder.swift
//  iMachiLive
//
//  Created by RIVER on 2019/01/21.
//  Copyright © 2019 Reverse. All rights reserved.
//

import UIKit

class StoryboardBuilder: NSObject {
    
    static let sharedInstanse = StoryboardBuilder()
    var mainStoryboard: UIStoryboard!
    
    override init() {
        super.init()
        mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
    }
    
    // MainViewController
    func buildMainViewController() -> UIViewController{
        return mainStoryboard.instantiateViewController(withIdentifier: "Main")
    }
    
    // UserViewController
    func buildUserViewController() -> UIViewController{
        return mainStoryboard.instantiateViewController(withIdentifier: "User")
    }
    
    
}
