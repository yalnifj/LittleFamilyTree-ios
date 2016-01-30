//
//  DressUpDolls.swift
//  Little Family Tree
//
//  Created by Melissa on 12/5/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation

class DressUpDolls {
    var countryMappings:[String:String]
    
    init() {
        countryMappings = [String:String]()
        countryMappings["united states"] = "usa"
        countryMappings["unknown"] = "usa"
        countryMappings["ireland"] = "ireland"
        countryMappings["native american"] = "nativeamerican"
        countryMappings["germany"] = "germany"
        countryMappings["denmark"] = "denmark"
        countryMappings["england"] = "england"
        countryMappings["france"] = "france"
        countryMappings["wales"] = "wales"
        countryMappings["scotland"] = "scotland"
        countryMappings["mexico"] = "mexico"
        countryMappings["sweden"] = "sweden"
        countryMappings["netherlands"] = "netherlands"
        countryMappings["russia"] = "russia"
        countryMappings["spain"] = "spain"
    }
    
    func getDollConfig(place:String?, person:LittlePerson) -> DollConfig {
        var folder:String? = nil
        if (place != nil) {
            folder = countryMappings[place!.lowercaseString]
        }
        if (folder == nil) {
            folder = countryMappings["unknown"]
        }
        
        let dc = DollConfig();
        dc.folderName = folder
        if (person.gender == GenderType.FEMALE) {
            dc.boygirl = "girl"
        } else {
            dc.boygirl = "boy"
        }
        dc.originalPlace = place;
        return dc;
    }
    
    func getDollPlaces() -> [String] {
        var places = [String]()
        for place in countryMappings.keys {
            if place != "unknown" {
                places.append(place)
            }
        }
        return places;
    }
}
