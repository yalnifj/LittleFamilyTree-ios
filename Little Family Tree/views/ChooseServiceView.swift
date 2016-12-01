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
    @IBOutlet weak var MyHeritageButton: UIButton!

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
        view.autoresizingMask = UIViewAutoresizing.flexibleWidth
        addSubview(view)
        PGVButton.isHidden = false
        //-- hide myheritage until it is ready
        MyHeritageButton.isHidden = false
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for:type(of: self))
        let nib = UINib(nibName: "ChooseServiceView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    @IBAction func FSButtonClicked(_ sender: UIButton) {
        print("FSButton clicked")
        let superview = self.view.superview
        self.view.removeFromSuperview()
        let subview = FamilySearchLogin(frame: (self.view?.bounds)!)
        subview.loginListener = self.loginListener
        superview?.addSubview(subview)
    }
    

    @IBAction func PGVButtonClicked(_ sender: UIButton) {
        print("PGVButton clicked")
        let superview = self.view.superview
        self.view.removeFromSuperview()
        let subview = PGVLogin(frame: (self.view?.bounds)!)
        subview.loginListener = self.loginListener
        superview?.addSubview(subview)
    }
    
    @IBAction func MyHeritageButtonClicked(_ sender: UIButton) {
        print("MyHeritage Button Clicked")
        let superview = self.view.superview
        self.view.removeFromSuperview()
        let subview = MyHeritageLogin(frame: (self.view?.bounds)!)
        subview.loginListener = self.loginListener
        superview?.addSubview(subview)
    }
}
