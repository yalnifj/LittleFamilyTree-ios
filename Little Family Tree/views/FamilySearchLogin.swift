//
//  FamilySearchLogin.swift
//  Little Family Tree
//
//  Created by Melissa on 11/11/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import UIKit

class FamilySearchLogin: UIView {

    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBOutlet weak var btnSignIn: UIBarButtonItem!

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
        let nib = UINib(nibName: "FamilySearchLogin", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }


    @IBAction func SignInButtonClicked(sender: UIBarButtonItem) {
        print("SignIn Button clicked")
    }
}
