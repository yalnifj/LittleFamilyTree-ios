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
            let back = SKSpriteNode(color: UIColor(hexString: "#D99F9FDD"), size: CGSize(width: self.size.width * 0.87, height: self.size.height * 0.87))
            if self.person!.frame == 3 {
                back.size = CGSize(width: self.size.width * 0.72, height: self.size.height * 0.72)
            }
            else if self.person!.frame == 5 {
                back.size = CGSize(width: self.size.width * 0.75, height: self.size.height * 0.85)
            }
            back.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
            back.zPosition = 1
            self.addChild(back)
            
            let photo = TextureHelper.getPortraitTexture(self.person!.person)
            photoSprite = SKSpriteNode(texture: photo)
            photoSprite?.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
            let ratio = (photo?.size().width)! / (photo?.size().height)!
            photoSprite?.size.width = self.size.width * 0.6
            photoSprite?.size.height = (self.size.width * 0.6) / ratio
            photoSprite?.zPosition = 2
            photoSprite?.isHidden = true
            self.addChild(photoSprite!)
            
            frameSprite = SKSpriteNode(imageNamed: "frame\(self.person!.frame)")
            frameSprite?.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
            frameSprite?.size.width = self.size.width
            frameSprite?.size.height = self.size.height
            frameSprite?.zPosition = 3
            self.addChild(frameSprite!)
        }
    }
    var frameSprite:SKSpriteNode?
    var photoSprite:SKSpriteNode?
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if person?.matched == false {
            gameScene?.frameTouched(self)
        } else {
            gameScene?.sayGivenName(person!.person)
        }
    }
    
    func flip() {
        if flipping == false {
            flipping = true
            removeAllActions();
            let firstHalfFlip = SKAction.scaleX(to: 0.0, duration: 0.3)
            let secondHalfFlip = SKAction.scaleX(to: 1.0, duration: 0.3)
            let firstHalfMove = SKAction.moveBy(x: self.size.width/2, y: 0, duration: 0.3)
            let secondHalfMove = SKAction.moveBy(x: -self.size.width/2, y: 0, duration: 0.3)
        
            setScale(1.0)
            
            run(firstHalfMove)
            run(firstHalfFlip, completion: {
                if self.person?.flipped == true {
                    self.person?.flipped = false
                    self.photoSprite?.isHidden = true
                } else {
                    self.person?.flipped = true
                    self.photoSprite?.isHidden = false
                    self.gameScene?.sayGivenName(self.person!.person)
                }
                self.run(secondHalfMove)
                self.run(secondHalfFlip, completion: {
                    self.flipping = false
                }) 
            }) 
        }
    }
    
    func delayFlip() {
        let delayAction = SKAction.wait(forDuration: 2.0)
        run(delayAction, completion: {
            self.flip()
        }) 
    }
    
}
