//
//  SongPersonAttributes.swift
//  Little Family Tree
//
//  Created by Melissa on 2/25/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import Foundation

protocol SongPersonAttribute {
    func getAttributeFromPerson(person:LittlePerson, number:Int) -> String?
}

class SongNameAttributor : SongPersonAttribute {
    func getAttributeFromPerson(person:LittlePerson, number:Int) -> String? {
        return person.givenName as String?
    }
}

class SongDatePlaceAttributor : SongPersonAttribute {
    func getAttributeFromPerson(person:LittlePerson, number:Int) -> String? {
        if (number % 2 == 0) {
            //-- date
            if (person.birthDate != nil) {
                let formatter = NSDateFormatter()
                formatter.dateFormat = "yyyy"
                let dateString = formatter.stringFromDate(person.birthDate!)
                return dateString
            } else {
                return "some time";
            }
        } else {
            //--place
            if (person.birthPlace != nil) {
                let country = PlaceHelper.getPlaceCountry(person.birthPlace as String?)
                if (country == "United States") {
                    let state = PlaceHelper.getTopPlace(person.birthPlace as String?, level: 2);
                    if (state != nil && PlaceHelper.isInUS(state!)) {
                        return state
                    }
                }
                return country
            } else {
                return "Earth"
            }
        }

    }
}