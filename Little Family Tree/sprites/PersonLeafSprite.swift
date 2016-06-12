//
//  PersonLeafSprite.swift
//  Little Family Tree
//
//  Created by Melissa on 6/11/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class PersonLeafSprite: SKSpriteNode {
    var person:LittlePerson? {
        didSet {
            if photoSprite != nil {
                photoSprite?.removeFromParent()
            }
            let photo = TextureHelper.getPortraitTexture(self.person!)
            photoSprite = SKSpriteNode(texture: photo)
            photoSprite?.position = CGPointMake(0, 0)
            let ratio = (photo?.size().width)! / (photo?.size().height)!
            photoSprite?.size.width = self.size.width * 0.5
            photoSprite?.size.height = (self.size.width * 0.5) / ratio
            photoSprite?.zPosition = 1
            self.addChild(photoSprite!)
        }
    }
    var photoSprite:SKSpriteNode? = nil
}