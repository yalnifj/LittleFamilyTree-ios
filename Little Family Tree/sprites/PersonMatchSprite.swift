//
//  PersonMatchSprite.swift
//  Little Family Tree
//
//  Created by Melissa on 11/25/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class PersonMatchSprite: SKSpriteNode {
    var flipping = false
    var gameScene:MatchGameScene?
    var person:MatchPerson? {
        didSet {
            let back = SKSpriteNode(color: UIColor(hexString: "#D99F9FDD"), size: CGSizeMake(self.size.width * 0.87, self.size.height * 0.87))
            if self.person!.frame == 3 {
                back.size = CGSizeMake(self.size.width * 0.72, self.size.height * 0.72)
            }
            else if self.person!.frame == 5 {
                back.size = CGSizeMake(self.size.width * 0.75, self.size.height * 0.85)
            }
            back.position = CGPointMake(self.size.width/2, self.size.height/2)
            back.zPosition = 1
            self.addChild(back)
            
            let photo = TextureHelper.getPortraitTexture(self.person!.person)
            photoSprite = SKSpriteNode(texture: photo)
            photoSprite?.position = CGPointMake(self.size.width/2, self.size.height/2)
            let ratio = (photo?.size().width)! / (photo?.size().height)!
            photoSprite?.size.width = self.size.width * 0.6
            photoSprite?.size.height = (self.size.width * 0.6) / ratio
            photoSprite?.zPosition = 2
            photoSprite?.hidden = true
            self.addChild(photoSprite!)
            
            frameSprite = SKSpriteNode(imageNamed: "frame\(self.person!.frame)")
            frameSprite?.position = CGPointMake(self.size.width/2, self.size.height/2)
            frameSprite?.size.width = self.size.width
            frameSprite?.size.height = self.size.height
            frameSprite?.zPosition = 3
            self.addChild(frameSprite!)
        }
    }
    var frameSprite:SKSpriteNode?
    var photoSprite:SKSpriteNode?
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        
        if person?.matched == false {
            gameScene?.frameTouched(self)
        } else {
            gameScene?.sayGivenName(person!)
        }
    }
    
    func flip() {
        if flipping == false {
            flipping = true
            removeAllActions();
            let firstHalfFlip = SKAction.scaleXTo(0.0, duration: 0.3)
            let secondHalfFlip = SKAction.scaleXTo(1.0, duration: 0.3)
            let firstHalfMove = SKAction.moveByX(self.size.width/2, y: 0, duration: 0.3)
            let secondHalfMove = SKAction.moveByX(-self.size.width/2, y: 0, duration: 0.3)
        
            setScale(1.0)
            
            runAction(firstHalfMove)
            runAction(firstHalfFlip) {
                if self.person?.flipped == true {
                    self.person?.flipped = false
                    self.photoSprite?.hidden = true
                } else {
                    self.person?.flipped = true
                    self.photoSprite?.hidden = false
                    self.gameScene?.speak(self.person!.person.givenName as! String)
                }
                self.runAction(secondHalfMove)
                self.runAction(secondHalfFlip) {
                    self.flipping = false
                }
            }
        }
    }
    
    func delayFlip() {
        let delayAction = SKAction.waitForDuration(2.0)
        runAction(delayAction) {
            self.flip()
        }
    }
    
}