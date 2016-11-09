//
//  MyHeritageLogin.swift
//  Little Family Tree
//
//  Created by Bryan  Farnworth on 8/4/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import Foundation

import UIKit

class MyHeritageLogin: UIView, StatusListener {
    
    var view:UIView!
    
    var loginListener:LoginCompleteListener?
    var service:MyHeritageService?
    var dataService = DataService.getInstance()
    
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
        
        
        service = MyHeritageService()
        dataService.serviceType = DataService.SERVICE_TYPE_MYHERITAGE
        dataService.remoteService = service
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for:type(of: self))
        let nib = UINib(nibName: "MyHeritageLogin", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }

    func statusChanged(_ message: String) {
    }
}
