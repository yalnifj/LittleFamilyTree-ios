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
            
            flame = SKSpriteNode(imageNamed: "flame1.png")
            flame?.position = CGPointMake(0, self.size.height/1.8)
            let fr = flame!.size.width / flame!.size.height
            flame?.size = CGSizeMake(self.size.width / 6, (self.size.width / 6) / fr)
            flame?.zPosition = 1
            let action = SKAction.animateWithTextures([SKTexture(imageNamed: "flame2.png"), SKTexture(imageNamed: "flame3.png"), SKTexture(imageNamed: "flame2.png"), SKTexture(imageNamed: "flame1.png")], timePerFrame: 0.15)
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
        nameLabel = SKLabelNode(text: person?.name as String?)
        nameLabel?.fontSize = self.size.width / 10
        nameLabel?.fontColor = UIColor.blackColor()
        nameLabel?.position = CGPointMake(0, nameLabel!.fontSize * -4)
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
        birthDateLabel?.position = CGPointMake(0, birthDateLabel!.fontSize * -5)
        birthDateLabel?.zPosition = 2
        self.addChild(birthDateLabel!)
		
		if ageLabel != nil {
            ageLabel?.removeFromParent()
        }
        ageLabel = SKLabelNode(text: "Age \(person!.age!)")
        ageLabel?.fontSize = nameLabel!.fontSize
        ageLabel?.fontColor = UIColor.blackColor()
        ageLabel?.position = CGPointMake(0, ageLabel!.fontSize * -6)
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