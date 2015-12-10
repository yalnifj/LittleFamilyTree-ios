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
    //var snapSprite : SKSpriteNode?
    var dollHolder : SKSpriteNode?
    var countryLabel : SKLabelNode?
    var scrollingDolls = false
    var scrolling = false
    var thumbSpriteMap = [SKNode : String]()
    var snapTolerance = CGFloat(10)
    var outlines = [SKSpriteNode : SKSpriteNode]()
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        self.size.width = view.bounds.width
        self.size.height = view.bounds.height
        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        snapTolerance = self.size.width / 25
        
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

        scale = CGFloat(1.0)
        doll = SKSpriteNode(imageNamed: "dolls/\(boygirl)doll")
        doll?.zPosition = 2
        scale = (self.size.height * 0.6) / (doll?.size.height)!
        doll?.setScale(scale)
        doll?.position = CGPointMake(self.size.width/2, self.size.height - (10 + (topBar?.size.height)! + (doll?.size.height)! / 2))
        self.addChild(doll!)
        
        setupSprites()
        
        var places = dolls.getDollPlaces()
        let color = UIColor(colorLiteralRed: 0.8, green: 0.8, blue: 0.8, alpha: 0.3)
        let height = (countryLabel?.position.y)! - 10
        dollHolder = SKSpriteNode(color: color, size: CGSizeMake(CGFloat(places.count+1) * (5 + height * 0.7), height))
        dollHolder?.position = CGPointMake((dollHolder?.size.width)!/2, (dollHolder?.size.height)! / 2)
        dollHolder?.zPosition = 2
        dollHolder?.hidden = true
        self.addChild(dollHolder!)
        
        places.sortInPlace()
        var dx = ((dollHolder?.size.height)! * 0.3) + CGFloat(-1 * (dollHolder?.size.width)! / 2)
        for place in places {
            let dc = dolls.getDollConfig(place, person: selectedPerson!)
            let thumb = SKSpriteNode(imageNamed: dc.getThumbnail())
            thumb.position = CGPointMake(dx, 14)
            let ratio = (thumb.texture?.size().width)! / (thumb.texture?.size().height)!
            thumb.size.height = (dollHolder?.size.height)! * 0.7
            thumb.size.width = thumb.size.height * ratio
            dollHolder?.addChild(thumb)
            thumbSpriteMap[thumb] = place
            
            let pl = SKLabelNode(text: dc.originalPlace)
            pl.fontSize = thumb.size.height / 7
            pl.fontColor = UIColor.blackColor()
            pl.position = CGPointMake(dx, thumb.size.height * -0.6)
            dollHolder?.addChild(pl)
            thumbSpriteMap[pl] = place
            
            dx = dx + thumb.size.height + 10
        }
        
    }
    
    func setupSprites() {
        if countryLabel != nil {
            countryLabel?.removeFromParent()
        }
        countryLabel = SKLabelNode(text: dollConfig?.originalPlace!)
        countryLabel?.fontSize = (topBar?.size.height)!
        countryLabel?.fontColor = UIColor.blackColor()
        countryLabel?.position = CGPointMake(self.size.width / 2, (doll?.position.y)! - ((countryLabel?.fontSize)! + (doll?.size.height)! / 2))
        countryLabel?.zPosition = 2
        self.addChild(countryLabel!)
        
        for s in clotheSprites {
            s.removeFromParent()
        }
        clotheSprites.removeAll()
        for s in outlines.values {
            s.removeFromParent()
        }
        outlines.removeAll()
        clothing = dollConfig?.getClothing()
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
                
                let outlineSprite = SKSpriteNode(imageNamed: cloth.filename)
                outlineSprite.zPosition = (doll?.zPosition)! + 1
                outlineSprite.setScale(scale)
                outlineSprite.position = getSnap(cloth, sprite:clothSprite)
                outlineSprite.shader = SKShader(fileNamed: "alphaOutline.fsh")
                outlineSprite.hidden = true
                self.addChild(outlineSprite)
                outlines[clothSprite] = outlineSprite
            }
        }
    }
    
    func getSnap(clothing:DollClothing, sprite:SKSpriteNode) -> CGPoint {
        let offsetX = (self.size.width - (doll?.size.width)!) / 2
        let snapX = offsetX + scale * CGFloat(clothing.snapX) + sprite.size.width / 2
        let cgSnapY = scale * CGFloat(clothing.snapY)
        let h2 = sprite.size.height / 2
        let top = (doll?.position.y)! + (1 * (doll?.size.height)!/2)
        let snapY = top - (cgSnapY + h2)
        let snap = CGPointMake(snapX, snapY)
        return snap
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
                    let outlineSprite = outlines[clothSprite]
                    if outlineSprite != nil {
                        outlineSprite?.hidden = false
                    }
                    
                    /*
                    let clothing = clothingMap[clothSprite]
                    let snapPoint = getSnap(clothing!, sprite:clothSprite)
                    snapSprite = SKSpriteNode(color: UIColor.blueColor(), size: CGSizeMake(snapTolerance*2, snapTolerance*2))
                    snapSprite!.position = snapPoint
                    snapSprite!.zPosition = 10
                    self.addChild(snapSprite!)
*/
                }
                else if touchedNode == dollHolder || touchedNode.parent == dollHolder {
                    scrollingDolls = true
                }
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var nextPoint = CGPointMake(0,0)
        for touch in touches {
            nextPoint = touch.locationInNode(self)
            if movingSprite != nil {
                let dx = lastPoint.x - nextPoint.x
                let dy = lastPoint.y - nextPoint.y
                movingSprite?.position.x -= dx
                movingSprite?.position.y -= dy
            }
            if scrollingDolls {
                let dx = lastPoint.x - nextPoint.x
                dollHolder?.position.x -= dx
                if dollHolder?.position.x < self.size.width - (dollHolder?.size.width)! / 2 {
                    dollHolder?.position.x = self.size.width - (dollHolder?.size.width)! / 2
                }
                if dollHolder?.position.x > (dollHolder?.size.width)!/2 {
                    dollHolder?.position.x = (dollHolder?.size.width)!/2
                }
                scrolling = true
            }
        }
        lastPoint = nextPoint
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        if movingSprite != nil {
            let clothing = clothingMap[movingSprite!]
            let snapPoint = getSnap(clothing!, sprite:movingSprite!)
            
            if movingSprite?.position.x >= snapPoint.x - snapTolerance && movingSprite?.position.x <= snapPoint.x + snapTolerance
                && movingSprite?.position.y >= snapPoint.y - snapTolerance && movingSprite?.position.y <= snapPoint.y + snapTolerance {
                    movingSprite?.position = snapPoint
                    clothing?.placed = true
            } else {
                clothing?.placed = false
            }
            let outlineSprite = outlines[movingSprite!]
            if outlineSprite != nil {
                outlineSprite?.hidden = true
            }
            movingSprite = nil
            
            var allPlaced = true
            for clothing in clothingMap.values {
                if clothing.placed == false {
                    allPlaced = false
                    break
                }
            }
            if allPlaced == true {
                self.playSuccessSound(0.5, onCompletion: { () in
                    self.dollHolder?.hidden = false
                })
            } else {
                dollHolder?.hidden = true
            }
        }
        /*
        if snapSprite != nil {
            snapSprite?.removeFromParent()
            snapSprite = nil
        }
*/
        if scrolling == false {
            for touch in touches {
                lastPoint = touch.locationInNode(self)
                let touchedNode = nodeAtPoint(lastPoint)
                if thumbSpriteMap[touchedNode] != nil {
                    let place = thumbSpriteMap[touchedNode]
                    self.dollConfig = self.dolls.getDollConfig(place, person: self.selectedPerson!)
                    self.setupSprites()
                    self.dollHolder?.hidden = true
                }
            }
        }
        scrollingDolls = false
        scrolling = false
    }
    
}