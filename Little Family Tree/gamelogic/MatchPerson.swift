//
//  MatchPerson.swift
//  Little Family Tree
//
//  Created by Melissa on 11/25/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation

class MatchPerson {
    var matched = false
    var flipped = false
    var person:LittlePerson
    var frame:Int
    
    init(person:LittlePerson, frame:Int) {
        self.person = person
        self.frame = frame
    }
}