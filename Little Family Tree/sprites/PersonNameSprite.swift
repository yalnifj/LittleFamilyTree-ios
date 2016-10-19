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
            photoSprite?.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
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
    var fullName = false {
        didSet {
            if nameLabel != nil && person != nil {
                if fullName {
                    nameLabel!.text = person!.name as String?
                } else {
                    nameLabel!.text = person!.givenName as String?
                }
            }
        }
    }
    
    func addLabel() {
        if nameLabel != nil {
            nameLabel?.removeFromParent()
        }
        if fullName {
            nameLabel = SKLabelNode(text: person?.name as String?)
        } else {
            nameLabel = SKLabelNode(text: person?.givenName as String?)
        }
        nameLabel?.fontSize = self.size.width / 10
        nameLabel?.fontColor = UIColor.black
        nameLabel?.position = CGPoint(x: self.size.width/2, y: (nameLabel?.fontSize)! / 2)
        nameLabel?.zPosition = 2
        self.addChild(nameLabel!)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if topic != nil {
            EventHandler.getInstance().publish(topic!, data: person)
        }
    }

}
