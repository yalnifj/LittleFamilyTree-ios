//
//  ScratchScene.swift
//  Little Family Tree
//
//  Created by Melissa on 12/10/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class ScratchScene: LittleFamilyScene, RandomMediaListener {
    var randomMediaChooser = RandomMediaChooser.getInstance()
    
	var photoSprite:SKSpriteNode?
	var coverSprite:SKSpriteNode?
    var image:UIImage?
	var lastPoint : CGPoint!
    var scratching = false
    
    var nameLabel:SKLabelNode?
    var relationshipLabel:SKLabelNode?
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        self.size.width = view.bounds.width
        self.size.height = view.bounds.height
        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        let background = SKSpriteNode(imageNamed: "scratch_background")
        background.position = CGPointMake(self.size.width/2, self.size.height/2)
        background.size.width = self.size.width
        background.size.height = self.size.height
        background.zPosition = 0
        self.addChild(background)
        
        setupTopBar()
        
        showLoadingDialog()
        
        randomMediaChooser.listener = self
        randomMediaChooser.addPeople([selectedPerson!])
        randomMediaChooser.loadMoreFamilyMembers()
    }
    
    override func willMoveFromView(view: SKView) {
        super.willMoveFromView(view)
    }
    
    override func update(currentTime: NSTimeInterval) {
        
    }
    
    func onMediaLoaded(media:Media?) {
        if media == nil {
            randomMediaChooser.loadMoreFamilyMembers()
            return
        }
        
        let texture = TextureHelper.getTextureForMedia(media!, size: self.size)
        if texture != nil {
            if photoSprite != nil {
                photoSprite?.removeFromParent()
            }
            if coverSprite != nil {
                coverSprite?.removeFromParent()
            }
            if nameLabel != nil {
                nameLabel?.removeFromParent()
            }
            if relationshipLabel != nil {
                relationshipLabel?.removeFromParent()
            }
            
            let ratio = (texture?.size().width)! / (texture?.size().height)!
            var w = self.size.width
            var h = self.size.height - (topBar?.size.height)! * 3
            if ratio < 1.0 || w > h{
                w = h * ratio
            } else {
                h = w / ratio
            }
            
            let ypos = 30 + (self.size.height / 2) - (topBar?.size.height)!
            
            photoSprite = SKSpriteNode(texture: texture, size: CGSizeMake(w, h))
            photoSprite?.zPosition = 2
            photoSprite?.position = CGPointMake(self.size.width / 2, ypos)
            photoSprite?.size.width = w
            photoSprite?.size.height = h
            self.addChild(photoSprite!)
            
            /*
            let coverTexture = SKMutableTexture(size: (photoSprite?.size)!)
            coverTexture.modifyPixelDataWithBlock( { (data, length) -> Void in
                // convert the void pointer into a pointer to your struct
                let pixels = UnsafeMutablePointer<RGBA>(data)
                let count = length / sizeof(RGBA)
                for i in 0..<count {
                    pixels[i].r = 0x55
                    pixels[i].g = 0x55
                    pixels[i].b = 0x55
                    pixels[i].a = 0x77
                }
            })
            */
            
            let rect = CGRectMake(0, 0, (photoSprite?.size.width)!, (photoSprite?.size.height)!)
            UIGraphicsBeginImageContextWithOptions((photoSprite?.size)!, false, 0)
            let color = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
            color.setFill()
            UIRectFill(rect)
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let coverTexture = SKTexture(image: image!)
            coverSprite = SKSpriteNode(texture: coverTexture)
            coverSprite?.zPosition = 3
            coverSprite?.position = CGPointMake(self.size.width / 2, ypos)
            coverSprite?.size.width = w
            coverSprite?.size.height = h
            self.addChild(coverSprite!)

            
            hideLoadingDialog()
            
        } else {
            randomMediaChooser.loadMoreFamilyMembers()
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        for touch in touches {
            lastPoint = touch.locationInNode(self)
            let touchedNode = nodeAtPoint(lastPoint)
            if touchedNode == coverSprite {
                scratching = true
                let sound = SKAction.playSoundFileNamed("erasing", waitForCompletion: true)
                let repeatSound = SKAction.repeatActionForever(sound)
                self.runAction(repeatSound)
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var nextPoint = CGPointMake(0,0)
        for touch in touches {
            nextPoint = touch.locationInNode(self)
            if scratching {
                drawLineFrom(lastPoint, toPoint: nextPoint)
                
                let r = CGFloat(1 + arc4random_uniform(3))
                let bit = SKShapeNode(circleOfRadius: r)
                bit.strokeColor = UIColor.grayColor()
                bit.fillColor = UIColor.grayColor()
                bit.position = nextPoint
                bit.zPosition = 10
                self.addChild(bit)
                
                let move = SKAction.moveByX((nextPoint.x - lastPoint.x) * 2.5, y: (nextPoint.y - lastPoint.y) * 2.5, duration: 0.7)
                let actions = SKAction.sequence([move, SKAction.removeFromParent()])
                bit.runAction(actions)
            }
        }
        lastPoint = nextPoint
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        for touch in touches {
            lastPoint = touch.locationInNode(self)

        }
        self.removeAllActions()
        checkComplete()
        scratching = false
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        UIGraphicsBeginImageContext((image?.size)!)
        let context = UIGraphicsGetCurrentContext()
        
        let oy = (photoSprite?.position.y)! - (photoSprite?.size.height)!/2
        let ox = (photoSprite?.position.x)! - (photoSprite?.size.width)!/2
        
        image?.drawInRect(CGRect(x: 0, y: 0, width: (image?.size.width)!, height: (image?.size.height)!))
        
        CGContextMoveToPoint(context, fromPoint.x - ox, (photoSprite?.size.height)! - (fromPoint.y - oy))
        CGContextAddLineToPoint(context, toPoint.x - ox, (photoSprite?.size.height)! - (toPoint.y - oy))
        
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, self.size.width/9)
        CGContextSetRGBStrokeColor(context, 0, 0, 0, 1.0)
        CGContextSetBlendMode(context, CGBlendMode.Clear)
        
        CGContextStrokePath(context)
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let coverTexture = SKTexture(image: image!)
        coverSprite?.texture = coverTexture
    }
    
    func checkComplete() {
        var complete = false
        
        let provider = CGImageGetDataProvider(image!.CGImage)
        let providerData = CGDataProviderCopyData(provider)
        let data = CFDataGetBytePtr(providerData)
        
        let numberOfComponents = Int(4)
        var count:Float = 0
        var passed:Float = 0
        var y = (coverSprite?.size.height)! / 30
        repeat {
            var x = (coverSprite?.size.width)! / 30
            repeat {
                let pixelData = Int(((coverSprite?.size.width)! * y) + x) * numberOfComponents

                    let a = data[pixelData + 3]
                    if (a < 30) {
                        passed++
                    }
                    count++
                
                x += (coverSprite?.size.width)! / 30
            } while(x < coverSprite?.size.width)
            y += (coverSprite?.size.height)! / 30
        } while(y < (coverSprite?.size.height)!)
        
        if passed / count > 0.98 {
            complete = true
        }
        
        if complete {
            coverSprite?.hidden = true
            self.showStars((self.photoSprite?.frame)!, starsInRect: false, count: Int(self.size.width / CGFloat(35)))
            self.playSuccessSound(1.0, onCompletion: {
                if self.nameLabel != nil {
                    self.nameLabel?.removeFromParent()
                }
                self.nameLabel = SKLabelNode(text: self.randomMediaChooser.selectedPerson?.name as? String)
                self.nameLabel?.fontSize = self.size.height / 30
                self.nameLabel?.position = CGPointMake(self.size.width / 2, (self.nameLabel?.fontSize)! * 2)
                self.nameLabel?.zPosition = 12
                self.nameLabel?.fontName = (self.nameLabel?.fontName)! + "-Bold"
                self.nameLabel?.color = UIColor.blackColor()
                self.addChild(self.nameLabel!)
                
                if self.relationshipLabel != nil {
                    self.relationshipLabel?.removeFromParent()
                }
                let relationship = RelationshipCalculator.getRelationship(self.selectedPerson, p: self.randomMediaChooser.selectedPerson)
                self.relationshipLabel = SKLabelNode(text: relationship)
                self.relationshipLabel?.fontSize = (self.nameLabel?.fontSize)!
                self.relationshipLabel?.position = CGPointMake(self.size.width / 2, (self.nameLabel?.fontSize)! / 2)
                self.relationshipLabel?.zPosition = 12
                self.relationshipLabel?.fontName = (self.nameLabel?.fontName)! + "-Bold"
                self.relationshipLabel?.color = UIColor.blackColor()
                self.addChild(self.relationshipLabel!)
                
                SpeechHelper.getInstance().speak(self.randomMediaChooser.selectedPerson?.givenName as! String)
                let waitAction = SKAction.waitForDuration(2.5)
                self.runAction(waitAction) {
                    self.showLoadingDialog()
                    self.randomMediaChooser.loadRandomImage()
                }
            })

        }
    }
}