//
//  DressUpScene.swift
//  Little Family Tree
//
//  Created by Melissa on 12/5/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit
import GPUImage
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

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
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

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


class DressUpScene: LittleFamilyScene, ChooseSkinToneListener {
    static var TOPIC_CHANGE_SKIN = "topic_change_skin"
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
    var skinButton : EventSprite?
    var skinTone : String = "light"
    var boygirl : String = "boy"
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.size.width = view.bounds.width
        self.size.height = view.bounds.height
        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        snapTolerance = self.size.width / 25
        
        let background = SKSpriteNode(imageNamed: "dressup_background")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.size.width = self.size.width
        background.size.height = self.size.height
        background.zPosition = 0
        self.addChild(background)
        
        setupTopBar()
        
        let defaultSkinTone = DataService.getInstance().dbHelper.getProperty(DataService.PROPERTY_SKIN_TONE)
        if defaultSkinTone != nil {
            skinTone = defaultSkinTone!
        }
        skinButton = EventSprite(imageNamed: "boy")
        skinButton?.zPosition = 10
        skinButton?.topic = DressUpScene.TOPIC_CHANGE_SKIN
        topBar!.addCustomSprite(skinButton!)
        self.updateSkinColor(skinTone)
        
        boygirl = "boy"
        if (selectedPerson!.gender == GenderType.female) {
            boygirl = "girl"
        }

        scale = CGFloat(1.0)
        if skinTone == "light" {
            doll = SKSpriteNode(imageNamed: "dolls/\(boygirl)doll")
        }
        else {
            doll = SKSpriteNode(imageNamed: "dolls/\(boygirl)doll_\(skinTone)")
        }
        doll?.zPosition = 2
        scale = (self.size.height * 0.6) / (doll?.size.height)!
        doll?.setScale(scale)
        doll?.position = CGPoint(x: self.size.width/2, y: self.size.height - (10 + (topBar?.size.height)! + (doll?.size.height)! / 2))
        self.addChild(doll!)
        
        setupSprites()
        
        var places = dolls.getDollPlaces()
        let color = UIColor(colorLiteralRed: 0.8, green: 0.8, blue: 0.8, alpha: 0.3)
        let height = (countryLabel?.position.y)! - 10
        dollHolder = SKSpriteNode(color: color, size: CGSize(width: CGFloat(places.count+1) * (5 + height * 0.7), height: height))
        dollHolder?.position = CGPoint(x: (dollHolder?.size.width)!/2, y: (dollHolder?.size.height)! / 2)
        dollHolder?.zPosition = 2
        dollHolder?.isHidden = true
        self.addChild(dollHolder!)
        
        places.sort()
        var dx = ((dollHolder?.size.height)! * 0.3) + CGFloat(-1 * (dollHolder?.size.width)! / 2)
        for place in places {
            let dc = dolls.getDollConfig(place, person: selectedPerson!)
            let thumb = SKSpriteNode(imageNamed: dc.getThumbnail())
            thumb.position = CGPoint(x: dx, y: 14)
            let ratio = (thumb.texture?.size().width)! / (thumb.texture?.size().height)!
            thumb.size.height = (dollHolder?.size.height)! * 0.7
            thumb.size.width = thumb.size.height * ratio
            dollHolder?.addChild(thumb)
            thumbSpriteMap[thumb] = place
            
            let pl = SKLabelNode(text: dc.originalPlace)
            pl.fontSize = thumb.size.height / 7
            pl.fontColor = UIColor.black
            pl.position = CGPoint(x: dx, y: thumb.size.height * -0.6)
            dollHolder?.addChild(pl)
            thumbSpriteMap[pl] = place
            
            dx = dx + thumb.size.height + 10
        }
        
