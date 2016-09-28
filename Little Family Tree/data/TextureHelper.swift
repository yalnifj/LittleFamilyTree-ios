//
//  TextureHelper.swift
//  Little Family Tree
//
//  Created by Melissa on 11/14/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation

import SpriteKit
import ImageIO

class TextureHelper {
    
    static func getPortraitTexture(person:LittlePerson) -> SKTexture? {
        let fileManager = NSFileManager.defaultManager()
        let url = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        
        if person.photoPath === nil || person.photoPath!.length == 0 {
            if person.name != nil {
                print("no portrait found for \(person.name!)")
            }
            return getDefaultPortrait(person)
        }
        let photoUrl = url.URLByAppendingPathComponent(person.photoPath as! String)
        if !fileManager.fileExistsAtPath(photoUrl!.path!) {
            if person.name != nil {
                print("no portrait found for \(person.name!)")
            }
            return getDefaultPortrait(person)
        }
        
        let data = NSData(contentsOfURL: photoUrl!)
        if data != nil {
            let uiImage = UIImage(data: data!)
            if uiImage != nil {
                let texture = SKTexture(image: uiImage!)
                return texture
            }
        }
        print("Unable to load data for \(person.photoPath)")
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
    
    static func getPortraitImage(person:LittlePerson) -> UIImage? {
        let fileManager = NSFileManager.defaultManager()
        let url = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        
        if person.photoPath === nil || person.photoPath!.length == 0 {
            if person.name != nil {
                print("no portrait found for \(person.name!)")
            }
            return getDefaultPortraitImage(person)
        }
        let photoUrl = url.URLByAppendingPathComponent(person.photoPath as! String)
        if !fileManager.fileExistsAtPath(photoUrl!.path!) {
            if person.name != nil {
                print("no portrait found for \(person.name!)")
            }
            return getDefaultPortraitImage(person)
        }
        
        let data = NSData(contentsOfURL: photoUrl!)
        if data != nil {
            let uiImage = UIImage(data: data!)
            if uiImage != nil {
                return uiImage
            }
        }
        print("Unable to load data for \(person.photoPath)")
        return getDefaultPortraitImage(person)
    }
    
    static func getDefaultPortraitImage(person:LittlePerson) -> UIImage? {
        if (person.age != nil) {
            if (person.age < 2) {
                return UIImage(named: "baby")
            }
            if (person.age < 18) {
                if (person.gender == GenderType.FEMALE) {
                    return UIImage(named: "girl")
                }
                return UIImage(named: "boy")
            }
            if (person.age < 50) {
                if (person.gender == GenderType.FEMALE) {
                    return UIImage(named: "mom")
                }
                return UIImage(named: "dad")
            }
            if (person.gender == GenderType.FEMALE) {
                return UIImage(named: "grandma")
            }
            return UIImage(named: "grandpa")
        } else {
            if (person.gender == GenderType.FEMALE) {
                return UIImage(named: "mom")
            }
            return UIImage(named: "dad")
        }
    }
    
    static func getTextureForMedia(media:Media, size:CGSize) -> SKTexture? {
        let fileManager = NSFileManager.defaultManager()
        let url = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let photoUrl = url.URLByAppendingPathComponent(media.localPath as! String)
        if fileManager.fileExistsAtPath(photoUrl!.path!) {
            print("reading file \(photoUrl)")
            let data = NSData(contentsOfURL: photoUrl!)
            if data != nil {
                let uiImage = UIImage(data: data!)
                if uiImage != nil {
                    if (uiImage?.size.width > size.width || uiImage?.size.height > size.height) {
                        let options: [NSString: NSObject] = [
                            kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height),
                            kCGImageSourceCreateThumbnailFromImageAlways: true
                        ]
                        
                        let imageSource = CGImageSourceCreateWithURL(photoUrl!, nil)
                        let scaledImage = CGImageSourceCreateThumbnailAtIndex(imageSource!, 0, options)
                        let texture = SKTexture(CGImage: scaledImage!)
                        return texture
                    }
                    else {
                        let texture = SKTexture(image: uiImage!)
                        return texture
                    }
                }
            }
            print("Unable to load texture for \(media.localPath!)")
        } else {
            print("File does not exist at \(media.localPath!)")
        }
        return nil
    }
}
