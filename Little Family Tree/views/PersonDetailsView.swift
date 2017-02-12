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
    var openingScene:LittleFamilyScene?
    
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
    @IBOutlet weak var recordButton: UIButton!
    
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
        view.autoresizingMask = UIViewAutoresizing.flexibleWidth
        addSubview(view)

    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for:type(of: self))
        let nib = UINib(nibName: "PersonDetailsView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }

    func showPerson(_ person:LittlePerson) {
        self.person = person
        
        let dataService = DataService.getInstance()
        let dbHelper = dataService.dbHelper
        
        let photo = TextureHelper.getPortraitImage(self.person!)
        self.portraitImg.image = photo
        
        self.nameLabel.text = person.name as String?
        self.remoteIdLbl.text = person.familySearchId as String?
        
        self.visibleSwitch.isOn = person.active
        if person.gender == GenderType.female {
            self.genderLbl.text = "Female"
        } else if person.gender == GenderType.male {
            self.genderLbl.text = "Male"
        } else {
            self.genderLbl.text = "Unknown"
        }
        
        let relationship = RelationshipCalculator.getRelationship(selectedPerson, p: person)
        self.relationshipLbl.text = relationship
        
        if person.birthDate != nil {
            let components = (Calendar.current as NSCalendar).components(.year, from: person.birthDate!)
            if components.year != nil {
                self.birthYearLbl.text = "\(components.year!)"
            }
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
    
    @IBAction func backButtonAction(_ sender: AnyObject) {
        self.view.removeFromSuperview()
        if listener != nil {
            listener!.onPersonDetailsClose()
        }
    }
    
    @IBAction func refreshAction(_ sender: AnyObject) {
        spinner.isHidden = false
        syncButton.isHidden = true
        
        SyncQ.getInstance().syncPerson(self.person!, onCompletion: {updatedPerson, err in
            DispatchQueue.main.async(execute: {
                //-- update person's lastsync date
                if updatedPerson != nil {
                    updatedPerson!.lastSync = Foundation.Date()
                    do {
                        try DataService.getInstance().dbHelper.persistLittlePerson(updatedPerson!)
                    } catch {
                        print("Unable to persist person \(updatedPerson!.id!)")
                    }
                    self.showPerson(updatedPerson!)
                } else {
                    //show error message
                    let x = Int((self.frame.width - 300) / 2)
                    let y = 50
                    let rect = CGRect(x: x, y: y, width: 300, height: 300)
                    let subview = SimpleDialogView(frame: rect)
                    subview.setMessage("Error synchronizing person", message: err!.description)
                    self.view?.addSubview(subview)
                }
                self.spinner.isHidden = true
                self.syncButton.isHidden = false
            })
        })
    }
   
    @IBAction func websiteAction(_ sender: AnyObject) {
        let remoteService = DataService.getInstance().remoteService
        UIApplication.shared.openURL(URL(string: remoteService!.getPersonUrl(person!.familySearchId!) as String )!)
    }
    
    @IBAction func visibleSwitchAction(_ sender: UISwitch) {
        self.person?.active = visibleSwitch.isOn
        do {
            try DataService.getInstance().dbHelper.persistLittlePerson(self.person!)
        } catch {
            print("Unable to persist person \(self.person!.id!)")
        }
    }
    
    @IBAction func recordButtonClicked(_ sender: AnyObject) {
        self.view?.removeFromSuperview()
        
        openingScene?.showRecordAudioDialog(person!, listener: listener!)
    }
}

protocol PersonDetailsCloseListener {
    func onPersonDetailsClose()
}
