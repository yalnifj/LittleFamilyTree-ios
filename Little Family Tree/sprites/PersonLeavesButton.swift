//
//  PersonLeavesButton.swift
//  Little Family Tree
//
//  Created by Melissa on 11/25/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class PersonLeavesButton: SKSpriteNode {
	var people:[LittlePerson]? {
		didSet: {
			if leaves != nil {
				leaves?.removeFromParent()
			}
			if leafTextures == nil {
				leafTextures = [SKTexture]()
				leafTextures.append(SKTexture(imageNamed: "leaves_overlay6"))
				leafTextures.append(SKTexture(imageNamed: "leaves_overlay5"))
				leafTextures.append(SKTexture(imageNamed: "leaves_overlay4"))
				leafTextures.append(SKTexture(imageNamed: "leaves_overlay3"))
				leafTextures.append(SKTexture(imageNamed: "leaves_overlay2"))
				leafTextures.append(SKTexture(imageNamed: "leaves_overlay1"))
			}
			
			leaves = SKSpriteNode(imageNamed: "leaves_overlay6")
			leaves?.size = self.size
			leaves?.position = CGPointMake(self.size.width/2, self.size.height/2)
			leaves?.zPosition = 5
			self.addChild(leaves!)
			
			let waitAction = SKAction.waitForDuration(3.0)
			let waitAction2 = SKAction.waitForDuration(2.0)
			let animAction = SKAction.animateWithTextures(leafTextures!, timePerFrame: 0.1, resize: false, restore: true)
			let animAction2 = animAction.reversedAction()
			let actions = SKAction.sequence([waitAction2, animAction, waitAction, animAction2])
			let repeat = SKAction.repeatForever(actions)
			leaves.runAction(repeat)
			
			index = 0
			if photoSprite == nil {
				let photo = TextureHelper.getPortraitTexture(self.people![index])
				photoSprite = SKSpriteNode(texture: photo)
				photoSprite?.position = CGPointMake(self.size.width/2, self.size.height/2)
				let ratio = (photo?.size().width)! / (photo?.size().height)!
				photoSprite?.size.width = self.size.width * 0.8
				photoSprite?.size.height = (self.size.width * 0.8) / ratio
				photoSprite?.zPosition = 1
				self.addChild(photoSprite!)
				
				let waitAction3 = SKAction.waitForDuration(6.2)
				photoSprite?.runAction(waitAction3) {
					self.nextPhoto()
				}
			}
		}
	}
	var index:Int = 0
	
	var photoSprite : SKSpriteNode?
	var leaves : SKSpriteNode?
	var leafTextures : [SKTexture]?
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        
        EventHandler.getInstance().publish(GameScene.TOPIC_START_TREE, data: self)
    }
	
	func nextPhoto() {
		self.index++
		if self.index >= self.people.count {
			self.index = 0
		}
		let nphoto = TextureHelper.getPortraitTexture(self.people![index])
		self.photoSprite.texture = nphoto
		let ratio = (nphoto?.size().width)! / (nphoto?.size().height)!
		photoSprite?.size.width = self.size.width * 0.8
		photoSprite?.size.height = (self.size.width * 0.8) / ratio
		
		let waitAction3 = SKAction.waitForDuration(6.2)
		photoSprite?.runAction(waitAction3) {
			self.nextPhoto()
		}
	}
}