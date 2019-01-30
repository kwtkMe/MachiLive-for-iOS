//
//  CustomAnnotationView.swift
//  iMachiLive
//
//  Created by RIVER on 2019/01/29.
//  Copyright © 2019 Reverse. All rights reserved.
//

import UIKit

class CustomAnnotationView: UIView {

    @IBOutlet weak var locationnameLabel: UILabel!
    @IBOutlet weak var songartworkImageView: UIImageView!
    @IBOutlet weak var songnameLabel: UILabel!
    @IBOutlet weak var songartistLabel: UILabel!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        loadNib()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }
    
    func loadNib(){
        let view = Bundle.main.loadNibNamed("CustomAnnotationView",
                                            owner: self,
                                            options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }
    
}
