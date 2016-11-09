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
        if (person.age != nil) {
            if (person.age < 2) {
                return SKTexture(imageNamed: "baby")
            }
            if (person.age < 18) {
                if (person.gender == GenderType.female) {
                    return SKTexture(imageNamed: "girl")
                }
                return SKTexture(imageNamed: "boy")
            }
            if (person.age < 50) {
                if (person.gender == GenderType.female) {
                    return SKTexture(imageNamed: "mom")
                }
                return SKTexture(imageNamed: "dad")
            }
            if (person.gender == GenderType.female) {
                return SKTexture(imageNamed: "grandma")
            }
            return SKTexture(imageNamed: "grandpa")
        } else {
            if (person.gender == GenderType.female) {
                return SKTexture(imageNamed: "mom")
            }
            return SKTexture(imageNamed: "dad")
        }
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
        if (person.age != nil) {
            if (person.age < 2) {
                return UIImage(named: "baby")
            }
            if (person.age < 18) {
                if (person.gender == GenderType.female) {
                    return UIImage(named: "girl")
                }
                return UIImage(named: "boy")
            }
            if (person.age < 50) {
                if (person.gender == GenderType.female) {
                    return UIImage(named: "mom")
                }
                return UIImage(named: "dad")
            }
            if (person.gender == GenderType.female) {
                return UIImage(named: "grandma")
            }
            return UIImage(named: "grandpa")
        } else {
            if (person.gender == GenderType.female) {
                return UIImage(named: "mom")
            }
            return UIImage(named: "dad")
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
