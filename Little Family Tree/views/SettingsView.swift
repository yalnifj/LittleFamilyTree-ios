//
//  SettingsView.swift
//  Little Family Tree
//
//  Created by Melissa on 1/5/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import UIKit

class SettingsView: UIView {

   
    @IBOutlet weak var btnBack: UIBarButtonItem!
    @IBOutlet weak var settingsTableView: UITableView!
    var view:UIView!
    
    var selectedPerson:LittlePerson?
    
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


    @IBAction func backButtonAction(sender: UIBarButtonItem) {
        print("Back Button clicked")
        self.view.removeFromSuperview()
    }
}
