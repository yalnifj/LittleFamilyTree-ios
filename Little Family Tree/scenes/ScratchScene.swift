//
//  ScratchScene.swift
//  Little Family Tree
//
//  Created by Melissa on 12/10/15.
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


class ScratchScene: LittleFamilyScene, RandomMediaListener {
    var randomMediaChooser = RandomMediaChooser.getInstance()
    
	var photoSprite:SKSpriteNode?
	var coverSprite:SKSpriteNode?
    var image:UIImage?
	var lastPoint : CGPoint!
    var scratching = false
    var completed = false
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.size.width = view.bounds.width
        self.size.height = view.bounds.height
        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        let background = SKSpriteNode(imageNamed: "scratch_background")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
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
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
    }
    
    func onMediaLoaded(_ media:Media?) {
        if media == nil {
            if randomMediaChooser.counter < randomMediaChooser.maxTries {
                randomMediaChooser.loadMoreFamilyMembers()
                return
            } else {
                DispatchQueue.main.async {
                    self.hideLoadingDialog()
                    self.showSimpleDialog("No Pictures Found", message: "There are not many pictures in your family tree. This activity requires pictures. Please add more pictures to your online family tree.")
                }
                return
            }
        }
        
        let texture = TextureHelper.getTextureForMedia(media!, size: CGSize(width: self.size.width * 0.66, height: self.size.height * 0.66))
        if texture != nil {
            if photoSprite != nil {
                photoSprite?.removeFromParent()
            }
            if coverSprite != nil {
                coverSprite?.removeFromParent()
            }
            
            let ratio = (texture?.size().width)! / (texture?.size().height)!
            var w = self.size.width - 10
            var h = self.size.height - (topBar?.size.height)! * 3
            if ratio < 1.0 || w > h{
                w = h * ratio
                if w > self.size.width - 10 {
                    w = self.size.width - 10
                    h = w / ratio
                }
            } else {
                h = w / ratio
                if h > self.size.height - (topBar?.size.height)! * 3 {
                    h = self.size.height - (topBar?.size.height)! * 3
                    w = h * ratio
                }
            }
            
            let ypos = 30 + (self.size.height / 2) - (topBar?.size.height)!
            
            photoSprite = SKSpriteNode(texture: texture, size: CGSize(width: w, height: h))
            photoSprite?.zPosition = 2
            photoSprite?.position = CGPoint(x: self.size.width / 2, y: ypos)
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
            
            let rect = CGRect(x: 0, y: 0, width: (photoSprite?.size.width)!, height: (photoSprite?.size.height)!)
            UIGraphicsBeginImageContextWithOptions((photoSprite?.size)!, false, 0)
            let color = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
            color.setFill()
            UIRectFill(rect)
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let coverTexture = SKTexture(image: image!)
            coverSprite = SKSpriteNode(texture: coverTexture)
            coverSprite?.zPosition = 3
            coverSprite?.position = CGPoint(x: self.size.width / 2, y: ypos)
            coverSprite?.size.width = w
            coverSprite?.size.height = h
            self.addChild(coverSprite!)

            
            hideLoadingDialog()
            completed = false
            
        } else {
            randomMediaChooser.loadMoreFamilyMembers()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        for touch in touches {
            lastPoint = touch.location(in: self)
            let touchedNode = atPoint(lastPoint)
            if touchedNode == coverSprite {
                scratching = true
                let quietMode = DataService.getInstance().dbHelper.getProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET)
                if quietMode == nil || quietMode == "false" {
                    let sound = SKAction.playSoundFileNamed("erasing", waitForCompletion: true)
                    let repeatSound = SKAction.repeatForever(sound)
                    self.run(repeatSound)
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        var nextPoint = CGPoint(x: 0,y: 0)
        for touch in touches {
            nextPoint = touch.location(in: self)
            if scratching {
                drawLineFrom(lastPoint, toPoint: nextPoint)
                
                let r = CGFloat(1 + arc4random_uniform(3))
                let bit = SKShapeNode(circleOfRadius: r)
                bit.strokeColor = UIColor.gray
                bit.fillColor = UIColor.gray
                bit.position = nextPoint
                bit.zPosition = 10
                self.addChild(bit)
                
                let move = SKAction.moveBy(x: (nextPoint.x - lastPoint.x) * 2.5, y: (nextPoint.y - lastPoint.y) * 2.5, duration: 0.7)
                let actions = SKAction.sequence([move, SKAction.removeFromParent()])
                bit.run(actions)
            }
        }
        lastPoint = nextPoint
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch in touches {
            lastPoint = touch.location(in: self)

        }
        self.removeAllActions()
        //if !completed {
            checkComplete()
        //}
        scratching = false
    }
    
    func drawLineFrom(_ fromPoint: CGPoint, toPoint: CGPoint) {
        UIGraphicsBeginImageContext((image?.size)!)
        let context = UIGraphicsGetCurrentContext()
        
        let oy = (photoSprite?.position.y)! - (photoSprite?.size.height)!/2
        let ox = (photoSprite?.position.x)! - (photoSprite?.size.width)!/2
        
        image?.draw(in: CGRect(x: 0, y: 0, width: (image?.size.width)!, height: (image?.size.height)!))
        
        context!.move(to: CGPoint(x: fromPoint.x - ox, y: (photoSprite?.size.height)! - (fromPoint.y - oy)))
        context!.addLine(to: CGPoint(x: toPoint.x - ox, y: (photoSprite?.size.height)! - (toPoint.y - oy)))
        
        context!.setLineCap(CGLineCap.round)
        context!.setLineWidth(self.size.width/9)
        context!.setStrokeColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        context!.setBlendMode(CGBlendMode.clear)
        
        context!.strokePath()
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let coverTexture = SKTexture(image: image!)
        coverSprite?.texture = coverTexture
    }
    
    func checkComplete() {
        var complete = false
        if image != nil {
            let provider = image!.cgImage!.dataProvider
            let providerData = provider!.data
            let data = CFDataGetBytePtr(providerData)
            
            let numberOfComponents = Int(4)
            var count:Float = 0
            var passed:Float = 0
            var y = (coverSprite?.size.height)! / 30
            repeat {
                var x = (coverSprite?.size.width)! / 30
                repeat {
                    let pixelData = Int(((coverSprite?.size.width)! * y) + x) * numberOfComponents

                        let a = data?[pixelData + 3]
                        if (a < 30) {
                            passed += 1
                        }
                        count += 1
                    
                    x += (coverSprite?.size.width)! / 30
                } while(x < coverSprite?.size.width)
                y += (coverSprite?.size.height)! / 30
            } while(y < (coverSprite?.size.height)!)
            
            if passed / count > 0.98 {
                complete = true
            }
        }
        
        if complete {
            coverSprite?.isHidden = true
            self.showStars((self.photoSprite?.frame)!, starsInRect: false, count: 5, container: self)
            self.playSuccessSound(1.0, onCompletion: {
                let relationship = RelationshipCalculator.getRelationship(self.selectedPerson, p: self.randomMediaChooser.selectedPerson)
                self.showFakeToasts([self.randomMediaChooser.selectedPerson!.name!, relationship])
                
                self.sayGivenName(self.randomMediaChooser.selectedPerson!)
                let waitAction = SKAction.wait(forDuration: 2.5)
                self.run(waitAction, completion: {
                    self.showLoadingDialog()
                    self.randomMediaChooser.loadRandomImage()
                    self.completed = true
                }) 
            })

        }
    }
}
