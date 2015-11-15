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
        get { return self.person }
        set {
            let photo = TextureHelper.getPortraitTexture(self.person!)
            photoSprite = SKSpriteNode(texture: photo)
            photoSprite?.position = CGPointMake(self.size.width/2, self.size.height/2)
            self.addChild(photoSprite!)
            
            nameLabel = SKLabelNode(text: person?.givenName as String?)
            nameLabel?.fontSize = 10
            nameLabel?.position = CGPointMake(self.size.width/2, 0)
            self.addChild(nameLabel!)
        }
    }
    var photoSprite:SKSpriteNode?
    var nameLabel:SKLabelNode?

}