//
//  FamilySearchLogin.swift
//  Little Family Tree
//
//  Created by Melissa on 11/11/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import UIKit

class FamilySearchLogin: UIView, StatusListener {

    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtError: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var btnBack: UIBarButtonItem!
    @IBOutlet weak var btnSignIn: UIBarButtonItem!
    @IBOutlet weak var btnSignIn2: UIButton!
    
    
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
        
        let dataService = DataService.getInstance()
        let username = dataService.getEncryptedProperty(DataService.SERVICE_USERNAME)
        if username != nil {
            txtUsername.text = username as String?
        }
        txtError.hidden = true
        
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass:self.dynamicType)
        let nib = UINib(nibName: "FamilySearchLogin", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }

    @IBAction func BackButtonClicked(sender: UIBarButtonItem) {
        print("Back Button clicked")
        self.view.removeFromSuperview()
    }

    @IBAction func SignInButtonClicked(sender: UIBarButtonItem) {
        print("SignIn Button clicked")
        loginAction()
    }
    
    @IBAction func SignInButton2Clicked(sender: UIButton) {
        print("SignIn2 Button clicked")
        loginAction()
    }
    
    func loginAction() {
        let username = txtUsername.text
        let password = txtPassword.text
        
        if username == nil || username?.isEmpty == true {
            showAlert("Username may not be empty")
            return
        }
        
        if password == nil || password?.isEmpty == true {
            showAlert("Password may not be empty")
            return
        }
        
        showInfoMsg("Logging into FamilySearch")
        
        let dataService = DataService.getInstance()
        let remoteService = FamilySearchService()
        
        remoteService.authenticate(username!, password: password!, onCompletion: { json, err in
            print("sessionid=\(remoteService.sessionId)")
            if remoteService.sessionId != nil {
                dataService.remoteService = remoteService
                dataService.serviceType = DataService.SERVICE_TYPE_FAMILYSEARCH
                dataService.dbHelper.saveProperty(DataService.SERVICE_TYPE, value: DataService.SERVICE_TYPE_FAMILYSEARCH)
                dataService.saveEncryptedProperty(DataService.SERVICE_USERNAME, value: username!);
                dataService.saveEncryptedProperty(DataService.SERVICE_TYPE_FAMILYSEARCH + DataService.SERVICE_TOKEN, value: password!);
                
                dataService.addStatusListener(self)
                dataService.getDefaultPerson(true, onCompletion: { person, err in
                    if person != nil {
                        print("person \(person?.id) \(person?.name)")
                        let task = InitialDataLoader(person: person!, listener: self)
                        task.execute({people, err in
                            print(people)
                            dataService.removeStatusListener(self)
                        })
                    } else {
                        self.showAlert("Unable to get default person")
                    }
                })
                
            } else {
                self.showAlert("Unable to login to FamilySearch \(err)")
            }
        })
    }
    
    func statusChanged(message: String) {
        showInfoMsg(message)
    }
    
    func showAlert(message:String) {
        txtError.hidden = false
        txtError.text = message
        txtError.textColor = UIColor.redColor()
        spinner.hidden = true
    }
    
    func showInfoMsg(message:String) {
        spinner.hidden = false
        spinner.startAnimating()
        txtError.hidden = false
        txtError.text = message
        txtError.textColor = UIColor.blackColor()
    }
}
