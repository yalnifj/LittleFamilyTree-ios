//
//  ParentsGuide.swift
//  Little Family Tree
//
//  Created by Melissa on 1/7/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import UIKit

class ParentsGuide: UIView {

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
        let nib = UINib(nibName: "ParentsGuide", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }

}
