//
//  ColoringScene.swift
//  Little Family Tree
//
//  Created by Melissa on 12/10/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class ColoringScene: LittleFamilyScene, RandomMediaListener, ColorPaletteListener, BrushSizeListener {
    var randomMediaChooser = RandomMediaChooser.getInstance()
    
	var photoSprite:SKSpriteNode?
	var coverSprite:SKSpriteNode?
	var lastPoint : CGPoint!
    var outlineSprite:SKEffectNode?
    var photoCopySprite:SKSpriteNode?
    var palette : ColorPaletteSprite?
    var brushSizer : BrushSizeSprite?
    var coloring = false
    var nextButton :SKSpriteNode?
    var shareButton :SKSpriteNode?
    
    var image:UIImage?
    var color:UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    var clearColor:UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    var brushSize:CGFloat = 12
    
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
        
        palette = ColorPaletteSprite()
        palette?.size.width = self.size.width * 0.60
        palette?.size.height = self.size.height / 8
        palette?.position = CGPointMake(0, 0)
        palette?.zPosition = 10
        palette?.userInteractionEnabled = true
        palette?.listener = self
        self.addChild(palette!)
        
        let colors = SKSpriteNode(imageNamed: "colors")
        palette?.colorPalette = colors
        
        let paintBrush = SKSpriteNode(imageNamed: "paintbrush")
        palette?.paintbrush = paintBrush
        
        brushSize = self.size.width/16
        brushSizer = BrushSizeSprite()
        brushSizer?.size = CGSizeMake((palette?.size.height)!, (palette?.size.height)!)
        brushSizer?.position = CGPointMake((palette?.size.width)!, 0)
        brushSizer?.zPosition = 10
        brushSizer?.maxSize = brushSize*2
        brushSizer?.minSize = brushSize/8
        brushSizer?.brushSize = brushSize
        brushSizer?.userInteractionEnabled = true
        brushSizer?.listener = self
        self.addChild(brushSizer!)
        
        nextButton = SKSpriteNode(imageNamed: "ff")
        let r1 = (nextButton?.size.width)! / (nextButton?.size.height)!
        let h = (palette?.size.height)! / 3
        nextButton?.size.height = h
        nextButton?.size.width = h * r1
        nextButton?.position = CGPointMake((brushSizer?.position.x)! + (brushSizer?.size.width)! + 15, (palette?.size.height)! - h)
        nextButton?.zPosition = 10
        self.addChild(nextButton!)
        
        shareButton = SKSpriteNode(imageNamed: "ff")
        let r2 = (shareButton?.size.width)! / (shareButton?.size.height)!
        shareButton?.size.height = h
        shareButton?.size.width = h * r2
        shareButton?.position = CGPointMake((brushSizer?.position.x)! + (brushSizer?.size.width)! + 15, (palette?.size.height)! - h)
        shareButton?.zPosition = 10
        self.addChild(shareButton!)
        
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
            var h = self.size.height - ((palette?.size.height)! + (topBar?.size.height)! * 3)
            if ratio < 1.0 || w > h {
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
            if touchedNode == outlineSprite! || touchedNode == photoCopySprite! {
                coloring = true
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var nextPoint = CGPointMake(0,0)
        for touch in touches {
            nextPoint = touch.locationInNode(self)
            if coloring {
                drawLineFrom(lastPoint, toPoint: nextPoint)
            }
        }
        lastPoint = nextPoint
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        for touch in touches {
            lastPoint = touch.locationInNode(self)
            if coloring == false {
                let touchedNode = nodeAtPoint(lastPoint)
                if touchedNode == nextButton {
                    showLoadingDialog()
                    randomMediaChooser.loadRandomImage()
                } else if touchedNode == shareButton {
                    //-- 1 get image from node
                    //-- launch sharing options
                    print("Share me")
                }
            }
        }
        //self.removeAllActions()
        //checkComplete()
        coloring = false
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        UIGraphicsBeginImageContext((coverSprite?.size)!)
        let context = UIGraphicsGetCurrentContext()
        
        let oy = (coverSprite?.position.y)! - (coverSprite?.size.height)!/2
        let ox = (coverSprite?.position.x)! - (coverSprite?.size.width)!/2
        
        image?.drawInRect(CGRect(x: 0, y: 0, width: (coverSprite?.size.width)!, height: (coverSprite?.size.height)!))
        
        CGContextMoveToPoint(context, fromPoint.x - ox, (coverSprite?.size.height)! - (fromPoint.y - oy))
        CGContextAddLineToPoint(context, toPoint.x - ox, (coverSprite?.size.height)! - (toPoint.y - oy))
        
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, brushSize)
        CGContextSetStrokeColorWithColor(context, color.CGColor)
        CGContextSetBlendMode(context, CGBlendMode.Copy)
        CGContextStrokePath(context)
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let coverTexture = SKTexture(image: image!)
        coverSprite?.texture = coverTexture
    }
    
    func onColorChange(color: UIColor) {
        self.color = color
        brushSizer?.brushColor = color
    }
    func onBrushSizeChange(size:CGFloat) {
        self.brushSize = size
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