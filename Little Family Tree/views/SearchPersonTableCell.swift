//
//  SearchPersonTableCell.swift
//  Little Family Tree
//
//  Created by Melissa on 3/15/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import Foundation
import UIKit

class SearchPersonTableCell: UITableViewCell {
 
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var genderLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var birthDateLbl: UILabel!
    @IBOutlet weak var remoteIdLbl: UILabel!
    @IBOutlet weak var birthPlaceLbl: UILabel!
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setValues(person:LittlePerson) {
        if person.gender == GenderType.MALE {
            genderLbl.text = "M"
        } else if person.gender == GenderType.FEMALE {
            genderLbl.text = "F"
        } else {
            genderLbl.text = "U"
        }
        
        nameLbl.text = person.name as String?
        remoteIdLbl.text = person.familySearchId as String?
        birthPlaceLbl.text = person.birthPlace as String?
        if person.birthDate != nil {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            let dateString = formatter.stringFromDate(person.birthDate!)
            birthDateLbl.text = dateString
        } else {
            birthDateLbl.text = "Unknown"
        }
        let portrait = TextureHelper.getPortraitImage(person)
        profileImg.image = portrait
    }
}