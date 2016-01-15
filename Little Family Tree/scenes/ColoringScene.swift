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
    
	var fullImageHolder:SKSpriteNode?
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
        nextButton?.position = CGPointMake((brushSizer?.position.x)! + (brushSizer?.size.width)! + 20, (palette?.size.height)! - h)
        nextButton?.zPosition = 10
        self.addChild(nextButton!)
        
        shareButton = SKSpriteNode(imageNamed: "camera")
        let r2 = (shareButton?.size.width)! / (shareButton?.size.height)!
        shareButton?.size.height = h
        shareButton?.size.width = h * r2
        shareButton?.position = CGPointMake((brushSizer?.position.x)! + (brushSizer?.size.width)! + 20, h)
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
            if outlineSprite != nil {
                outlineSprite?.removeFromParent()
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
			
			fullImageHolder = SKSpriteNode()
			fullImageHolder?.zPosition = 2
			fullImageHolder?.position = CGPointMake(self.size.width / 2, ypos)
			fullImageHolder?.size.width = w
			fullImageHolder?.size.height = h
			self.addChild(fullImageHolder!)
            
            photoSprite = SKSpriteNode(texture: texture, size: CGSizeMake(w, h))
            photoSprite?.zPosition = 2
            photoSprite?.position = CGPointMake(0, 0)
            photoSprite?.size.width = w
            photoSprite?.size.height = h
            fullImageHolder!.addChild(photoSprite!)
            
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
            coverSprite?.position = CGPointMake(0, 0)
            coverSprite?.size.width = w
            coverSprite?.size.height = h
            fullImageHolder!.addChild(coverSprite!)

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
            outlineSprite?.position = CGPointMake(0, 0)
            outlineSprite?.filter = filter
            fullImageHolder!.addChild(outlineSprite!)
            
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
					showSharingPanel()
                }
            }
        }
        //self.removeAllActions()
        //checkComplete()
        coloring = false
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
	
	func showSharingPanel() {
		if (fullImageHolder != nil) {
			let imageTexture = self.scene!.view!.textureFromNode(fullImageHolder!)
			let image = UIImage(CGImage: imageTexture!.CGImage())
			let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
			self.view!.window!.rootViewController!.presentViewController(activityViewController, animated: true, completion: nil)
		}
	}
}
