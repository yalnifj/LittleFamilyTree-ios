//
//  MyHeritageLogin.swift
//  Little Family Tree
//
//  Created by Bryan  Farnworth on 8/4/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import Foundation

import UIKit

class MyHeritageLogin: UIView, StatusListener, UIWebViewDelegate {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var webView: UIWebView!
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
        
        webView.delegate = self
        webView.isUserInteractionEnabled = true
        webView.scrollView.isScrollEnabled = true
        
        let url = URL(string: "https://accounts.myheritage.com/oauth2/authorize?client_id=\(service!.clientId)&redirect_uri=urn:ietf:wg:oauth:2.0:oob&scope=basic,offline_access&response_type=token")
        let request = URLRequest(url: url!)
        webView.loadRequest(request)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for:type(of: self))
        let nib = UINib(nibName: "MyHeritageLogin", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        //Sent before a web view begins loading a frame.
        print("before a web view begins loading a frame")
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        return true
    }

    public func webViewDidStartLoad(_ webView: UIWebView) {
        //Sent after a web view starts loading a frame.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        spinner.isHidden = false
        spinner.startAnimating()
        print("starting to load:")
        print(webView.request!)
    }

    public func webViewDidFinishLoad(_ webView: UIWebView) {
        //Sent after a web view finishes loading a frame.
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        spinner.isHidden = true
        spinner.stopAnimating()
        
        print("finished loading")
        print(webView.request!)//Sent after a web view finishes loading a frame.
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        if webView.request?.url?.absoluteString == "https://accounts.myheritage.com/oauth2/authorize" {
            let title = webView.stringByEvaluatingJavaScript(from: "document.title")
            if title != nil && title!.contains("Success") {
                let parts = title!.split("=")
                if parts.count > 1 {
                    var accessToken = parts[1]
                    let aParts = accessToken.split("&")
                    accessToken = aParts[0]
                    print(accessToken)
                    service?.sessionId = accessToken
                    
                    self.showInfoMsg("Loading data")
                    
                    dataService.addStatusListener(self)
                    
                    service?.getCurrentUser({data, err in
                        if data != nil {
                            let indi = data!["default_individual"]
                            let indiId = indi["id"].string
                            if indiId != nil {
                                self.dataService.dbHelper.saveProperty(DataService.SERVICE_TYPE, value: DataService.SERVICE_TYPE_MYHERITAGE)
                                self.dataService.saveEncryptedProperty(DataService.SERVICE_TYPE_MYHERITAGE + DataService.SERVICE_TOKEN, value: accessToken)
                                self.dataService.saveEncryptedProperty(DataService.SERVICE_USERNAME, value: indiId!);
                
                                self.dataService.dbHelper.fireCreateOrUpdateUser(false)
                                
                                self.dataService.getDefaultPerson(true, onCompletion: { person, err in
                                    if person != nil {
                                        print("person \(person?.id) \(person?.name)")
                                        let task = InitialDataLoader(person: person!, listener: self)
                                        task.execute({people, err in
                                            self.showInfoMsg("Finished loading")
                                            self.dataService.removeStatusListener(self)
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
                                self.showAlert("Unable to get default person \(indi)")
                            }
                        } else {
                            self.showAlert("Unable to get current user \(err)")
                        }
                    })
                } else {
                    self.showAlert("Error logging into MyHeritage")
                }
            } else {
                self.showAlert("Error logging into MyHeritage")
            }
            //print(webView.request!.allHTTPHeaderFields)
        }
    }

    public func webView(_ webView: UIWebView, didFailLoadWithError error: Error){
        //Sent if a web view failed to load a frame.
        print("failed to load")
        print(error)
    }
    
    func statusChanged(_ message: String) {
        showInfoMsg(message)
    }
    
    func showAlert(_ message:String) {
        DispatchQueue.main.async {
            self.webView.isHidden = true
            self.statusLabel.isHidden = false
            self.statusLabel.text = message
            self.statusLabel.textColor = UIColor.red
            self.spinner.isHidden = true
            print(message)
        }
    }
    
    func showInfoMsg(_ message:String) {
        DispatchQueue.main.async {
            self.webView.isHidden = true
            if message.isEmpty {
                self.spinner.isHidden = true
                self.spinner.stopAnimating()
                self.statusLabel.isHidden = true
            } else {
                self.spinner.isHidden = false
                self.spinner.startAnimating()
                self.statusLabel.isHidden = false
                self.statusLabel.text = message
                self.statusLabel.textColor = UIColor.black
                print(message)
            }
        }
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        print("Back Button clicked")
        self.view.removeFromSuperview()
        loginListener?.LoginCanceled()
    }
}
