//
//  ListView.swift
//  iMachiLive
//
//  Created by RIVER on 2018/12/20.
//  Copyright © 2018 Reverse. All rights reserved.
//

import UIKit

class ListView: UIView {

    let listView: UIView!
    
    
    override init(frame: CGRect) {
        self.listView = UIView()
        super.init(frame: frame)
        commonInit(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit(frame: CGRect) {
        guard let viewController = UIStoryboard(name: "Right", bundle: nil).instantiateInitialViewController() else { return }

        listView.frame = frame
        listView.backgroundColor = .white
        listView.addSubview(viewController.view)
    }

}