        EventHandler.getInstance().subscribe(DressUpScene.TOPIC_CHANGE_SKIN, listener: self)
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        EventHandler.getInstance().unSubscribe(DressUpScene.TOPIC_CHANGE_SKIN, listener: self)
    }
    
    func updateSkinColor(_ skinTone:String) {
        let texture = TextureHelper.getDefaultPortraitTexture(selectedPerson!, skinTone: skinTone)
        skinButton?.texture = texture
    }
    
    func setupSprites() {
        if countryLabel != nil {
            countryLabel?.removeFromParent()
        }
        countryLabel = SKLabelNode(text: dollConfig?.originalPlace!)
        countryLabel?.fontSize = (topBar?.size.height)!
        countryLabel?.fontColor = UIColor.black
        countryLabel?.position = CGPoint(x: self.size.width / 2, y: (doll?.position.y)! - ((countryLabel?.fontSize)! + (doll?.size.height)! / 2))
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
        
        let alphaMaskFilter = GPUImageFilter(fragmentShaderFromFile: "alphaMaskShader")
        //let sobelFilter = GPUImageSobelEdgeDetectionFilter()
        let sobelFilter = GPUImageAlphaSobelEdgeDetectionFilter(fragmentShaderFromFile: "sobelAlphaShader")
        let groupFilter = GPUImageFilterGroup()
        groupFilter.addFilter(alphaMaskFilter)
        groupFilter.addFilter(sobelFilter)
        alphaMaskFilter?.addTarget(sobelFilter)
        groupFilter.initialFilters = [ alphaMaskFilter ]
        groupFilter.terminalFilter = sobelFilter
        
        clothing = dollConfig?.getClothing()
        if clothing != nil {
            var x = CGFloat(0)
            var y = CGFloat(10)
            var z = doll!.zPosition + 1
            for cloth in clothing! {
                let clothSprite = SKSpriteNode(imageNamed: cloth.filename)
                clothSprite.zPosition = z
                z = z + 1
                clothSprite.setScale(scale)
                if x > self.size.width - clothSprite.size.width/2 {
                    x = CGFloat(0)
                    y = y + clothSprite.size.height
                }
                if x == 0 {
                    x = 10 + clothSprite.size.width / 2
                }
                clothSprite.position = CGPoint(x: x, y: y + clothSprite.size.height / 2)
                self.addChild(clothSprite)
                x = x + clothSprite.size.width + 20
                clotheSprites.append(clothSprite)
                clothingMap[clothSprite] = cloth
                
                let outlineImage = UIImage(named: cloth.filename)
                print("outlineImage size: \(outlineImage!.size)")
                let outputImage = groupFilter.image(byFilteringImage: outlineImage!)
                //let outputImage = alphaMaskFilter.imageByFilteringImage(outlineImage!)
                let outlineTexture = SKTexture(image: outputImage!)
                
                let outlineSprite = SKSpriteNode(texture: outlineTexture)
                outlineSprite.zPosition = (doll?.zPosition)! + 1
                outlineSprite.setScale(scale)
                outlineSprite.position = getSnap(cloth, sprite:clothSprite)
                outlineSprite.isHidden = true
                self.addChild(outlineSprite)
                outlines[clothSprite] = outlineSprite
            }
        }
    }
    
    func getSnap(_ clothing:DollClothing, sprite:SKSpriteNode) -> CGPoint {
        let offsetX = (self.size.width - (doll?.size.width)!) / 2
        let snapX = offsetX + scale * CGFloat(clothing.snapX) + sprite.size.width / 2
        let cgSnapY = scale * CGFloat(clothing.snapY)
        let h2 = sprite.size.height / 2
        let top = (doll?.position.y)! + (1 * (doll?.size.height)!/2)
        let snapY = top - (cgSnapY + h2)
        let snap = CGPoint(x: snapX, y: snapY)
        return snap
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        movingSprite = nil
        for touch in touches {
            lastPoint = touch.location(in: self)
            let touchedNode = atPoint(lastPoint)
            if touchedNode is SKSpriteNode {
                let clothSprite = touchedNode as! SKSpriteNode
                if clothingMap[clothSprite] != nil {
                    movingSprite = clothSprite
                    let outlineSprite = outlines[clothSprite]
                    if outlineSprite != nil {
                        outlineSprite?.isHidden = false
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
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        var nextPoint = CGPoint(x: 0,y: 0)
        for touch in touches {
            nextPoint = touch.location(in: self)
            if movingSprite != nil {
                let dx = lastPoint.x - nextPoint.x
                let dy = lastPoint.y - nextPoint.y
                movingSprite?.position.x -= dx
                movingSprite?.position.y -= dy
            }
            if scrollingDolls {
                let dx = lastPoint.x - nextPoint.x
                if abs(dx) > 8 {
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
        }
        lastPoint = nextPoint
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
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
                outlineSprite?.isHidden = true
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
                self.showStars(CGRect(x: (self.doll?.position.x)! / 2, y: (self.doll?.position.y)! / 2, width: (self.doll?.size.width)!, height: (self.doll?.size.height)!), starsInRect: true, count: Int((self.doll?.size.width)!) / 25, container: nil)
                self.playSuccessSound(0.5, onCompletion: { () in
                    self.dollHolder?.isHidden = false
                })
            } else {
                dollHolder?.isHidden = true
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
                lastPoint = touch.location(in: self)
                let touchedNode = atPoint(lastPoint)
                if thumbSpriteMap[touchedNode] != nil {
                    let place = thumbSpriteMap[touchedNode]
                    self.dollConfig = self.dolls.getDollConfig(place, person: self.selectedPerson!)
                    self.setupSprites()
                    self.dollHolder?.isHidden = true
                }
            }
        }
        scrollingDolls = false
        scrolling = false
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
    }
    
    override func onEvent(_ topic: String, data: NSObject?) {
        super.onEvent(topic, data: data)
        if topic == DressUpScene.TOPIC_CHANGE_SKIN {
            let frame = prepareDialogRect(300, height: 400)
            let subview = ChooseSkinToneView(frame: frame)
            subview.selectedPerson = selectedPerson
            subview.listener = self
            self.view?.addSubview(subview)

        }
    }
    
    func onSelected(skinTone:String) {
        clearDialogRect()
        self.skinTone = skinTone
        if skinTone == "light" {
            doll?.texture = SKTexture(imageNamed: "dolls/\(boygirl)doll")
        }
        else {
            doll?.texture = SKTexture(imageNamed: "dolls/\(boygirl)doll_\(skinTone)")
        }
        self.updateSkinColor(skinTone)
    }
    
    func cancelled() {
        clearDialogRect()
    }
}

class GPUImageAlphaSobelEdgeDetectionFilter : GPUImageSobelEdgeDetectionFilter {
    override init!(fragmentShaderFromFile fragmentShaderFilename: String!) {
        let fragmentShaderPathname = Bundle.main.path(forResource: fragmentShaderFilename, ofType: "fsh")
        //let fragmentShaderPathname = [[NSBundle mainBundle] pathForResource:fragmentShaderFilename ofType:@"fsh"];
        let shaderString = try! NSString(contentsOfFile: fragmentShaderPathname!, encoding: String.Encoding.utf8.rawValue)
        super.init(fragmentShaderFrom: shaderString as String)
    }
}
