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
		didSet {
			var leafTexture:SKTexture?
			if left {
				leafTexture = SKTexture(imageNamed: "leaf_left")
			} else {
				leafTexture = SKTexture(imageNamed: "leaf_right")
			}
			
			let leaf = SKSpriteNode(texture: leafTexture!)
			leaf.size = self.size
			leaf.position = CGPointMake(self.size.width / 2, self.size.height / 2)
			leaf.zPosition = 1
			self.addChild(leaf)
			
			if person != nil {
				let photo = TextureHelper.getPortraitTexture(person!)
				let photoSprite = SKSpriteNode(texture: photo)
				photoSprite.position = CGPointMake(self.size.width/2, self.size.height/2)
				let ratio = (photo?.size().width)! / (photo?.size().height)!
				photoSprite.size.width = self.size.width * 0.58
				photoSprite.size.height = (self.size.width * 0.58) / ratio
				photoSprite.zPosition = 2
				self.addChild(photoSprite)
				
				let nameLabel = SKLabelNode(text: person?.givenName as String?)
				nameLabel.fontSize = self.size.width / 6
				nameLabel.fontColor = UIColor.whiteColor()
				nameLabel.position = CGPointMake(self.size.width/2, nameLabel.fontSize / -2)
				nameLabel.zPosition = 3
				self.addChild(nameLabel)
			}
		}
	}
	var left:Bool = false
}

class TreeCoupleSprite : SKSpriteNode {
    var lSprite:TreePersonSprite?
    var rSprite:TreePersonSprite?
    
    var treeNode:TreeNode? {
        didSet {
            lSprite = TreePersonSprite()
            lSprite?.left = true
            lSprite?.position = CGPointZero
            lSprite?.size.width = self.size.width / 2
            lSprite?.size.height = self.size.height
            lSprite?.person = treeNode?.leftPerson
            self.addChild(lSprite!)
            
            rSprite = TreePersonSprite()
            rSprite?.left = false
            rSprite?.position = CGPointMake(self.size.width / 2, 0)
            rSprite?.size.width = self.size.width / 2
            rSprite?.size.height = self.size.height
            rSprite?.person = treeNode?.rightPerson
            self.addChild(rSprite!)
        }
    }
}