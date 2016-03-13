//
//  SimpleDialogView.swift
//  Little Family Tree
//
//  Created by Melissa on 3/10/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import UIKit

class SimpleDialogView: UIView {
    
    
    @IBOutlet weak var titleBar: UINavigationBar!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    
    var view:UIView!
    
    var listener:SimpleDialogCloseListener?
    
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
        titleBar.topItem?.title = title
        
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.sizeToFit()
    }
    
    @IBAction func closeButtonClicked(sender: AnyObject) {
        self.removeFromSuperview()
        if listener != nil {
            listener!.onDialogClose()
        }
    }
    
}

protocol SimpleDialogCloseListener {
    func onDialogClose()
}