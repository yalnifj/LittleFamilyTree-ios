//
//  PersonBubbleSprite.swift
//  Little Family Tree
//
//  Created by Melissa on 12/30/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class PersonBubbleSprite: SKSpriteNode {
    var person:LittlePerson? {
        didSet {
            bubble = SKSpriteNode(imageNamed: "bubble")
            bubble?.size = self.size
            bubble?.position = CGPointMake(self.size.width/2, self.size.height/2)
            bubble?.zPosition = 1
            self.addChild(bubble!)
            
            let photo = TextureHelper.getPortraitTexture(person!)
            personSprite = SKSpriteNode(texture: photo)
            let w = self.size.width * 0.6
            let r = (photo?.size().height)! / (photo?.size().width)!
            let h = w * r
            personSprite?.size = CGSizeMake(w, h)
            personSprite?.zPosition = 2
            self.addChild(personSprite!)
        }
    }
    
    var bubble:SKSpriteNode?
    var personSprite:SKSpriteNode?
}