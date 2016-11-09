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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setValues(_ person:LittlePerson) {
        if person.gender == GenderType.male {
            genderLbl.text = "M"
        } else if person.gender == GenderType.female {
            genderLbl.text = "F"
        } else {
            genderLbl.text = "U"
        }
        
        nameLbl.text = person.name as String?
        remoteIdLbl.text = person.familySearchId as String?
        birthPlaceLbl.text = person.birthPlace as String?
        if person.birthDate != nil {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            let dateString = formatter.string(from: person.birthDate!)
            birthDateLbl.text = dateString
        } else {
            birthDateLbl.text = "Unknown"
        }
        let portrait = TextureHelper.getPortraitImage(person)
        profileImg.image = portrait
    }
}
