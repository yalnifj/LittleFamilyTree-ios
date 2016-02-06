//
//  SettingsView.swift
//  Little Family Tree
//
//  Created by Melissa on 1/5/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import UIKit

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
    @IBOutlet weak var remoteTreeType: UILabel!
    @IBOutlet weak var syncInBackgroundSwitch: UISwitch!
    @IBOutlet weak var syncUsingCellSwitch: UISwitch!
    @IBOutlet weak var syncDelaySlider: UISlider!
    @IBOutlet weak var syncDelayLabel: UILabel!
    @IBOutlet weak var quietModeSwitch: UISwitch!
    
    @IBOutlet weak var versionLabel: UILabel!
    
    let delays = [1,2,3,5,8,12,18,24,36,48]
    
    var view:UIView!
    
    var selectedPerson:LittlePerson?
    
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
        
        let color:UIColor = UIColor.lightGrayColor()
        
        view1.layer.borderColor = color.CGColor
        view1.layer.borderWidth = 0.5
        view2.layer.borderColor = color.CGColor
        view2.layer.borderWidth = 0.5
        view3.layer.borderColor = color.CGColor
        view3.layer.borderWidth = 0.5
        view4.layer.borderColor = color.CGColor
        view4.layer.borderWidth = 0.5
        view5.layer.borderColor = color.CGColor
        view5.layer.borderWidth = 0.5
        view6.layer.borderColor = color.CGColor
        view6.layer.borderWidth = 0.5
        view7.layer.borderColor = color.CGColor
        view7.layer.borderWidth = 0.5
        view8.layer.borderColor = color.CGColor
        view8.layer.borderWidth = 0.5
        view9.layer.borderColor = color.CGColor
        view9.layer.borderWidth = 0.5
        
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
        
        syncDelaySlider.minimumValue = 0
        syncDelaySlider.maximumValue = Float(delays.count-1)
        syncDelaySlider.continuous = true
        
        let syncDelay = dataService.dbHelper.getProperty(DataService.PROPERTY_SYNC_DELAY)
        var delay = 1
        if syncDelay != nil {
            delay = Int(syncDelay!)!
        }
        var delayIndex = delays.indexOf(delay)
        if delayIndex == nil {
            delayIndex = 0
        }
        syncDelaySlider.setValue(Float(delayIndex!), animated: false)
        
        versionLabel.text = "1.0.2"
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass:self.dynamicType)
        let nib = UINib(nibName: "SettingsView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    @IBAction func syncBackgroundAction(sender: UISwitch) {
        let dataService = DataService.getInstance()
        if sender.on {
            dataService.dbHelper.saveProperty(DataService.PROPERTY_SYNC_BACKGROUND, value: "true")
        } else {
            dataService.dbHelper.saveProperty(DataService.PROPERTY_SYNC_BACKGROUND, value: "false")
        }
    }
    @IBAction func syncCellAction(sender: UISwitch) {
        let dataService = DataService.getInstance()
        if sender.on {
            dataService.dbHelper.saveProperty(DataService.PROPERTY_SYNC_CELL, value: "true")
        } else {
            dataService.dbHelper.saveProperty(DataService.PROPERTY_SYNC_CELL, value: "false")
        }
    }
    @IBAction func syncDelaySliderAction(sender: UISlider) {
        let index = Int(round(syncDelaySlider.value))
        let delay = delays[index]
        syncDelaySlider.setValue(Float(index), animated: false)
        syncDelayLabel.text = "\(delay) hours"
        DataService.getInstance().dbHelper.saveProperty(DataService.PROPERTY_SYNC_DELAY, value: String(delay))
    }

    @IBAction func ManagePeopleAction(sender: UIButton) {
    }
    
    @IBAction func parentsGuideAction(sender: UIButton) {
        let subview = ParentsGuide(frame: (self.view?.bounds)!)
        self.view?.addSubview(subview)
    }

    @IBAction func visitWebsiteAction(sender: AnyObject) {
        print("Visit website")
        UIApplication.sharedApplication().openURL(NSURL(string:"http://www.littlefamilytree.com")!)
    }
    
    @IBAction func backButtonAction(sender: UIBarButtonItem) {
        print("Back Button clicked")
        self.view.removeFromSuperview()
    }
    
    @IBAction func quietModeToggleAction(sender: UISwitch) {
        let dataService = DataService.getInstance()
        if sender.on {
            dataService.dbHelper.saveProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET, value: "true")
        } else {
            dataService.dbHelper.saveProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET, value: "false")
        }
    }
}
