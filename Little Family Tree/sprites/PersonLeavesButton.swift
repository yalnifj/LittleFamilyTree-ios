//
//  PersonLeavesButton.swift
//  Little Family Tree
//
//  Created by Melissa on 11/25/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class PersonLeavesButton: SKSpriteNode {
	var people:[LittlePerson]? {
		didSet {
			if leaves != nil {
				leaves?.removeFromParent()
			}
			if leafTextures == nil {
				leafTextures = [SKTexture]()
				leafTextures?.append(SKTexture(imageNamed: "leaves_overlay6"))
				leafTextures?.append(SKTexture(imageNamed: "leaves_overlay5"))
				leafTextures?.append(SKTexture(imageNamed: "leaves_overlay4"))
				leafTextures?.append(SKTexture(imageNamed: "leaves_overlay3"))
				leafTextures?.append(SKTexture(imageNamed: "leaves_overlay2"))
				leafTextures?.append(SKTexture(imageNamed: "leaves_overlay1"))
			}
			
			leaves = SKSpriteNode(imageNamed: "leaves_overlay6")
			leaves?.size = self.size
			leaves?.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
			leaves?.zPosition = 5
			self.addChild(leaves!)
			
			let waitAction = SKAction.wait(forDuration: 3.0)
			let waitAction2 = SKAction.wait(forDuration: 1.0)
            let animAction = SKAction.animate(with: leafTextures!, timePerFrame: 0.15, resize: false, restore: false)
			let animAction2 = animAction.reversed()
			let actions = SKAction.sequence([waitAction2, animAction, waitAction, animAction2])
			let repeated = SKAction.repeatForever(actions)
			leaves?.run(repeated)
			
			index = 0
			if photoSprite == nil && self.people != nil && index < self.people!.count {
				let photo = TextureHelper.getPortraitTexture(self.people![index])
				photoSprite = SKSpriteNode(texture: photo)
				photoSprite?.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
				let ratio = (photo?.size().width)! / (photo?.size().height)!
                if ratio < 1.0 {
                    photoSprite?.size.height = self.size.height * 0.8
                    photoSprite?.size.width = (self.size.height * 0.8) * ratio
                } else {
                    photoSprite?.size.width = self.size.width * 0.8
                    photoSprite?.size.height = (self.size.width * 0.8) / ratio
                }
				photoSprite?.zPosition = 1
				self.addChild(photoSprite!)
				
				let waitAction3 = SKAction.wait(forDuration: 7.3)
				photoSprite?.run(waitAction3, completion: {
					self.nextPhoto()
				}) 
			}
		}
	}
	var index:Int = 0
	
	var photoSprite : SKSpriteNode?
	var leaves : SKSpriteNode?
	var leafTextures : [SKTexture]?
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        EventHandler.getInstance().publish(GameScene.TOPIC_START_TREE, data: self)
    }
	
	func nextPhoto() {
		self.index += 1
		if self.index >= self.people?.count {
			self.index = 0
		}
		let nphoto = TextureHelper.getPortraitTexture(self.people![index])
		self.photoSprite?.texture = nphoto
        let ratio = (nphoto?.size().width)! / (nphoto?.size().height)!
        if ratio < 1.0 {
            photoSprite?.size.height = self.size.height * 0.8
            photoSprite?.size.width = (self.size.height * 0.8) * ratio
        } else {
            photoSprite?.size.width = self.size.width * 0.8
            photoSprite?.size.height = (self.size.width * 0.8) / ratio
        }
		
		let waitAction3 = SKAction.wait(forDuration: 5.3)
		photoSprite?.run(waitAction3, completion: {
			self.nextPhoto()
		}) 
	}
}
