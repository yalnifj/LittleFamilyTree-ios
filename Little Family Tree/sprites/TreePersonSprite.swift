//
//  TreePersonSprite.swift
//  Little Family Tree
//
//  Created by Melissa on 11/25/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class TreePersonSprite: SKSpriteNode {
	var person:LittlePerson? {
		didSet: {
			var leafTexture:SKTexture?
			if left {
				leafTexture = SKTexture(imageNamed: "left_leaf")
			} else {
				leafTexture = SKTexture(imageNamed: "right_leaf")
			}
			
			let leaf = SKSpriteNode(texture: leafTexture!)
			leaf.size = self.size
			leaf.position = CGPointMake(self.size.width / 2, self.size.height / 2)
			leaf.zPosition = 1
			self.addChild(leaf)
			
			if person != nil {
				let photo = TextureHelper.getPortraitTexture(person)
				let photoSprite = SKSpriteNode(texture: photo)
				photoSprite.position = CGPointMake(self.size.width/2, self.size.height/2)
				let ratio = (photo?.size().width)! / (photo?.size().height)!
				photoSprite.size.width = self.size.width * 0.75
				photoSprite.size.height = (self.size.width * 0.75) / ratio
				photoSprite.zPosition = 2
				self.addChild(photoSprite)
			}
		}
	}
	var left:Bool = false
}