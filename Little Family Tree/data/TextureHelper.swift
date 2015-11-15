//
//  TextureHelper.swift
//  Little Family Tree
//
//  Created by Melissa on 11/14/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation

import SpriteKit

class TextureHelper {
    
    static func getPortraitTexture(person:LittlePerson) -> SKTexture? {
        let fileManager = NSFileManager.defaultManager()
        if person.photoPath != nil && person.photoPath!.length == 0 && !fileManager.fileExistsAtPath(person.photoPath as! String) {
            return getDefaultPortrait(person)
        }
        
        let data = NSData(contentsOfFile: person.photoPath! as String)
        let uiImage = UIImage(data: data!)
        if uiImage != nil {
            let texture = SKTexture(image: uiImage!)
            return texture
        }
        return getDefaultPortrait(person)
    }
    
    static func getDefaultPortrait(person:LittlePerson) -> SKTexture {
        if (person.age != nil) {
            if (person.age < 2) {
                return SKTexture(imageNamed: "baby")
            }
            if (person.age < 18) {
                if (person.gender == GenderType.FEMALE) {
                    return SKTexture(imageNamed: "girl")
                }
                return SKTexture(imageNamed: "boy")
            }
            if (person.age < 50) {
                if (person.gender == GenderType.FEMALE) {
                    return SKTexture(imageNamed: "mom")
                }
                return SKTexture(imageNamed: "dad")
            }
            if (person.gender == GenderType.FEMALE) {
                return SKTexture(imageNamed: "grandma")
            }
            return SKTexture(imageNamed: "grandpa")
        } else {
            if (person.gender == GenderType.FEMALE) {
                return SKTexture(imageNamed: "mom")
            }
            return SKTexture(imageNamed: "dad")
        }
    }
}