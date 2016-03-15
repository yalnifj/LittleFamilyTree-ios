//
//  PersonDetailsView.swift
//  Little Family Tree
//
//  Created by Melissa on 2/9/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import UIKit

class PersonDetailsView: UIView {

    var view:UIView!
    var person:LittlePerson?
    var selectedPerson:LittlePerson?
    
    @IBOutlet weak var portraitImg: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var remoteIdLbl: UILabel!
    
    @IBOutlet weak var visibleSwitch: UISwitch!
    @IBOutlet weak var genderLbl: UILabel!
    @IBOutlet weak var relationshipLbl: UILabel!
    @IBOutlet weak var birthYearLbl: UILabel!
    @IBOutlet weak var birthPlaceLbl: UILabel!
    @IBOutlet weak var livingLbl: UILabel!
    @IBOutlet weak var hasParentsLbl: UILabel!
    @IBOutlet weak var hasSpousesLbl: UILabel!
    @IBOutlet weak var hasChildrenLbl: UILabel!
    @IBOutlet weak var hasPicturesLbl: UILabel!
    @IBOutlet weak var lastSyncLbl: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var syncButton: UIButton!
    
    var listener:PersonDetailsCloseListener?
    
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

    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass:self.dynamicType)
        let nib = UINib(nibName: "PersonDetailsView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }

    func showPerson(person:LittlePerson) {
        self.person = person
        
        let dataService = DataService.getInstance()
        let dbHelper = dataService.dbHelper
        
        let photo = TextureHelper.getPortraitImage(self.person!)
        self.portraitImg.image = photo
        
        self.nameLabel.text = person.name as String?
        self.remoteIdLbl.text = person.familySearchId as String?
        
        self.visibleSwitch.on = person.active
        if person.gender == GenderType.FEMALE {
            self.genderLbl.text = "Female"
        } else if person.gender == GenderType.MALE {
            self.genderLbl.text = "Male"
        } else {
            self.genderLbl.text = "Unknown"
        }
        
        let relationship = RelationshipCalculator.getRelationship(selectedPerson, p: person)
        self.relationshipLbl.text = relationship
        
        if person.birthDate != nil {
            let components = NSCalendar.currentCalendar().components(.Year, fromDate: person.birthDate!)
            self.birthYearLbl.text = "\(components.year)"
        } else {
            self.birthYearLbl.text = ""
        }
        
        self.birthPlaceLbl.text = person.birthPlace as String?
        
        if person.alive != nil && person.alive! == true {
            self.livingLbl.text = "Yes"
        } else {
            self.livingLbl.text = "No"
        }
        
        if person.hasParents == nil {
            self.hasParentsLbl.text = "Not synced"
        } else {
            if person.hasParents! == true {
                let parents = dbHelper.getParentsForPerson(person.id!)
                if parents == nil || parents!.count == 0 {
                    self.hasParentsLbl.text = "No"
                } else {
                    self.hasParentsLbl.text = "Yes \(parents!.count)"
                }
            } else {
                self.hasParentsLbl.text = "No"
            }
        }
        
        if person.hasSpouses == nil {
            self.hasSpousesLbl.text = "Not synced"
        } else {
            if person.hasSpouses! == true {
                let spouses = dbHelper.getSpousesForPerson(person.id!)
                if spouses == nil || spouses!.count == 0 {
                    self.hasSpousesLbl.text = "No"
                } else {
                    self.hasSpousesLbl.text = "Yes \(spouses!.count)"
                }
            } else {
                self.hasSpousesLbl.text = "No"
            }
        }
        
        if person.hasChildren == nil {
            self.hasChildrenLbl.text = "Not synced"
        } else {
            if person.hasChildren! == true {
                let children = dbHelper.getChildrenForPerson(person.id!)
                if children == nil || children!.count == 0 {
                    self.hasChildrenLbl.text = "No"
                } else {
                    self.hasChildrenLbl.text = "Yes \(children!.count)"
                }
            } else {
                self.hasChildrenLbl.text = "No"
            }
        }
        
        if person.hasMedia == nil {
            self.hasPicturesLbl.text = "Not synced"
        } else {
            if person.hasMedia! == true {
                let media = dbHelper.getMediaForPerson(person.id!)
                if media.count == 0 {
                    self.hasPicturesLbl.text = "No"
                } else {
                    self.hasPicturesLbl.text = "Yes \(media.count)"
                }
            } else {
                self.hasPicturesLbl.text = "No"
            }
        }
        
        self.lastSyncLbl.text = person.lastSync!.description
    }
    
    @IBAction func backButtonAction(sender: AnyObject) {
        if listener != nil {
            listener!.onPersonDetailsClose()
        } else {
            self.view.removeFromSuperview()
        }
    }
    
    @IBAction func refreshAction(sender: AnyObject) {
        // TODO add a spinner
        spinner.hidden = false
        syncButton.hidden = true
        
        SyncQ.getInstance().syncPerson(self.person!, onCompletion: {updatedPerson, err in
            dispatch_async(dispatch_get_main_queue(), {
                //-- update person's lastsync date
                if updatedPerson != nil {
                    updatedPerson!.lastSync = NSDate()
                    do {
                        try DataService.getInstance().dbHelper.persistLittlePerson(updatedPerson!)
                    } catch {
                        print("Unable to persist person \(updatedPerson!.id!)")
                    }
                    self.showPerson(updatedPerson!)
                }
                self.spinner.hidden = true
                self.syncButton.hidden = false
            })
        })
    }
   
    @IBAction func websiteAction(sender: AnyObject) {
        let remoteService = DataService.getInstance().remoteService
        UIApplication.sharedApplication().openURL(NSURL(string: remoteService!.getPersonUrl(person!.familySearchId!) as String )!)
    }
    
    @IBAction func visibleSwitchAction(sender: UISwitch) {
        self.person?.active = visibleSwitch.on
        do {
            try DataService.getInstance().dbHelper.persistLittlePerson(self.person!)
        } catch {
            print("Unable to persist person \(self.person!.id!)")
        }
    }
}

protocol PersonDetailsCloseListener {
    func onPersonDetailsClose()
}
