//
//  SimpleDialogView.swift
//  Little Family Tree
//
//  Created by Melissa on 3/10/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import Foundation

import UIKit

class SimpleDialogView: UIView {
    
    
    
    var view:UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass:self.dynamicType)
        let nib = UINib(nibName: "SettingsView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }

    func setMessage(title:String, message:String) {
        
    }
    
}