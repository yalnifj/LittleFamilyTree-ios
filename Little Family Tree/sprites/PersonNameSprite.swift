//
//  PersonNameSprite.swift
//  Little Family Tree
//
//  Created by Melissa on 11/14/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class PersonNameSprite: SKSpriteNode {
    var person:LittlePerson? {
        didSet {
            if photoSprite != nil {
                photoSprite?.removeFromParent()
            }
            let photo = TextureHelper.getPortraitTexture(self.person!)
            photoSprite = SKSpriteNode(texture: photo)
            photoSprite?.position = CGPointMake(self.size.width/2, self.size.height/2)
            let ratio = (photo?.size().width)! / (photo?.size().height)!
            photoSprite?.size.width = self.size.width * 0.6
            photoSprite?.size.height = (self.size.width * 0.6) / ratio
            photoSprite?.zPosition = 1
            self.addChild(photoSprite!)
            
            
            if showLabel {
                addLabel()
            }
        }
    }
    var photoSprite:SKSpriteNode? = nil
    var nameLabel:SKLabelNode? = nil
    var showLabel = true {
        didSet {
            if !showLabel && nameLabel != nil {
                nameLabel?.removeFromParent()
            }
            if showLabel {
                addLabel()
            }
        }
    }
    var topic:String?
    
    func addLabel() {
        if nameLabel != nil {
            nameLabel?.removeFromParent()
        }
        nameLabel = SKLabelNode(text: person?.givenName as String?)
        nameLabel?.fontSize = self.size.width / 10
        nameLabel?.fontColor = UIColor.blackColor()
        nameLabel?.position = CGPointMake(self.size.width/2, (nameLabel?.fontSize)! / 2)
        nameLabel?.zPosition = 2
        self.addChild(nameLabel!)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        if topic != nil {
            EventHandler.getInstance().publish(topic!, data: person)
        }
    }

}