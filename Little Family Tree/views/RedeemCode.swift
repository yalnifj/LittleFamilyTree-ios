//
//  SearchPeople.swift
//  Little Family Tree
//
//  Created by Melissa on 2/6/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import Foundation
import UIKit

class RedeemCode: UIView {
    
    var view:UIView!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var codeTxt: UITextField!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var openingScene:LittleFamilyScene?

    
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
        let nib = UINib(nibName: "RedeemCode", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
    @IBAction func backButtonAction(sender: AnyObject) {
        print("Back Button Clicked")
        self.view.removeFromSuperview()
        openingScene?.showSettings()
    }
    
    @IBAction func validateButtonAction(sender: AnyObject) {
        statusLbl.text = "Validating code..."
        spinner.startAnimating()
        DataService.getInstance().dbHelper.validateCode(codeTxt.text!, onCompletion: { valid in
            self.spinner.stopAnimating()
            if valid {
                DataService.getInstance().dbHelper.saveProperty(LittleFamilyScene.PROP_HAS_PREMIUM, value: "true")
                DataService.getInstance().dbHelper.fireCreateOrUpdateUser(true)
                self.statusLbl.text = "Successfully validated code"
            } else {
                self.statusLbl.text = "Unable to validate code"
            }
        })
    }
}