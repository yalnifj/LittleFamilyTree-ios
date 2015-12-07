//
//  DressUpScene.swift
//  Little Family Tree
//
//  Created by Melissa on 12/5/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class DressUpScene: LittleFamilyScene {
    var dolls = DressUpDolls()
    var dollConfig:DollConfig?
    var clothing:[DollClothing]?
    var clotheSprites:[SKSpriteNode] = [SKSpriteNode]()
    var lastPoint : CGPoint!
    var clothingMap = [SKSpriteNode:DollClothing]()
    var doll:SKSpriteNode?
    var movingSprite : SKSpriteNode?
    var scale : CGFloat!
    var snapSprite : SKSpriteNode?
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        self.size.width = view.bounds.width
        self.size.height = view.bounds.height
        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        let background = SKSpriteNode(imageNamed: "dressup_background")
        background.position = CGPointMake(self.size.width/2, self.size.height/2)
        background.size.width = self.size.width
        background.size.height = self.size.height
        background.zPosition = 0
        self.addChild(background)
        
        setupTopBar()
        var boygirl = "boy"
        if (selectedPerson!.gender == GenderType.FEMALE) {
            boygirl = "girl"
        }
        clothing = dollConfig?.getClothing()

        scale = CGFloat(1.0)
        doll = SKSpriteNode(imageNamed: "dolls/\(boygirl)doll")
        doll?.zPosition = 2
        scale = (self.size.height * 0.6) / (doll?.size.height)!
        doll?.setScale(scale)
        doll?.position = CGPointMake(self.size.width/2, self.size.height - (10 + (topBar?.size.height)! + (doll?.size.height)! / 2))
        self.addChild(doll!)
        
        if clothing != nil {
            var x = CGFloat(0)
            var y = CGFloat(0)
            var z = CGFloat(3)
            for cloth in clothing! {
                let clothSprite = SKSpriteNode(imageNamed: cloth.filename)
                clothSprite.zPosition = z++
                clothSprite.setScale(scale)
                if x > self.size.width - clothSprite.size.width/2 {
                    x = CGFloat(0)
                    y = y + clothSprite.size.height
                }
                if x == 0 {
                    x = 10 + clothSprite.size.width / 2
                }
                if y == 0  {
                    y = clothSprite.size.height * 3
                }
                clothSprite.position = CGPointMake(x, y)
                self.addChild(clothSprite)
                x = x + clothSprite.size.width + 20
                clotheSprites.append(clothSprite)
                clothingMap[clothSprite] = cloth
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        movingSprite = nil
        for touch in touches {
            lastPoint = touch.locationInNode(self)
            let touchedNode = nodeAtPoint(lastPoint)
            if touchedNode is SKSpriteNode {
                let clothSprite = touchedNode as! SKSpriteNode
                if clothingMap[clothSprite] != nil {
                    movingSprite = clothSprite
                    let clothing = clothingMap[clothSprite]
                    var snapX = CGFloat((clothing?.snapX)!) * scale
                    snapX = snapX + (doll?.position.x)!/2
                    snapX = snapX + scale*(movingSprite?.size.width)!/2
                    
                    var snapY = self.size.height - ((topBar?.size.height)! + ((CGFloat((clothing?.snapY)!)) * scale))
                    snapY = snapY + (doll?.position.y)!/2
                    snapY = snapY + (movingSprite?.size.height)!/2
                    
                    snapSprite = SKSpriteNode(color: UIColor.blueColor(), size: CGSizeMake(20, 20))
                    snapSprite!.position.x = snapX
                    snapSprite!.position.y = snapY
                    snapSprite!.zPosition = 10
                    self.addChild(snapSprite!)
                }
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if movingSprite != nil {
            var nextPoint = CGPointMake(0,0)
            for touch in touches {
                nextPoint = touch.locationInNode(self)
                let dx = lastPoint.x - nextPoint.x
                let dy = lastPoint.y - nextPoint.y
                movingSprite?.position.x -= dx
                movingSprite?.position.y -= dy
            }
            
            lastPoint = nextPoint
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        if movingSprite != nil {
            let clothing = clothingMap[movingSprite!]
            var snapX = CGFloat((clothing?.snapX)!) * scale
            snapX = snapX + (doll?.position.x)!/2
            snapX = snapX + scale*(movingSprite?.size.width)!/2
            
            var snapY = self.size.height - ((topBar?.size.height)! + ((CGFloat((clothing?.snapY)!)) * scale))
            snapY = snapY + (doll?.position.y)!/2
            snapY = snapY + (movingSprite?.size.height)!/2
            if movingSprite?.position.x >= snapX - 10 && movingSprite?.position.x <= snapX + 10
                && movingSprite?.position.y >= snapY - 10 && movingSprite?.position.y <= snapY + 10 {
                    movingSprite?.position.x = snapX
                    movingSprite?.position.y = snapY
                    clothing?.placed = true
            } else {
                clothing?.placed = false
            }
            movingSprite = nil
        }
        if snapSprite != nil {
            snapSprite?.removeFromParent()
            snapSprite = nil
        }
    }
}