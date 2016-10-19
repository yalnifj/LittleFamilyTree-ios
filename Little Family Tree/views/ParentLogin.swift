//
//  FamilySearchLogin.swift
//  Little Family Tree
//
//  Created by Melissa on 11/11/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import UIKit

class ParentLogin: UIView {

    
    @IBOutlet weak var serviceTypeImage: UIImageView!
    
    @IBOutlet weak var btnBack: UIBarButtonItem!
    @IBOutlet weak var btnSignIn: UIBarButtonItem!
    @IBOutlet weak var btnSignIn2: UIButton!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var txtError: UILabel!
	@IBOutlet weak var chkRemember: UISwitch!

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
        //txtPassword.text = "1234pass"
		chkRemember.setOn(false, animated: false)
        txtError.isHidden = true
        spinner.isHidden = true
        spinner.stopAnimating()
		
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for:type(of: self))
        let nib = UINib(nibName: "ParentLogin", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }

    @IBAction func BackButtonClicked(_ sender: UIBarButtonItem) {
        print("Back Button clicked")
        self.view.removeFromSuperview()
        if self.loginListener != nil {
            loginListener?.LoginCanceled()
        }
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
        spinner.isHidden = false
        spinner.startAnimating()
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
        
        let dataService = DataService.getInstance()
        let storedUsername = dataService.getEncryptedProperty(DataService.SERVICE_USERNAME)
        let storedPass = dataService.getEncryptedProperty(DataService.SERVICE_TYPE_FAMILYSEARCH + DataService.SERVICE_TOKEN)
        if username == storedUsername && password == storedPass {
            txtUsername.text = ""
            txtPassword.text = ""
            if self.loginListener != nil {
				if chkRemember.isOn {
					let now = Foundation.Date()
					dataService.dbHelper.saveProperty(DataService.PROPERTY_REMEMBER_ME, value: now.timeIntervalSince1970.description)
				} else {
					dataService.dbHelper.saveProperty(DataService.PROPERTY_REMEMBER_ME, value: "0")
				}
                self.view.removeFromSuperview()
                self.loginListener?.LoginComplete()
            }
        } else {
            showAlert("Unable to authorize credentials.")
        }
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
