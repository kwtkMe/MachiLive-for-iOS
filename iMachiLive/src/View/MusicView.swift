//
//  MusicView.swift
//  iMachiLive
//
//  Created by RIVER on 2018/12/20.
//  Copyright © 2018 Reverse. All rights reserved.
//

import UIKit

class MusicView: UIView {
    
    let musicView: UIView!

    
    override init(frame: CGRect) {
        self.musicView = UIView()
        super.init(frame: frame)
        commonInit(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit(frame: CGRect) {
        guard let viewController = UIStoryboard(name: "Left", bundle: nil).instantiateInitialViewController() else { return }
        
        musicView.frame = frame
        musicView.backgroundColor = .white
        musicView.addSubview(viewController.view)
    }
    
    
}
