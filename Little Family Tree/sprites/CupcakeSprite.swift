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
            photoSprite?.size.width = self.size.width / 2.5
            photoSprite?.size.height = (self.size.width / 2.5) / ratio
            photoSprite?.zPosition = 1
            self.addChild(photoSprite!)
            
            addLabels()
        }
    }
    var photoSprite:SKSpriteNode? = nil
    var nameLabel:SKLabelNode? = nil
	var birthDateLabel:SKLabelNode? = nil
	var ageLabel:SKLabelNode? = nil
    var topic:String?
    
    func addLabels() {
        if nameLabel != nil {
            nameLabel?.removeFromParent()
        }
        nameLabel = SKLabelNode(text: person?.name as String?)
        nameLabel?.fontSize = self.size.width / 10
        nameLabel?.fontColor = UIColor.blackColor()
        nameLabel?.position = CGPointMake(0, nameLabel!.fontSize * -3)
        nameLabel?.zPosition = 2
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
        birthDateLabel?.position = CGPointMake(0, birthDateLabel!.fontSize * -4)
        birthDateLabel?.zPosition = 2
        self.addChild(birthDateLabel!)
		
		if ageLabel != nil {
            ageLabel?.removeFromParent()
        }
        ageLabel = SKLabelNode(text: "Age \(person!.age)")
        ageLabel?.fontSize = nameLabel!.fontSize
        ageLabel?.fontColor = UIColor.blackColor()
        ageLabel?.position = CGPointMake(0, ageLabel!.fontSize * -5)
        ageLabel?.zPosition = 2
        self.addChild(ageLabel!)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        if topic != nil {
            EventHandler.getInstance().publish(topic!, data: person)
        }
    }

}