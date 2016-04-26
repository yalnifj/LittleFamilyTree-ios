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
    static var TOPIC_NEXT_IMAGE = "nextImage"
    static var TOPIC_SHARE_IMAGE = "shareImage"
    
    var randomMediaChooser = RandomMediaChooser.getInstance()
    
	var fullImageHolder:SKSpriteNode?
	var photoSprite:SKSpriteNode?
	var coverSprite:SKSpriteNode?
	var lastPoint : CGPoint!
    var outlineSprite:SKSpriteNode?
    var photoCopySprite:SKSpriteNode?
    var palette : ColorPaletteSprite?
    var brushSizer : BrushSizeSprite?
    var coloring = false
    var nextButton :EventSprite?
    var shareButton :EventSprite?
    var outlineButton : SKSpriteNode?
    var logoMark: SKSpriteNode?
    
    var image:UIImage?
    var color:UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    var clearColor:UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    var brushSize:CGFloat = 12
    var activityViewController:UIActivityViewController?
    
    var showOutline = true
    
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
        
        brushSize = min(self.size.width, self.size.height)/16
        brushSizer = BrushSizeSprite()
        brushSizer?.size = CGSizeMake((palette?.size.height)!, (palette?.size.height)!)
        brushSizer?.position = CGPointMake((palette?.size.width)!, 0)
        brushSizer?.zPosition = 10
        brushSizer?.maxSize = min(brushSizer!.size.width, brushSizer!.size.height)
        brushSizer?.minSize = max(brushSize/6, 10)
        brushSizer?.brushSize = brushSize
        brushSizer?.userInteractionEnabled = true
        brushSizer?.listener = self
        self.addChild(brushSizer!)
        
        outlineButton = SKSpriteNode(imageNamed: "grandma_outline")
        let r1 = (outlineButton?.size.width)! / (outlineButton?.size.height)!
        let h = (palette?.size.height)! / 2
        outlineButton?.size.height = h
        outlineButton?.size.width = h * r1
        outlineButton?.position = CGPointMake((brushSizer?.position.x)! + (brushSizer?.size.width)! + 20, (palette?.size.height)! - h)
        outlineButton?.zPosition = 10
        self.addChild(outlineButton!)

        
        nextButton = EventSprite(imageNamed: "ff")
        let r3 = (nextButton?.size.width)! / (nextButton?.size.height)!
        let h2 = (palette?.size.height)! / 3
        nextButton?.size.height = h2
        nextButton?.size.width = h2 * r3
        nextButton?.position = CGPointMake((brushSizer?.position.x)! + (brushSizer?.size.width)! + 20, (palette?.size.height)! - h2)
        nextButton?.zPosition = 10
        nextButton?.topic = ColoringScene.TOPIC_NEXT_IMAGE
        topBar!.addCustomSprite(nextButton!)
        //self.addChild(nextButton!)
        
        shareButton = EventSprite(imageNamed: "camera")
        let r2 = (shareButton?.size.width)! / (shareButton?.size.height)!
        shareButton?.size.height = h2
        shareButton?.size.width = h2 * r2
        shareButton?.position = CGPointMake((brushSizer?.position.x)! + (brushSizer?.size.width)! + 20, h2)
        shareButton?.zPosition = 10
        shareButton?.topic = ColoringScene.TOPIC_SHARE_IMAGE
        //self.addChild(shareButton!)
        topBar!.addCustomSprite(shareButton!)
        
        showLoadingDialog()
        
        randomMediaChooser.listener = self
        randomMediaChooser.addPeople([selectedPerson!])
        randomMediaChooser.loadMoreFamilyMembers()
        
        EventHandler.getInstance().subscribe(ColoringScene.TOPIC_NEXT_IMAGE, listener: self)
        EventHandler.getInstance().subscribe(ColoringScene.TOPIC_SHARE_IMAGE, listener: self)
    }
    
    override func willMoveFromView(view: SKView) {
        super.willMoveFromView(view)
        EventHandler.getInstance().unSubscribe(ColoringScene.TOPIC_NEXT_IMAGE, listener: self)
        EventHandler.getInstance().unSubscribe(ColoringScene.TOPIC_SHARE_IMAGE, listener: self)
    }
    
    override func update(currentTime: NSTimeInterval) {
        
    }
    
    func onMediaLoaded(media:Media?) {
        if media == nil {
            randomMediaChooser.loadMoreFamilyMembers()
            return
        }
        
        if showOutline == false {
            toggleOutline()
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

            let filter:CIFilter? = CIFilter(name: "CILineOverlay")!
            let os = SKEffectNode()
            os.zPosition = 4
            os.position = CGPointMake(0, 0)
            os.filter = filter
            
            let smalltexture = TextureHelper.getTextureForMedia(media!, size: CGSizeMake(self.size.width/2, self.size.height/2))
            if smalltexture != nil {
                photoCopySprite = SKSpriteNode(texture: smalltexture, size: CGSizeMake(w, h))
                photoCopySprite?.zPosition = 2
                photoCopySprite?.position = CGPointMake(0, 0)
                photoCopySprite?.size.width = w
                photoCopySprite?.size.height = h
                os.addChild(photoCopySprite!)
            
                let imageTexture = self.scene!.view!.textureFromNode(os)
                if imageTexture != nil {
                    outlineSprite = SKSpriteNode(texture: imageTexture)
                    outlineSprite!.zPosition = 4
                    outlineSprite!.position = CGPointMake(0, 0)
                    outlineSprite?.hidden = !showOutline
                    fullImageHolder!.addChild(outlineSprite!)
                }
            }
            
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
            if (outlineSprite != nil && touchedNode == outlineSprite!) || (coverSprite != nil && touchedNode == coverSprite!) {
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
                if touchedNode == outlineButton {
                    toggleOutline()
                }
            }
        }
        //self.removeAllActions()
        //checkComplete()
        coloring = false
    }
    
    override func onEvent(topic: String, data: NSObject?) {
        super.onEvent(topic, data: data)
        if topic == ColoringScene.TOPIC_NEXT_IMAGE {
            showLoadingDialog()
            randomMediaChooser.loadRandomImage()
        } else if topic == ColoringScene.TOPIC_SHARE_IMAGE {
            //-- 1 get image from node
            //-- launch sharing options
            print("Share me")
            showParentAuth()
        }
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        if fullImageHolder == nil || photoSprite == nil || coverSprite == nil {
            return
        }
        
        UIGraphicsBeginImageContext((image?.size)!)
        let context = UIGraphicsGetCurrentContext()
        
        let oy = (fullImageHolder?.position.y)! - (fullImageHolder?.size.height)!/2
        let ox = (fullImageHolder?.position.x)! - (fullImageHolder?.size.width)!/2
        
        image?.drawInRect(CGRect(x: 0, y: 0, width: (image?.size.width)!, height: (image?.size.height)!))
        
        //CGContextMoveToPoint(context, 0, 0)
        //CGContextAddLineToPoint(context, 0, 50)
        
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
    
    func toggleOutline() {
        showOutline = !showOutline
        if showOutline {
            outlineButton?.texture = SKTexture(imageNamed: "grandma_outline")
            if outlineSprite != nil {
                outlineSprite?.hidden = false
            }
        } else {
            outlineButton?.texture = SKTexture(imageNamed: "grandma")
            if outlineSprite != nil {
                outlineSprite?.hidden = true
            }
        }
    }
    
    func onColorChange(color: UIColor) {
        self.color = color
        brushSizer?.brushColor = color
    }
    func onBrushSizeChange(size:CGFloat) {
        self.brushSize = size
    }
    
    func showParentAuth() {
		let remember = DataService.getInstance().dbHelper.getProperty(DataService.PROPERTY_REMEMBER_ME)
		if remember != nil {
			let time = Double(remember!)
			let date = NSDate(timeIntervalSince1970: time)
			if date.timeIntervalSinceNow > -60 * 20 {
				showSharingPanel()
				return
			}
		}
        let frame = CGRect(x: self.size.width/2 - 150, y: self.size.height/2 - 200, width: 300, height: 400)
        let subview = ParentLogin(frame: frame)
        class ShareLoginListener : LoginCompleteListener {
            var scene:ColoringScene
            init(scene:ColoringScene) {
                self.scene = scene
            }
            func LoginComplete() {
                scene.showSharingPanel()
            }
            func LoginCanceled() {
                
            }
        }
        subview.loginListener = ShareLoginListener(scene: self)
        self.view?.addSubview(subview)
        self.speak("Ask an adult for help.")
    }
	
	func showSharingPanel() {
		if (fullImageHolder != nil) {
            let ratio = (photoSprite?.texture?.size().width)! / (photoSprite?.texture?.size().height)!
            var w = self.size.width
            var h = self.size.height - ((palette?.size.height)! + (topBar?.size.height)! * 3)
            if ratio < 1.0 || w > h {
                w = h * ratio
            } else {
                h = w / ratio
            }

            logoMark = SKSpriteNode(imageNamed: "logo")
            let lr = logoMark!.size.height / logoMark!.size.width
            logoMark?.zPosition = 10
            logoMark?.anchorPoint = CGPointZero
            logoMark?.position = CGPointMake(w / -2, h / -2)
            if w > h {
                logoMark?.size.width = h * CGFloat(0.4) / lr
                logoMark?.size.height = h * CGFloat(0.4)
            } else {
                logoMark?.size.width = w * CGFloat(0.4)
                logoMark?.size.height = w * CGFloat(0.4) * lr
            }
            fullImageHolder!.addChild(logoMark!)
            
			let imageTexture = self.scene!.view!.textureFromNode(fullImageHolder!)
			let image = UIImage(CGImage: imageTexture!.CGImage())
            logoMark?.removeFromParent()
            
			activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            if let wPPC = activityViewController!.popoverPresentationController {
                wPPC.sourceView = self.view!
                wPPC.sourceRect = CGRect(x: self.size.width/4, y: self.size.height/2, width: self.size.width/2, height: self.size.height/2)
            }
			self.view!.window!.rootViewController!.presentViewController(activityViewController!, animated: true, completion: nil)
		}
	}
}
