//
//  CupcakeSprite.swift
//  Little Family Tree
//
//  Created by Melissa on 11/14/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class CupcakeSprite: SKSpriteNode {
    var person:LittlePerson? {
        didSet {
            if photoSprite != nil {
                photoSprite?.removeFromParent()
            }
            let photo = TextureHelper.getPortraitTexture(self.person!)
            photoSprite = SKSpriteNode(texture: photo)
            photoSprite?.position = CGPointMake(0, 0)
            let ratio = (photo?.size().width)! / (photo?.size().height)!
            photoSprite?.size.width = self.size.width / 2.0
            photoSprite?.size.height = (self.size.width / 2.0) / ratio
            photoSprite?.zPosition = 2
            self.addChild(photoSprite!)
            
            let num = 1 + arc4random_uniform(UInt32(3))
            flame = SKSpriteNode(imageNamed: "flame\(num).png")
            flame?.position = CGPointMake(0, self.size.height/1.8)
            let fr = flame!.size.width / flame!.size.height
            flame?.size = CGSizeMake(self.size.width / 6, (self.size.width / 6) / fr)
            flame?.zPosition = 1
            var textures = [SKTexture(imageNamed: "flame2.png"), SKTexture(imageNamed: "flame3.png"), SKTexture(imageNamed: "flame2.png"), SKTexture(imageNamed: "flame1.png")]
            for _ in 0..<num {
                textures.append(textures.removeFirst())
            }
            let action = SKAction.animateWithTextures(textures, timePerFrame: 0.15)
            flame?.runAction(SKAction.repeatActionForever(action))
            self.addChild(flame!)
            
            addLabels()
        }
    }
    var flame:SKSpriteNode? = nil
    var photoSprite:SKSpriteNode? = nil
    var nameLabel:SKLabelNode? = nil
	var birthDateLabel:SKLabelNode? = nil
	var ageLabel:SKLabelNode? = nil
    var topic:String?
    
    func addLabels() {
        if nameLabel != nil {
            nameLabel?.removeFromParent()
        }
        var name = person!.name as! String
        let parts = name.split(" ")
        if parts.count > 3 {
            name = "\(parts[0])"
            for n in parts.count - 2 ..< parts.count {
                name = name + " \(parts[n])"
            }
        }
        nameLabel = SKLabelNode(text: name)
        nameLabel?.fontSize = self.size.width / 10
        nameLabel?.fontColor = UIColor.blackColor()
        nameLabel?.position = CGPointMake(0, nameLabel!.fontSize * -4)
        if nameLabel?.frame.width > self.size.width * 1.1 {
            nameLabel?.fontSize = nameLabel!.fontSize * 0.75
        }
        nameLabel?.zPosition = 3
        self.addChild(nameLabel!)
		
		if birthDateLabel != nil {
            birthDateLabel?.removeFromParent()
        }
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        let dateString = formatter.stringFromDate(person!.birthDate!)

        birthDateLabel = SKLabelNode(text: dateString)
        birthDateLabel?.fontSize = nameLabel!.fontSize
        birthDateLabel?.fontColor = UIColor.blackColor()
        birthDateLabel?.position = CGPointMake(0, nameLabel!.position.y - birthDateLabel!.fontSize)
        birthDateLabel?.zPosition = 3
        self.addChild(birthDateLabel!)
		
		if ageLabel != nil {
            ageLabel?.removeFromParent()
        }
        
        let ageComponents = NSCalendar.currentCalendar().components([.Month, .Day],
                                                                     fromDate: person!.birthDate!)
        let month = ageComponents.month
        let day = ageComponents.day
        
        let ageComponentsNow = NSCalendar.currentCalendar().components([.Month, .Day],
                                                                    fromDate: NSDate())
        var age = person!.age!
        let monthN = ageComponentsNow.month
        let dayN = ageComponentsNow.day
        if month > monthN || (month==monthN && day > dayN) {
            age += 1
        }
        
        ageLabel = SKLabelNode(text: "Age \(age)")
        ageLabel?.fontSize = nameLabel!.fontSize
        ageLabel?.fontColor = UIColor.blackColor()
        ageLabel?.position = CGPointMake(0, birthDateLabel!.position.y - ageLabel!.fontSize)
        ageLabel?.zPosition = 3
        self.addChild(ageLabel!)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        if topic != nil {
            EventHandler.getInstance().publish(topic!, data: person)
        }
    }

}