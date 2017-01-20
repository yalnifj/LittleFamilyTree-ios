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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class TextureHelper {
    
    static func getPortraitTexture(_ person:LittlePerson) -> SKTexture? {
        let fileManager = FileManager.default
        let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        if person.photoPath == nil || person.photoPath!.isEmpty {
            if person.name != nil {
                print("no portrait found for \(person.name!)")
            }
            return getDefaultPortrait(person)
        }
        let photoUrl = url.appendingPathComponent(person.photoPath!)
        if !fileManager.fileExists(atPath: photoUrl.path) {
            if person.name != nil {
                print("no portrait found for \(person.name!)")
            }
            return getDefaultPortrait(person)
        }
        
        let data = try? Data(contentsOf: photoUrl)
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
    
    static func getDefaultPortrait(_ person:LittlePerson) -> SKTexture {
        var skinTone = DataService.getInstance().dbHelper.getProperty(DataService.PROPERTY_SKIN_TONE)
        if skinTone == nil {
            skinTone = "light"
        }
        return TextureHelper.getDefaultPortraitTexture(person, skinTone:skinTone!)
    }
    
    static func getDefaultPortraitTexture(_ person:LittlePerson, skinTone:String) -> SKTexture {
        if (person.age != nil) {
            if (person.age < 2) {
                if skinTone == "light" {
                    return SKTexture(imageNamed: "baby")
                }
                if skinTone == "mid" {
                    return SKTexture(imageNamed: "baby_mid")
                }
                if skinTone == "dark" {
                    return SKTexture(imageNamed: "baby_dark")
                }
            }
            if (person.age < 18) {
                if (person.gender == GenderType.female) {
                    if skinTone == "light" {
                        return SKTexture(imageNamed: "girl")
                    }
                    if skinTone == "mid" {
                        return SKTexture(imageNamed: "girl_mid")
                    }
                    if skinTone == "dark" {
                        return SKTexture(imageNamed: "girl_dark")
                    }
                }
                if skinTone == "light" {
                    return SKTexture(imageNamed: "boy")
                }
                if skinTone == "mid" {
                    return SKTexture(imageNamed: "boy_mid")
                }
                if skinTone == "dark" {
                    return SKTexture(imageNamed: "boy_dark")
                }
            }
            if (person.age < 50) {
                if (person.gender == GenderType.female) {
                    if skinTone == "light" {
                        return SKTexture(imageNamed: "mom")
                    }
                    if skinTone == "mid" {
                        return SKTexture(imageNamed: "mom_mid")
                    }
                    if skinTone == "dark" {
                        return SKTexture(imageNamed: "mom_dark")
                    }
                }
                if skinTone == "light" {
                    return SKTexture(imageNamed: "dad")
                }
                if skinTone == "mid" {
                    return SKTexture(imageNamed: "dad_mid")
                }
                if skinTone == "dark" {
                    return SKTexture(imageNamed: "dad_dark")
                }
            }
            if (person.gender == GenderType.female) {
                if skinTone == "light" {
                    return SKTexture(imageNamed: "grandma")
                }
                if skinTone == "mid" {
                    return SKTexture(imageNamed: "grandma_mid")
                }
                if skinTone == "dark" {
                    return SKTexture(imageNamed: "grandma_dark")
                }
            }
            if skinTone == "light" {
                return SKTexture(imageNamed: "grandpa")
            }
            if skinTone == "mid" {
                return SKTexture(imageNamed: "grandpa_mid")
            }
            if skinTone == "dark" {
                return SKTexture(imageNamed: "grandpa_dark")
            }
        } else {
            if (person.gender == GenderType.female) {
                if skinTone == "light" {
                    return SKTexture(imageNamed: "mom")
                }
                if skinTone == "mid" {
                    return SKTexture(imageNamed: "mom_mid")
                }
                if skinTone == "dark" {
                    return SKTexture(imageNamed: "mom_dark")
                }
            }
            if skinTone == "light" {
                return SKTexture(imageNamed: "dad")
            }
            if skinTone == "mid" {
                return SKTexture(imageNamed: "dad_mid")
            }
            if skinTone == "dark" {
                return SKTexture(imageNamed: "dad_dark")
            }
        }
        return SKTexture(imageNamed: "dad")
    }
    
    static func getPortraitImage(_ person:LittlePerson) -> UIImage? {
        let fileManager = FileManager.default
        let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        if person.photoPath == nil || person.photoPath!.isEmpty {
            if person.name != nil {
                print("no portrait found for \(person.name!)")
            }
            return getDefaultPortraitImage(person)
        }
        let photoUrl = url.appendingPathComponent(person.photoPath!)
        if !fileManager.fileExists(atPath: photoUrl.path) {
            if person.name != nil {
                print("no portrait found for \(person.name!)")
            }
            return getDefaultPortraitImage(person)
        }
        
        let data = try? Data(contentsOf: photoUrl)
        if data != nil {
            let uiImage = UIImage(data: data!)
            if uiImage != nil {
                return uiImage
            }
        }
        print("Unable to load data for \(person.photoPath)")
        return getDefaultPortraitImage(person)
    }
    
    static func getDefaultPortraitImage(_ person:LittlePerson) -> UIImage? {
        var skinTone = DataService.getInstance().dbHelper.getProperty(DataService.PROPERTY_SKIN_TONE)
        if skinTone == nil {
            skinTone = "light"
        }
        return TextureHelper.getDefaultPortraitImageBySkin(person, skinTone:skinTone!)
    }
    
    static func getDefaultPortraitImageBySkin(_ person:LittlePerson, skinTone:String) -> UIImage? {
        if (person.age != nil) {
            if (person.age < 2) {
                if skinTone == "light" {
                    return UIImage(named: "baby")
                }
                return UIImage(named: "baby_\(skinTone)")
            }
            if (person.age < 18) {
                if (person.gender == GenderType.female) {
                    if skinTone == "light" {
                        return UIImage(named: "girl")
                    }
                    return UIImage(named: "girl_\(skinTone)")
                }
                if skinTone == "light" {
                    return UIImage(named: "boy")
                }
                return UIImage(named: "boy_\(skinTone)")
            }
            if (person.age < 50) {
                if (person.gender == GenderType.female) {
                    if skinTone == "light" {
                        return UIImage(named: "mom")
                    }
                    return UIImage(named: "mom_\(skinTone)")
                }
                if skinTone == "light" {
                    return UIImage(named: "dad")
                }
                return UIImage(named: "dad_\(skinTone)")
            }
            if (person.gender == GenderType.female) {
                if skinTone == "light" {
                    return UIImage(named: "grandma")
                }
                return UIImage(named: "grandma_\(skinTone)")
            }
            if skinTone == "light" {
                return UIImage(named: "grandpa")
            }
            return UIImage(named: "grandpa_\(skinTone)")
        } else {
            if (person.gender == GenderType.female) {
                if skinTone == "light" {
                    return UIImage(named: "mom")
                }
                return UIImage(named: "mom_\(skinTone)")
            }
            if skinTone == "light" {
                return UIImage(named: "dad")
            }
            return UIImage(named: "dad_\(skinTone)")
        }
    }
    
    static func getTextureForMedia(_ media:Media, size:CGSize) -> SKTexture? {
        let fileManager = FileManager.default
        let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photoUrl = url.appendingPathComponent(media.localPath!)
        if fileManager.fileExists(atPath: photoUrl.path) {
            print("reading file \(photoUrl)")
            let data = try? Data(contentsOf: photoUrl)
            if data != nil {
                let uiImage = UIImage(data: data!)
                if uiImage != nil {
                    if (uiImage?.size.width > size.width || uiImage?.size.height > size.height) {
                        let options: [NSString: NSObject] = [
                            kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height) as NSObject,
                            kCGImageSourceCreateThumbnailFromImageAlways: true as NSObject
                        ]
                        
                        let imageSource = CGImageSourceCreateWithURL(photoUrl as CFURL, nil)
                        let scaledImage = CGImageSourceCreateThumbnailAtIndex(imageSource!, 0, options as CFDictionary?)
                        let texture = SKTexture(cgImage: scaledImage!)
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
