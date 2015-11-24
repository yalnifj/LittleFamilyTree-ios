//
//  ChooseServiceView.swift
//  Little Family Tree
//
//  Created by Melissa on 11/11/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import UIKit

@IBDesignable class ChooseServiceView: UIView {
    @IBOutlet weak var FSButton: UIButton!
    @IBOutlet weak var PGVButton: UIButton!

    var view:UIView!
    
    var loginListener:LoginCompleteListener?
    
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
        let nib = UINib(nibName: "ChooseServiceView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
    @IBAction func FSButtonClicked(sender: UIButton) {
        print("FSButton clicked")
        let superview = self.view.superview
        self.view.removeFromSuperview()
        let subview = FamilySearchLogin(frame: (self.view?.bounds)!)
        subview.loginListener = self.loginListener
        superview?.addSubview(subview)
    }
    

    @IBAction func PGVButtonClicked(sender: UIButton) {
        print("PGVButton clicked")
        self.view.removeFromSuperview()
    }
}
