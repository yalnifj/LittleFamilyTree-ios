//
//  TopBar.swift
//  Little Family Tree
//
//  Created by Melissa on 11/25/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class TopBar: SKSpriteNode {
    var photoSprite:SKSpriteNode?
    var homeSprite:SKSpriteNode?
    
    var person:LittlePerson? {
        didSet {
            let photo = TextureHelper.getPortraitTexture(self.person!)
            photoSprite = SKSpriteNode(texture: photo)
            let ratio = (photo?.size().width)! / (photo?.size().height)!
            photoSprite?.size.height = self.size.height - 5
            photoSprite?.size.width = (self.size.height - 5) * ratio
            photoSprite?.position = CGPointMake(-self.size.width/2, 0)
            photoSprite?.zPosition = 1
            self.addChild(photoSprite!)
        }
    }
    
    var homeTexture:SKTexture? {
        didSet {
            homeSprite = SKSpriteNode(texture: homeTexture)
            let ratio = (homeTexture?.size().width)! / (homeTexture?.size().height)!
            homeSprite?.size.height = self.size.height - 5
            homeSprite?.size.width = (self.size.height - 5) * ratio
            homeSprite?.position = CGPointMake(self.size.width/2 - (2 + self.size.height), 0)
            homeSprite?.zPosition = 1
            self.addChild(homeSprite!)

        }
    }
    
}