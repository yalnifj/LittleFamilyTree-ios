//
//  SettingsView.swift
//  Little Family Tree
//
//  Created by Melissa on 1/5/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import UIKit
import StoreKit

class SettingsView: UIView {

   
    @IBOutlet weak var btnBack: UIBarButtonItem!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view4: UIView!
    @IBOutlet weak var view6: UIView!
    @IBOutlet weak var view5: UIView!
    @IBOutlet weak var view7: UIView!
    @IBOutlet weak var view8: UIView!
    @IBOutlet weak var view9: UIView!
    @IBOutlet weak var view10: UIView!
    @IBOutlet weak var view11: UIView!
    @IBOutlet weak var remoteTreeType: UILabel!
    @IBOutlet weak var syncInBackgroundSwitch: UISwitch!
    @IBOutlet weak var syncUsingCellSwitch: UISwitch!
    @IBOutlet weak var syncDelaySlider: UISlider!
    @IBOutlet weak var syncDelayLabel: UILabel!
    @IBOutlet weak var quietModeSwitch: UISwitch!
	@IBOutlet weak var showStepChildrenSwitch: UISwitch!
    @IBOutlet weak var restoreButton: UIButton!
    
    @IBOutlet weak var versionLabel: UILabel!
    
    let delays = [1,2,3,5,8,12,18,24,36,48]
    
    var view:UIView!
    
    var selectedPerson:LittlePerson?
    var openingScene:LittleFamilyScene?
    
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
        
        let color:UIColor = UIColor.lightGray
        
        view1.layer.borderColor = color.cgColor
        view1.layer.borderWidth = 0.5
        view2.layer.borderColor = color.cgColor
        view2.layer.borderWidth = 0.5
        view3.layer.borderColor = color.cgColor
        view3.layer.borderWidth = 0.5
        view4.layer.borderColor = color.cgColor
        view4.layer.borderWidth = 0.5
        view5.layer.borderColor = color.cgColor
        view5.layer.borderWidth = 0.5
        view6.layer.borderColor = color.cgColor
        view6.layer.borderWidth = 0.5
        view7.layer.borderColor = color.cgColor
        view7.layer.borderWidth = 0.5
        view8.layer.borderColor = color.cgColor
        view8.layer.borderWidth = 0.5
        view9.layer.borderColor = color.cgColor
        view9.layer.borderWidth = 0.5
        view10.layer.borderColor = color.cgColor
        view10.layer.borderWidth = 0.5
        view11.layer.borderColor = color.cgColor
        view11.layer.borderWidth = 0.5
        
        let dataService = DataService.getInstance()
        let treeType = dataService.dbHelper.getProperty(DataService.SERVICE_TYPE)
        remoteTreeType.text = treeType as String?
        
        let backSync = dataService.dbHelper.getProperty(DataService.PROPERTY_SYNC_BACKGROUND)
        if backSync == nil || backSync == "true" {
            syncInBackgroundSwitch.setOn(true, animated: false)
        } else {
            syncInBackgroundSwitch.setOn(false, animated: false)
        }
        
        let syncCell = dataService.dbHelper.getProperty(DataService.PROPERTY_SYNC_CELL)
        if syncCell == nil || syncCell == "false" {
            syncUsingCellSwitch.setOn(false, animated: false)
        } else {
            syncUsingCellSwitch.setOn(true, animated: false)
        }
        
