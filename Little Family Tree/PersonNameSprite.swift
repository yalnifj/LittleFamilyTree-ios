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
            let photo = TextureHelper.getPortraitTexture(self.person!)
            photoSprite = SKSpriteNode(texture: photo)
            photoSprite?.position = CGPointMake(self.size.width/2, self.size.height/2)
            let ratio = (photo?.size().width)! / (photo?.size().height)!
            photoSprite?.size.width = self.size.width * 0.6
            photoSprite?.size.height = (self.size.width * 0.6) / ratio
            
            self.addChild(photoSprite!)
            
            nameLabel = SKLabelNode(text: person?.givenName as String?)
            nameLabel?.fontSize = 24
            nameLabel?.fontColor = UIColor.blackColor()
            nameLabel?.position = CGPointMake(self.size.width/2, 12)
            self.addChild(nameLabel!)
        }
    }
    var photoSprite:SKSpriteNode?
    var nameLabel:SKLabelNode?

}