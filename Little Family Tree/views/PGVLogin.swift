//
//  FamilySearchLogin.swift
//  Little Family Tree
//
//  Created by Melissa on 11/11/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import UIKit

class PGVLogin: UIView, StatusListener, UITextFieldDelegate {

    @IBOutlet weak var txtDefaultId: UITextField!
    @IBOutlet weak var txtUrl: UITextField!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtError: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var btnBack: UIBarButtonItem!
    @IBOutlet weak var btnSignIn: UIBarButtonItem!
    @IBOutlet weak var btnSignIn2: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var view:UIView!
    var activeField: UITextField?
    
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
        let url = dataService.dbHelper.getProperty(DataService.SERVICE_BASEURL)
        if url != nil {
            txtUrl.text = url as String?
        } else {
            txtUrl.text = "http://"
        }
        let username = dataService.getEncryptedProperty(DataService.SERVICE_USERNAME)
        if username != nil {
            txtUsername.text = username as String?
        }
        let defaultId = dataService.dbHelper.getProperty(DataService.SERVICE_DEFAULTPERSONID)
        if defaultId != nil {
            txtDefaultId.text = defaultId as String?
        }
        txtError.isHidden = true
        spinner.isHidden = true
        spinner.stopAnimating()
        
        self.txtUrl.delegate = self
        self.txtDefaultId.delegate = self
        self.txtPassword.delegate = self
        self.txtUsername.delegate = self
        
        registerForKeyboardNotifications()
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for:type(of: self))
        let nib = UINib(nibName: "PGVLogin", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }

    @IBAction func BackButtonClicked(_ sender: UIBarButtonItem) {
        print("Back Button clicked")
        deregisterFromKeyboardNotifications()
        self.view.removeFromSuperview()
    }

    @IBAction func SignInButtonClicked(_ sender: UIBarButtonItem) {
        print("SignIn Button clicked")
        view.endEditing(true)
        loginAction()
    }
    
    @IBAction func SignInButton2Clicked(_ sender: UIButton) {
        print("SignIn2 Button clicked")
        view.endEditing(true)
        loginAction()
    }
    
    func loginAction() {
        view.endEditing(true)
        let url = txtUrl.text
        let username = txtUsername.text
        let password = txtPassword.text
        var defaultPersonId = txtDefaultId.text
        
        if url == nil || url?.isEmpty == true {
            showAlert("URL may not be empty")
            return
        }
        
        if username == nil || username?.isEmpty == true {
            showAlert("Username may not be empty")
            return
        }
        
        if password == nil || password?.isEmpty == true {
            showAlert("Password may not be empty")
            return
        }
        
        if defaultPersonId == nil || defaultPersonId?.isEmpty == true {
            defaultPersonId = "I1"
        }
        
        showInfoMsg("Logging into PhpGedView")
        
        let dataService = DataService.getInstance()
        let remoteService = PGVService(base: url!, defaultPersonId: defaultPersonId!)
        dataService.serviceType = DataService.SERVICE_TYPE_PHPGEDVIEW
        dataService.remoteService = remoteService
        
        remoteService.getVersion({ version, err in
            if err != nil {
                self.showAlert("Error connecting to PhpGedView \(err!)")
            } else if version==nil {
                self.showAlert("Error connecting to PhpGedView.  Check your connection parameters and try again.")
            } else {
                self.showInfoMsg("PhpGedView Version \(version!)")
                
                remoteService.authenticate(username!, password: password!, onCompletion: { sessionId, err in
                    print("sessionid=\(remoteService.sessionId)")
                    if remoteService.sessionId != nil {
                        dataService.dbHelper.saveProperty(DataService.SERVICE_TYPE, value: DataService.SERVICE_TYPE_PHPGEDVIEW)
                        dataService.dbHelper.saveProperty(DataService.SERVICE_BASEURL, value: url!)
                        dataService.saveEncryptedProperty(DataService.SERVICE_USERNAME, value: username!);
                        dataService.saveEncryptedProperty(DataService.SERVICE_TYPE_PHPGEDVIEW + DataService.SERVICE_TOKEN, value: password!);
                        dataService.dbHelper.saveProperty(DataService.SERVICE_DEFAULTPERSONID, value: defaultPersonId!);
                        
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
                                        self.deregisterFromKeyboardNotifications()
                                        self.loginListener?.LoginComplete()
                                    }
                                })
                            } else {
                                self.showAlert("Unable to get default person \(err)")
                            }
                        })
                        
                    } else {
                        self.showAlert("Unable to login to PhpGedView \(err)")
                    }
                })
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
    
    func registerForKeyboardNotifications()
    {
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(PGVLogin.keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PGVLogin.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    func deregisterFromKeyboardNotifications()
    {
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWasShown(_ notification: Notification)
    {
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        let info : NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let _ = activeField
        {
            if (!aRect.contains(activeField!.frame.origin))
            {
                self.scrollView.scrollRectToVisible(activeField!.frame, animated: true)
            }
        }
        
        
    }
    
    
    func keyboardWillBeHidden(_ notification: Notification)
    {
        //Once keyboard disappears, restore original positions
        let info : NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        activeField = nil
    }
}