        let quietMode = dataService.dbHelper.getProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET)
        if quietMode == nil || quietMode == "false" {
            quietModeSwitch.setOn(false, animated: false)
        } else {
            quietModeSwitch.setOn(true, animated: false)
        }
		
		let showStepChildren = dataService.dbHelper.getProperty(DataService.PROPERTY_SHOW_STEP_CHILDREN)
        if showStepChildren == nil || showStepChildren == "true" {
            showStepChildrenSwitch.setOn(true, animated: false)
        } else {
            showStepChildrenSwitch.setOn(false, animated: false)
        }
        
        syncDelaySlider.minimumValue = 0
        syncDelaySlider.maximumValue = Float(delays.count-1)
        syncDelaySlider.isContinuous = true
        
        let syncDelay = dataService.dbHelper.getProperty(DataService.PROPERTY_SYNC_DELAY)
        var delay = 1
        if syncDelay != nil {
            delay = Int(syncDelay!)!
        }
        var delayIndex = delays.index(of: delay)
        if delayIndex == nil {
            delayIndex = 0
        }
        syncDelaySlider.setValue(Float(delayIndex!), animated: false)
        
        //First get the nsObject by defining as an optional anyObject
        let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject?
        
        //Then just cast the object as a String, but be careful, you may want to double check for nil
        var version = nsObject as! String
		
		let premiumStr = DataService.getInstance().dbHelper.getProperty(LittleFamilyScene.PROP_HAS_PREMIUM)
        if premiumStr != nil && premiumStr == "true" {
			version = "\(version) Premium"
		}

        versionLabel.text = version
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for:type(of: self))
        let nib = UINib(nibName: "SettingsView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    @IBAction func syncBackgroundAction(_ sender: UISwitch) {
        let dataService = DataService.getInstance()
        if sender.isOn {
            dataService.dbHelper.saveProperty(DataService.PROPERTY_SYNC_BACKGROUND, value: "true")
        } else {
            dataService.dbHelper.saveProperty(DataService.PROPERTY_SYNC_BACKGROUND, value: "false")
        }
    }
    @IBAction func syncCellAction(_ sender: UISwitch) {
        let dataService = DataService.getInstance()
        if sender.isOn {
            dataService.dbHelper.saveProperty(DataService.PROPERTY_SYNC_CELL, value: "true")
        } else {
            dataService.dbHelper.saveProperty(DataService.PROPERTY_SYNC_CELL, value: "false")
        }
    }
    @IBAction func syncDelaySliderAction(_ sender: UISlider) {
        let index = Int(round(syncDelaySlider.value))
        let delay = delays[index]
        syncDelaySlider.setValue(Float(index), animated: false)
        syncDelayLabel.text = "\(delay) hours"
        DataService.getInstance().dbHelper.saveProperty(DataService.PROPERTY_SYNC_DELAY, value: String(delay))
    }

    @IBAction func ManagePeopleAction(_ sender: UIButton) {
        self.view.removeFromSuperview()
        openingScene?.showManagePeople()
    }
    
    @IBAction func parentsGuideAction(_ sender: UIButton) {
        self.view.removeFromSuperview()
        openingScene?.showParentsGuide(SettingsPGCloseListener(os: openingScene!), skipGate: true)
    }

    @IBAction func visitWebsiteAction(_ sender: AnyObject) {
        print("Visit website")
        UIApplication.shared.openURL(URL(string:"http://www.littlefamilytree.com")!)
    }
    
    @IBAction func backButtonAction(_ sender: UIBarButtonItem) {
        print("Back Button clicked")
        self.view.removeFromSuperview()
        openingScene?.isPaused = false
    }
    
    @IBAction func quietModeToggleAction(_ sender: UISwitch) {
        let dataService = DataService.getInstance()
        if sender.isOn {
            dataService.dbHelper.saveProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET, value: "true")
        } else {
            dataService.dbHelper.saveProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET, value: "false")
        }
    }
	
	@IBAction func showStepChildrenToggleAction(_ sender: UISwitch) {
        let dataService = DataService.getInstance()
        if sender.isOn {
            dataService.dbHelper.saveProperty(DataService.PROPERTY_SHOW_STEP_CHILDREN, value: "true")
        } else {
            dataService.dbHelper.saveProperty(DataService.PROPERTY_SHOW_STEP_CHILDREN, value: "false")
        }
    }
    
    var iapHelper:IAPHelper?
    @IBAction func restorePurchases(_ sender: AnyObject) {
        iapHelper = IAPHelper(listener: restoreListener(view: self))
        iapHelper?.restorePurchases()

    }
    
    func showError(_ error:String) {
        print(error)
        let x = Int((self.frame.width - 300) / 2)
        let y = 50
        let rect = CGRect(x: x, y: y, width: 300, height: 300)
        let subview = SimpleDialogView(frame: rect)
        subview.setMessage("Error", message: error)
        self.view?.addSubview(subview)
    }
    
    class restoreListener: IAPHelperListener {
        var view:SettingsView
        init(view:SettingsView) {
            self.view = view
        }
        func onProductsReady(_ productsArray: [SKProduct]) {
            
        }
        func onTransactionComplete() {
            DataService.getInstance().dbHelper.saveProperty(LittleFamilyScene.PROP_HAS_PREMIUM, value: "true")
            DataService.getInstance().dbHelper.fireCreateOrUpdateUser(true)
        }
        func onError(_ error:String) {
            print(error)
            view.showError(error)
        }
    }
}

class SettingsPGCloseListener: ParentsGuideCloseListener {
    var openingScene:LittleFamilyScene
    init(os:LittleFamilyScene) {
        self.openingScene = os
    }
    func onClose() {
        openingScene.showSettings()
    }
}
