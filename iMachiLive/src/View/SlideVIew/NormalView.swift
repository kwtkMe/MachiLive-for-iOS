//
//  NormalView.swift
//  SlideUpViewAnimation
//
//  Created by RIVER on 2019/02/05.
//  Copyright © 2019 Reverse. All rights reserved.
//

import UIKit

class NormalView:
    UIView,
    UISearchBarDelegate
{

    @IBOutlet weak var locationSearchBar: UISearchBar!
    
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
        let view = Bundle.main.loadNibNamed("NormalView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        
        locationSearchBar.delegate = self
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.endEditing(true)
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        locationSearchBar.resignFirstResponder()
        return true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.endEditing(true)
    }

}
