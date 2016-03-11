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
	var settingsSprite:SKSpriteNode?
    var customSprites = [SKSpriteNode]()
    
    var person:LittlePerson? {
        didSet {
            let photo = TextureHelper.getPortraitTexture(self.person!)
            photoSprite = SKSpriteNode(texture: photo)
            let ratio = (photo?.size().width)! / (photo?.size().height)!
            photoSprite?.size.height = self.size.height - 5
            photoSprite?.size.width = (self.size.height - 5) * ratio
            photoSprite?.position = CGPointMake(((photoSprite?.size.width)! / 2) + 5 - self.size.width/2, 0)
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
            homeSprite?.position = CGPointMake(self.size.width/2 - (5 + self.size.height/2), 0)
            homeSprite?.zPosition = 1
            self.addChild(homeSprite!)

			settingsSprite = SKSpriteNode(imageNamed: "settings")
			settingsSprite?.size.height = self.size.height - 5
			settingsSprite?.size.width = self.size.height - 5
			settingsSprite?.position = CGPointMake(0, 0)
			settingsSprite?.zPosition = 1
			self.addChild(settingsSprite!)
        }
    }
    
    func addCustomSprite(sprite:SKSpriteNode) {
        customSprites.append(sprite)
        let ratio = sprite.size.height / sprite.size.width
        sprite.size.height = self.size.height - 5
        sprite.size.width = sprite.size.height / ratio
        let width = self.size.width - photoSprite!.size.width - homeSprite!.size.width - 20
        let bwidth = width / CGFloat(customSprites.count + 1)
        settingsSprite?.position.x = photoSprite!.position.x + (photoSprite!.size.width / 2) + (bwidth / 2)
        var x = settingsSprite!.position.x + bwidth
        for s in customSprites {
            s.position = CGPointMake(x, 0)
            x = x + bwidth
        }
        
        self.addChild(sprite)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        for touch in touches {
            let location = touch.locationInNode(self)
            let touchedNode = nodeAtPoint(location)
            if touchedNode == homeSprite {
                EventHandler.getInstance().publish(LittleFamilyScene.TOPIC_START_HOME, data: person)
            }
            else if touchedNode == photoSprite {
                EventHandler.getInstance().publish(LittleFamilyScene.TOPIC_START_CHOOSE, data: person)
            }
			else if touchedNode == settingsSprite {
				EventHandler.getInstance().publish(LittleFamilyScene.TOPIC_START_SETTINGS, data: person)
			}
            else {
                for sprite in customSprites {
                    if touchedNode == sprite || touchedNode.parent == sprite || sprite.children.contains(touchedNode) {
                        sprite.touchesEnded(touches, withEvent: event)
                    }
                }
            }
        }
    }

}