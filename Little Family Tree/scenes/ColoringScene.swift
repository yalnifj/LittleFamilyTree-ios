//
//  ColoringScene.swift
//  Little Family Tree
//
//  Created by Melissa on 12/10/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit
import Firebase

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
        
        palette = ColorPaletteSprite()
        palette?.size.width = self.size.width * 0.60
        palette?.size.height = self.size.height / 8
        palette?.position = CGPoint(x: 0, y: 0)
        palette?.zPosition = 10
        palette?.isUserInteractionEnabled = true
        palette?.listener = self
        self.addChild(palette!)
        
        let colors = SKSpriteNode(imageNamed: "colors")
        palette?.colorPalette = colors
        
        let paintBrush = SKSpriteNode(imageNamed: "paintbrush")
        palette?.paintbrush = paintBrush
        
        brushSize = min(self.size.width, self.size.height)/16
        brushSizer = BrushSizeSprite()
        brushSizer?.size = CGSize(width: (palette?.size.height)!, height: (palette?.size.height)!)
        brushSizer?.position = CGPoint(x: (palette?.size.width)!, y: 0)
        brushSizer?.zPosition = 10
        brushSizer?.maxSize = min(brushSizer!.size.width, brushSizer!.size.height)
        brushSizer?.minSize = max(brushSize/6, 10)
        brushSizer?.brushSize = brushSize
        brushSizer?.isUserInteractionEnabled = true
        brushSizer?.listener = self
        self.addChild(brushSizer!)
        
        outlineButton = SKSpriteNode(imageNamed: "grandma_outline")
        let r1 = (outlineButton?.size.width)! / (outlineButton?.size.height)!
        let h = (palette?.size.height)! / 2
        outlineButton?.size.height = h
        outlineButton?.size.width = h * r1
        outlineButton?.position = CGPoint(x: (brushSizer?.position.x)! + (brushSizer?.size.width)! + 20, y: (palette?.size.height)! - h)
        outlineButton?.zPosition = 10
        self.addChild(outlineButton!)

        
        nextButton = EventSprite(imageNamed: "ff")
        let r3 = (nextButton?.size.width)! / (nextButton?.size.height)!
        let h2 = (palette?.size.height)! / 3
        nextButton?.size.height = h2
        nextButton?.size.width = h2 * r3
        nextButton?.position = CGPoint(x: (brushSizer?.position.x)! + (brushSizer?.size.width)! + 20, y: (palette?.size.height)! - h2)
        nextButton?.zPosition = 10
        nextButton?.topic = ColoringScene.TOPIC_NEXT_IMAGE
        topBar!.addCustomSprite(nextButton!)
        //self.addChild(nextButton!)
        
        shareButton = EventSprite(imageNamed: "camera")
        let r2 = (shareButton?.size.width)! / (shareButton?.size.height)!
        shareButton?.size.height = h2
        shareButton?.size.width = h2 * r2
        shareButton?.position = CGPoint(x: (brushSizer?.position.x)! + (brushSizer?.size.width)! + 20, y: h2)
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
        
        FIRAnalytics.logEvent(withName: kFIREventViewItem, parameters: [
            kFIRParameterItemName: String(describing: ColoringScene.self) as NSObject
        ])
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        EventHandler.getInstance().unSubscribe(ColoringScene.TOPIC_NEXT_IMAGE, listener: self)
        EventHandler.getInstance().unSubscribe(ColoringScene.TOPIC_SHARE_IMAGE, listener: self)
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
    
    func onMediaLoaded(_ media:Media?) {
        if media == nil {
            if randomMediaChooser.counter < randomMediaChooser.maxTries {
                randomMediaChooser.loadMoreFamilyMembers()
                return
            } else {
                //dispatch_async(dispatch_get_main_queue()) {
                    self.hideLoadingDialog()
                    self.showSimpleDialog("No Pictures Found", message: "There are not many pictures in your family tree. This activity requires pictures. Please add more pictures to your online family tree.")
                //}
                return
            }
        }
        
        if showOutline == false {
            toggleOutline()
        }
        
        let texture = TextureHelper.getTextureForMedia(media!, size: CGSize(width: self.size.width * 0.66, height: self.size.height * 0.66))
        if texture != nil {
            DispatchQueue.main.async(execute: {
            if self.fullImageHolder != nil {
                self.fullImageHolder?.removeAllChildren()
                self.fullImageHolder?.removeFromParent()
            }
            
            let ratio = (texture?.size().width)! / (texture?.size().height)!
            var w = self.size.width
            var h = self.size.height - ((self.palette?.size.height)! + (self.topBar?.size.height)! * 3)
            if ratio < 1.0 || w > h {
                w = h * ratio
            } else {
                h = w / ratio
            }
            
            let ypos = (self.size.height / 2) + (self.palette?.size.height)! / 2 - (self.topBar?.size.height)! / 2
			
			self.fullImageHolder = SKSpriteNode()
			self.fullImageHolder?.zPosition = 2
			self.fullImageHolder?.position = CGPoint(x: self.size.width / 2, y: ypos)
			self.fullImageHolder?.size.width = w
			self.fullImageHolder?.size.height = h
			self.addChild(self.fullImageHolder!)
            
            self.photoSprite = SKSpriteNode(texture: texture, size: CGSize(width: w, height: h))
            self.photoSprite?.zPosition = 2
            self.photoSprite?.position = CGPoint(x: 0, y: 0)
            self.photoSprite?.size.width = w
            self.photoSprite?.size.height = h
            self.fullImageHolder!.addChild(self.photoSprite!)
            
            let rect = CGRect(x: 0, y: 0, width: (self.photoSprite?.size.width)!, height: (self.photoSprite?.size.height)!)
            UIGraphicsBeginImageContextWithOptions((self.photoSprite?.size)!, false, 0)
            let color = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            color.setFill()
            UIRectFill(rect)
            self.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let coverTexture = SKTexture(image: self.image!)
            self.coverSprite = SKSpriteNode(texture: coverTexture)
            self.coverSprite?.zPosition = 3
            self.coverSprite?.position = CGPoint(x: 0, y: 0)
            self.coverSprite?.size.width = w
            self.coverSprite?.size.height = h
            self.fullImageHolder!.addChild(self.coverSprite!)

            let filter:CIFilter? = CIFilter(name: "CILineOverlay")!
            let os = SKEffectNode()
            os.zPosition = 4
            os.position = CGPoint(x: 0, y: 0)
            os.filter = filter
            
            let smalltexture = TextureHelper.getTextureForMedia(media!, size: CGSize(width: self.size.width/2, height: self.size.height/2))
            if smalltexture != nil {
                self.photoCopySprite = SKSpriteNode(texture: smalltexture, size: CGSize(width: w, height: h))
                self.photoCopySprite?.zPosition = 2
                self.photoCopySprite?.position = CGPoint(x: 0, y: 0)
                self.photoCopySprite?.size.width = w
                self.photoCopySprite?.size.height = h
                os.addChild(self.photoCopySprite!)
            
                let imageTexture = self.scene!.view!.texture(from: os)
                if imageTexture != nil {
                    self.outlineSprite = SKSpriteNode(texture: imageTexture)
                    self.outlineSprite!.zPosition = 4
                    self.outlineSprite!.position = CGPoint(x: 0, y: 0)
                    self.outlineSprite?.isHidden = !self.showOutline
                    self.fullImageHolder!.addChild(self.outlineSprite!)
                }
            }
            
            self.hideLoadingDialog()
            
            self.userHasPremium({ premium in
                if !premium {
                    var tryCount = self.getTryCount("try_coloring_count")
                    tryCount = 0
                    var tryAvailable = true
                    if tryCount > 3 {
                        tryAvailable = false
                    }
                    
                    self.showLockDialog(tryAvailable,  tries: LittleFamilyScene.FREE_TRIES - (tryCount - 1))
                }
            })
            })
            
        } else {
            randomMediaChooser.loadMoreFamilyMembers()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        for touch in touches {
            lastPoint = touch.location(in: self)
            let touchedNode = atPoint(lastPoint)
            if (outlineSprite != nil && touchedNode == outlineSprite!) || (coverSprite != nil && touchedNode == coverSprite!) {
                coloring = true
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        var nextPoint = CGPoint(x: 0,y: 0)
        for touch in touches {
            nextPoint = touch.location(in: self)
            if coloring {
                drawLineFrom(lastPoint, toPoint: nextPoint)
            }
        }
        lastPoint = nextPoint
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch in touches {
            lastPoint = touch.location(in: self)
            if coloring == false {
                let touchedNode = atPoint(lastPoint)
                if touchedNode == outlineButton {
                    toggleOutline()
                }
            }
        }
        //self.removeAllActions()
        //checkComplete()
        coloring = false
    }
    
    override func onEvent(_ topic: String, data: NSObject?) {
        super.onEvent(topic, data: data)
        if topic == ColoringScene.TOPIC_NEXT_IMAGE {
            showLoadingDialog()
            randomMediaChooser.loadRandomImage()
        } else if topic == ColoringScene.TOPIC_SHARE_IMAGE {
            //-- 1 get image from node
            //-- launch sharing options
            print("Share me")
            showParentAuth()
        } else if topic == LittleFamilyScene.TOPIC_TRY_PRESSED {
            let tryCount = getTryCount("try_coloring_count")
            DataService.getInstance().dbHelper.saveProperty("try_coloring_count", value: "\(tryCount)")
        }
    }
    
    func drawLineFrom(_ fromPoint: CGPoint, toPoint: CGPoint) {
        if fullImageHolder == nil || photoSprite == nil || coverSprite == nil {
            return
        }
        
        UIGraphicsBeginImageContext((image?.size)!)
        let context = UIGraphicsGetCurrentContext()
        
        let oy = (fullImageHolder?.position.y)! - (fullImageHolder?.size.height)!/2
        let ox = (fullImageHolder?.position.x)! - (fullImageHolder?.size.width)!/2
        
        image?.draw(in: CGRect(x: 0, y: 0, width: (image?.size.width)!, height: (image?.size.height)!))
        
        //CGContextMoveToPoint(context, 0, 0)
        //CGContextAddLineToPoint(context, 0, 50)
        
        context!.move(to: CGPoint(x: fromPoint.x - ox, y: (photoSprite?.size.height)! - (fromPoint.y - oy)))
        context!.addLine(to: CGPoint(x: toPoint.x - ox, y: (photoSprite?.size.height)! - (toPoint.y - oy)))
        
        context!.setLineCap(CGLineCap.round)
        context!.setLineWidth(brushSize)
        context!.setStrokeColor(color.cgColor)
        context!.setBlendMode(CGBlendMode.copy)
        context!.strokePath()
        
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
                outlineSprite?.isHidden = false
            }
        } else {
            outlineButton?.texture = SKTexture(imageNamed: "grandma")
            if outlineSprite != nil {
                outlineSprite?.isHidden = true
            }
        }
    }
    
    func onColorChange(_ color: UIColor) {
        self.color = color
        brushSizer?.brushColor = color
    }
    func onBrushSizeChange(_ size:CGFloat) {
        self.brushSize = size
    }
    
    func showParentAuth() {
		let remember = DataService.getInstance().dbHelper.getProperty(DataService.PROPERTY_REMEMBER_ME)
		if remember != nil {
			let time = Double(remember!)
			let date = Foundation.Date(timeIntervalSince1970: time!)
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
            logoMark?.anchorPoint = CGPoint.zero
            logoMark?.position = CGPoint(x: w / -2, y: h / -2)
            if w > h {
                logoMark?.size.width = h * CGFloat(0.4) / lr
                logoMark?.size.height = h * CGFloat(0.4)
            } else {
                logoMark?.size.width = w * CGFloat(0.4)
                logoMark?.size.height = w * CGFloat(0.4) * lr
            }
            fullImageHolder!.addChild(logoMark!)
            
			let imageTexture = self.scene!.view!.texture(from: fullImageHolder!)
			let image = UIImage(cgImage: imageTexture!.cgImage())
            logoMark?.removeFromParent()
            
			activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            if let wPPC = activityViewController!.popoverPresentationController {
                wPPC.sourceView = self.view!
                wPPC.sourceRect = CGRect(x: self.size.width/4, y: self.size.height/2, width: self.size.width/2, height: self.size.height/2)
            }
			self.view!.window!.rootViewController!.present(activityViewController!, animated: true, completion: nil)
		}
	}
}
