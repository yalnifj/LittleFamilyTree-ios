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
        
        let dataService = DataService.getInstance()
        let username = dataService.getEncryptedProperty(DataService.SERVICE_USERNAME)
        if username != nil {
            txtUsername.text = username as String?
        }
        //txtUsername.text = "tum000205905"
        //txtPassword.text = "1234pass"
        txtError.isHidden = true
        spinner.isHidden = true
        spinner.stopAnimating()
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for:type(of: self))
        let nib = UINib(nibName: "FamilySearchLogin", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }

    @IBAction func BackButtonClicked(_ sender: UIBarButtonItem) {
        print("Back Button clicked")
        self.view.removeFromSuperview()
    }

    @IBAction func SignInButtonClicked(_ sender: UIBarButtonItem) {
        print("SignIn Button clicked")
        loginAction()
    }
    
    @IBAction func SignInButton2Clicked(_ sender: UIButton) {
        print("SignIn2 Button clicked")
        loginAction()
    }
    
    func loginAction() {
        view.endEditing(true)
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
        let remoteService = FamilySearchService.sharedInstance
        dataService.serviceType = DataService.SERVICE_TYPE_FAMILYSEARCH as NSString?
        dataService.remoteService = remoteService
        
        remoteService.authenticate(username!, password: password!, onCompletion: { sessionId, err in
            print("sessionid=\(remoteService.sessionId)")
            if remoteService.sessionId != nil {
                dataService.dbHelper.saveProperty(DataService.SERVICE_TYPE, value: DataService.SERVICE_TYPE_FAMILYSEARCH)
                dataService.saveEncryptedProperty(DataService.SERVICE_USERNAME, value: username!);
                dataService.saveEncryptedProperty(DataService.SERVICE_TYPE_FAMILYSEARCH + DataService.SERVICE_TOKEN, value: password!);
                
                dataService.dbHelper.fireCreateOrUpdateUser(false)
                
                dataService.addStatusListener(self)
                dataService.getDefaultPerson(true, onCompletion: { person, err in
                    if person != nil {
                        print("person \(person?.id) \(person?.name)")
                        let task = InitialDataLoader(person: person!, listener: self)
                        task.execute({people, err in
                            self.spinner.stopAnimating()
                            self.spinner.isHidden = true
                            self.txtError.isHidden = true
                            print(people?.count)
                            dataService.removeStatusListener(self)
                            DispatchQueue.main.async {
                                self.removeFromSuperview()
                            }
                            if self.loginListener != nil {
                                self.loginListener?.LoginComplete()
                            }
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
    
    func statusChanged(_ message: String) {
        showInfoMsg(message)
    }
    
    func showAlert(_ message:String) {
        DispatchQueue.main.async {
            self.txtError.isHidden = false
            self.txtError.text = message
            self.txtError.textColor = UIColor.red
            self.spinner.isHidden = true
            print(message)
        }
    }
    
    func showInfoMsg(_ message:String) {
        DispatchQueue.main.async {
            if message.isEmpty {
                self.spinner.isHidden = true
                self.spinner.stopAnimating()
                self.txtError.isHidden = true
            } else {
                self.spinner.isHidden = false
                self.spinner.startAnimating()
                self.txtError.isHidden = false
                self.txtError.text = message
                self.txtError.textColor = UIColor.black
                print(message)
            }
        }
    }
}
