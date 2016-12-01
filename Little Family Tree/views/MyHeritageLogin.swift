//
//  MyHeritageLogin.swift
//  Little Family Tree
//
//  Created by Bryan  Farnworth on 8/4/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import Foundation

import UIKit

class MyHeritageLogin: UIView, StatusListener, MyHeritageSessionListener {
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
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
        
        infoLabel.text = "Logging in..."
        
        service = MyHeritageService()
        dataService.serviceType = DataService.SERVICE_TYPE_MYHERITAGE
        dataService.remoteService = service
        service?.sessionListener = self
        service?.authWithDialog()
        
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for:type(of: self))
        let nib = UINib(nibName: "MyHeritageLogin", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }

    func statusChanged(_ message: String) {
        infoLabel.text = message
    }
    
    func userLoggedIn() {
        infoLabel.text = "Authentication successful"
        
        service?.getCurrentUser({data, err in
        
            let indi = data!["default_individual"] as! NSDictionary
            let indiId = indi["id"] as! String
            
            self.dataService.dbHelper.saveProperty(DataService.SERVICE_TYPE, value: DataService.SERVICE_TYPE_MYHERITAGE)
            self.dataService.saveEncryptedProperty(DataService.SERVICE_USERNAME, value: indiId);
            self.dataService.saveEncryptedProperty(DataService.SERVICE_TYPE_MYHERITAGE + DataService.SERVICE_TOKEN, value: self.service!.sessionId!);
            
            self.dataService.dbHelper.fireCreateOrUpdateUser(false)
            
            self.dataService.addStatusListener(self)
            self.dataService.getDefaultPerson(true, onCompletion: { person, err in
                if person != nil {
                    print("person \(person?.id) \(person?.name)")
                    let task = InitialDataLoader(person: person!, listener: self)
                    task.execute({people, err in
                        self.spinner.stopAnimating()
                        self.spinner.isHidden = true
                        self.dataService.removeStatusListener(self)
                        DispatchQueue.main.async {
                            self.removeFromSuperview()
                        }
                        if self.loginListener != nil {
                            self.loginListener?.LoginComplete()
                        }
                    })
                } else {
                    self.statusChanged("Unable to get default person")
                }
            })

        })
    }
    
    func userDidNotLogIn() {
        infoLabel.text = "Failed to authenticate with MyHeritage"
        spinner.isHidden = true
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        print("Back Button clicked")
        self.view.removeFromSuperview()
        loginListener?.LoginCanceled()
    }
}
