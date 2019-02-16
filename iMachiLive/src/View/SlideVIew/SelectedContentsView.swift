//
//  ExpandedView.swift
//  SlideUpViewAnimation
//
//  Created by RIVER on 2019/02/05.
//  Copyright © 2019 Reverse. All rights reserved.
//

import UIKit

class SelectedContentsView: UIView {

    @IBOutlet weak var songartworkImageView: UIImageView!
    @IBOutlet weak var playerstatusButton: UIButton!
    @IBOutlet weak var songtitleLabel: UILabel!
    @IBOutlet weak var songartistImageView: UILabel!
    @IBOutlet weak var contributeravatarImageView: UIImageView!
    @IBOutlet weak var contributernameLabel: UILabel!
    @IBOutlet weak var contributedateLabel: UILabel!
    
    let notification = NotificationCenter.default
    
    deinit {
        notification.removeObserver(self)
    }
    
    // コードから初期化
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    // Storyboardから初期化
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
    }
    
    func loadNib(){
        let view = Bundle.main.loadNibNamed("SelectedContentsView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }

    @IBAction func tapMusicStatusButton(_ sender: UIButton) {

    }
    @IBAction func tapEditButton(_ sender: UIButton) {
        notification.post(name: .AnnotationEdit, object: nil)
    }
    @IBAction func tapDeleteButton(_ sender: UIButton) {
        notification.post(name: .AnnotationRemove, object: nil)
    }
    
}
