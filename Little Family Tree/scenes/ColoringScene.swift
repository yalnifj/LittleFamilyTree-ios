//
//  ColoringScene.swift
//  Little Family Tree
//
//  Created by Melissa on 12/10/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class ColoringScene: LittleFamilyScene, RandomMediaListener {
    var randomMediaChooser = RandomMediaChooser.getInstance()
    
	var photoSprite:SKSpriteNode?
	var coverSprite:SKSpriteNode?
	var lastPoint : CGPoint!
    var outlineSprite:SKEffectNode?
    var photoCopySprite:SKSpriteNode?
    var palette : SKSpriteNode?
    
    var image:UIImage?
    
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
            
            palette = SKSpriteNode(imageNamed: "colors")
            let cratio = (palette?.size.height)! / (palette?.size.width)!
            palette?.size.width = self.size.width / 2
            palette?.size.height = (palette?.size.width)! * cratio
            palette?.position = CGPointMake((palette?.size.width)! / 2, (palette?.size.height)! / 2)
            palette?.zPosition = 10
            self.addChild(palette!)
            
            let ratio = (texture?.size().width)! / (texture?.size().height)!
            var w = self.size.width
            var h = self.size.height - ((palette?.size.height)! + (topBar?.size.height)! * 3)
            if ratio < 1.0 {
                w = h * ratio
            } else {
                h = w / ratio
            }
            
            let ypos = (self.size.height / 2) + (palette?.size.height)! / 2 - (topBar?.size.height)! / 2
            
            photoSprite = SKSpriteNode(texture: texture, size: CGSizeMake(w, h))
            photoSprite?.zPosition = 2
            photoSprite?.position = CGPointMake(self.size.width / 2, ypos)
            photoSprite?.size.width = w
            photoSprite?.size.height = h
            self.addChild(photoSprite!)
            
            let rect = CGRectMake(0, 0, (photoSprite?.size.width)!, (photoSprite?.size.height)!)
            UIGraphicsBeginImageContextWithOptions((photoSprite?.size)!, false, 0)
            let color = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
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

            var filter:CIFilter? = nil
            let os = NSProcessInfo().operatingSystemVersion
            switch(os.majorVersion) {
                case 9:
                    filter = CIFilter(name: "CILineOverlay")!
                break
                default:
                    filter = EdgeMaskFilter()
                break
            }
            outlineSprite = SKEffectNode()
            outlineSprite?.zPosition = 4
            outlineSprite?.position = CGPointMake(self.size.width / 2, ypos)
            outlineSprite?.filter = filter
            self.addChild(outlineSprite!)
            
            let smalltexture = TextureHelper.getTextureForMedia(media!, size: CGSizeMake(self.size.width/2, self.size.height/2))
            photoCopySprite = SKSpriteNode(texture: smalltexture, size: CGSizeMake(w, h))
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

class EdgeMaskFilter: CIFilter {
    var edgeFilter:CIFilter?
    var maskFilter:MaskFilter?
    var inputImage: CIImage?
    
    override init() {
        super.init()
        edgeFilter = CIFilter(name: "CIEdgeWork")!
        maskFilter = MaskFilter()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        edgeFilter = CIFilter(name: "CIEdgeWork")!
        maskFilter = MaskFilter()    }
    
    override var outputImage : CIImage! {
        if let inputImage = inputImage {
            edgeFilter?.setValue(inputImage, forKey: "inputImage")
            maskFilter?.inputImage = edgeFilter?.outputImage
            return maskFilter?.outputImage
        }
        return nil
    }
}

class MaskFilter : CIFilter {
    var kernel: CIColorKernel?
    var inputImage: CIImage?
    
    override init() {
        super.init()
        kernel = createKernel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        kernel = createKernel()
    }
    
    override var outputImage : CIImage! {
        if let inputImage = inputImage,
            let kernel = kernel {
                let dod = inputImage.extent
                let args = [inputImage as AnyObject]
                return kernel.applyWithExtent(dod, arguments: args)
        }
        return nil
    }
    
    private func createKernel() -> CIColorKernel {
        let kernelString =
        "kernel vec4 maskFilterKernel(sampler src) {\n" +
        "    vec4 t = sample(src, destCoord());\n" +
        "    t.w = (t.x >= 0.90 ? (t.y >= 0.90 ? (t.z >= 0.90 ? 0.0 : 1.0) : 1.0) : 1.0);\n" +
        "    return t;\n" +
        "}"
        return CIColorKernel(string: kernelString)!
    }
}