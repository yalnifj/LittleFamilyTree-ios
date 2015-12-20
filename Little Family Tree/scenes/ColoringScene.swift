//
//  ColoringScene.swift
//  Little Family Tree
//
//  Created by Melissa on 12/10/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

// struct of 4 bytes
struct RGBA {
    var r: UInt8
    var g: UInt8
    var b: UInt8
    var a: UInt8
}

class ColoringScene: LittleFamilyScene, RandomMediaListener {
    var randomMediaChooser = RandomMediaChooser.getInstance()
    
	var photoSprite:SKSpriteNode?
	var coverSprite:SKSpriteNode?
	var lastPoint : CGPoint!
    var coverTexture = SKMutableTexture()
    var outlineSprite:SKEffectNode?
    var photoCopySprite:SKSpriteNode?
    
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
            
            let ratio = (texture?.size().width)! / (texture?.size().height)!
            var w = self.size.width
            var h = self.size.height - (topBar?.size.height)! * 3
            if ratio < 1.0 {
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
            
            let coverTexture = SKMutableTexture(size: (photoSprite?.size)!)
            coverTexture.modifyPixelDataWithBlock( { (data, length) -> Void in
                // convert the void pointer into a pointer to your struct
                let pixels = UnsafeMutablePointer<RGBA>(data)
                let count = length / sizeof(RGBA)
                for i in 0..<count {
                    pixels[i].r = 0xff
                    pixels[i].g = 0xff
                    pixels[i].b = 0xff
                    pixels[i].a = 0x55
                }
            })
            
            coverSprite = SKSpriteNode(texture: coverTexture)
            coverSprite?.zPosition = 3
            coverSprite?.position = CGPointMake(self.size.width / 2, ypos)
            coverSprite?.size.width = w
            coverSprite?.size.height = h
            self.addChild(coverSprite!)

            var filter:CIFilter? = nil
            let os = NSProcessInfo().operatingSystemVersion
            switch(os.majorVersion) {
                case 9:
                    filter = CIFilter(name: "CILineOverlay")!
                break
                default:
                    filter = CIFilter(name: "CIEdgeWork")!
                break
            }
            outlineSprite = SKEffectNode()
            outlineSprite?.zPosition = 4
            outlineSprite?.position = CGPointMake(self.size.width / 2, ypos)
            outlineSprite?.filter = filter
            self.addChild(outlineSprite!)
            
            photoCopySprite = SKSpriteNode(texture: texture, size: CGSizeMake(w, h))
            photoCopySprite?.zPosition = 2
            photoCopySprite?.position = CGPointMake(0, 0)
            photoCopySprite?.size.width = w
            photoCopySprite?.size.height = h
            outlineSprite?.addChild(photoCopySprite!)
            
            

            
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
                
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var nextPoint = CGPointMake(0,0)
        for touch in touches {
            nextPoint = touch.locationInNode(self)
            
        }
        lastPoint = nextPoint
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        for touch in touches {
            lastPoint = touch.locationInNode(self)

        }
    }
}