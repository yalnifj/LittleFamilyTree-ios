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
            bubble?.position = CGPointMake(0, 0)
            bubble?.zPosition = 1
            self.addChild(bubble!)
            
            let photo = TextureHelper.getPortraitTexture(person!)
            personSprite = SKSpriteNode(texture: photo)
            let w = self.size.width * 0.6
            let r = (photo?.size().height)! / (photo?.size().width)!
            let h = w * r
            personSprite?.size = CGSizeMake(w, h)
            personSprite?.position = CGPointMake(0, 0)
            personSprite?.zPosition = 2
            self.addChild(personSprite!)
        }
    }
    
    var bubble:SKSpriteNode?
    var personSprite:SKSpriteNode?
    var popped = false
	
	func highlight() {
		let highlight = SKSpriteNode(imageNamed: "bubbled_hi")
		highlight.size = self.size
		highlight.position = CGPointMake(0, 0)
		highlight.zPosition = 3
		self.addChild(highlight)
		let action = SKAction.sequence([
			SKAction.repeatAction(SKAction.rotateByAngle(6, duration: 1), count: 3),
			SKAction.removeFromParent()
		])
		highlight.runAction(action)
	}
}