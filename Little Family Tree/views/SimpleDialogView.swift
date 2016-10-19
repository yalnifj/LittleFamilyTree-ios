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
        view.autoresizingMask = UIViewAutoresizing.flexibleWidth
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for:type(of: self))
        let nib = UINib(nibName: "SimpleDialogView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }

    func setMessage(_ title:String, message:String) {
        titleBar.topItem?.title = title
        
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.sizeToFit()
    }
    
    @IBAction func closeButtonClicked(_ sender: AnyObject) {
        self.removeFromSuperview()
        if listener != nil {
            listener!.onDialogClose()
        }
    }
    
}

protocol SimpleDialogCloseListener {
    func onDialogClose()
}
