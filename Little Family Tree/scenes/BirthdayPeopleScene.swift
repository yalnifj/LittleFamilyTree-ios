//
//  BirthdayPeopleScene
//  Little Family Tree
//
//  Created by Melissa on 12/5/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit
import GPUImage

class BirthdayPeopleScene: LittleFamilyScene {
	static var TOPIC_PERSON_TOUCHED = "personTouched"
    static var TOPIC_BIRTHDAY_PERSON_SELECTED = "birthdayPersonSelected"
    static var TOPIC_CARD_SELECTED = "cardSelected"
	static var TOPIC_SHARE_IMAGE = "shareImage"
	static var TOPIC_SHOW_CUPCAKES = "showCupcakes"
	
    var lastPoint : CGPoint!
    var portrait = true
    var vanityTop:SKSpriteNode?
    var vanityBottom:SKSpriteNode?
    var peopleSprites = [SKSpriteNode]()
	var cupcakes = [CupcakeSprite]()
	var stickerSprites = [SKSpriteNode]()
	var onMirror = [SKSpriteNode]()
	var cardSprite: SKSpriteNode?
	var movingSprite: SKSpriteNode?
    var minY = CGFloat(0)
    var clipY = CGFloat(0)
	
	var shareButton :EventSprite?
    var cupcakeButton :EventSprite?
	
	var birthdayPeople = [LittlePerson]()
	var birthdayPerson: LittlePerson?
    
    var stickerRects = [CGRect]()
	
	var moved = false
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        self.size.width = view.bounds.width
        self.size.height = view.bounds.height
        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        let background = SKSpriteNode(imageNamed: "dressup_background")
        background.position = CGPointMake(self.size.width/2, self.size.height/2)
        background.size.width = self.size.width
        background.size.height = self.size.height
        background.zPosition = 0
        self.addChild(background)
        
        setupTopBar()
		
		shareButton = EventSprite(imageNamed: "camera")
        shareButton?.zPosition = 10
        shareButton?.topic = BirthdayPeopleScene.TOPIC_SHARE_IMAGE
        topBar!.addCustomSprite(shareButton!)
		
		cupcakeButton = EventSprite(imageNamed: "cupcake4")
        cupcakeButton?.zPosition = 10
        cupcakeButton?.topic = BirthdayPeopleScene.TOPIC_SHOW_CUPCAKES
        topBar!.addCustomSprite(cupcakeButton!)
		
		birthdayPeople = DataService.getInstance().dbHelper.getNextBirthdays(15, maxLevel: 4)
		if birthdayPeople.count == 0 {
			birthdayPeople.append(selectedPerson!)
		}
		
		//-- TODO sort by birth date
		
		setupCupcakes()
		
		EventHandler.getInstance().subscribe(BirthdayPeopleScene.TOPIC_PERSON_TOUCHED, listener: self)
        EventHandler.getInstance().subscribe(BirthdayPeopleScene.TOPIC_BIRTHDAY_PERSON_SELECTED, listener: self)
		EventHandler.getInstance().subscribe(BirthdayPeopleScene.TOPIC_CARD_SELECTED, listener: self)
		EventHandler.getInstance().subscribe(BirthdayPeopleScene.TOPIC_SHARE_IMAGE, listener: self)
		EventHandler.getInstance().subscribe(BirthdayPeopleScene.TOPIC_SHOW_CUPCAKES, listener: self)
    }
	
	override func willMoveFromView(view: SKView) {
        super.willMoveFromView(view)
        EventHandler.getInstance().unSubscribe(BirthdayPeopleScene.TOPIC_PERSON_TOUCHED, listener: self)
        EventHandler.getInstance().unSubscribe(BirthdayPeopleScene.TOPIC_BIRTHDAY_PERSON_SELECTED, listener: self)
		EventHandler.getInstance().unSubscribe(BirthdayPeopleScene.TOPIC_CARD_SELECTED, listener: self)
		EventHandler.getInstance().unSubscribe(BirthdayPeopleScene.TOPIC_SHARE_IMAGE, listener: self)
		EventHandler.getInstance().unSubscribe(BirthdayPeopleScene.TOPIC_SHOW_CUPCAKES, listener: self)
    }
	
	override func onEvent(topic: String, data: NSObject?) {
		super.onEvent(topic, data: data)
        if topic == BirthdayPeopleScene.TOPIC_PERSON_TOUCHED {
		} else if topic == BirthdayPeopleScene.TOPIC_BIRTHDAY_PERSON_SELECTED {
			setupVanity()
		} else if topic == BirthdayPeopleScene.TOPIC_CARD_SELECTED {
            if data is EventSprite {
                cardSelected(data as! EventSprite)
            }
		} else if topic == BirthdayPeopleScene.TOPIC_SHARE_IMAGE {
		} else if topic == BirthdayPeopleScene.TOPIC_SHOW_CUPCAKES {
			setupCupcakes()
		}
	}
	
	func setupCupcakes() {
		//TODO remove old sprites
        
        self.birthdayPerson = nil
		
		if vanityTop != nil {
			vanityTop!.removeFromParent()
		}
		if vanityBottom != nil {
			vanityBottom!.removeFromParent()
		}
        
        for ps in peopleSprites {
            ps.removeFromParent()
        }
        peopleSprites.removeAll()
		
		let width = min(self.size.width, self.size.height - self.topBar!.size.height)
		let cupcakeWidth = (width / CGFloat(3)) - 10
        
		//-- create cupcakes
		var x = CGFloat(10 + cupcakeWidth / 2)
		var y = self.size.height - cupcakeWidth
		for person in birthdayPeople {
			let num = 1 + arc4random_uniform(UInt32(4))
			let cupcake = CupcakeSprite(imageNamed: "cupcake\(num)")
			let ratio = cupcake.size.width / cupcake.size.height
			cupcake.size = CGSizeMake(cupcakeWidth, cupcakeWidth / ratio)
			cupcake.position = CGPointMake(x, y)
			cupcake.zPosition = 3
			cupcake.person = person
			self.addChild(cupcake)
			self.cupcakes.append(cupcake)
			
			x = x + cupcakeWidth + 10
			if x > width {
				x = CGFloat(10 + cupcakeWidth / 2)
				y = y - 20 - cupcakeWidth / ratio
			}
		}
        minY = y
        clipY = y
	}
	
	func setupVanity() {
		for cupcake in cupcakes {
			cupcake.removeFromParent()
		}
		cupcakes.removeAll()
	
        let width = min(self.size.width, self.size.height - self.topBar!.size.height)
        if width < self.size.width {
            portrait = false
        }
        
        let vtTexture = SKTexture(imageNamed: "vanity_top")
        var ratio = vtTexture.size().width / vtTexture.size().height
        
        var vanityWidth = width
        if !portrait {
            vanityWidth = (width / 2) * ratio
        }
        
        vanityTop = SKSpriteNode(texture: vtTexture)
        vanityTop?.size = CGSizeMake(vanityWidth * 0.885, vanityWidth * 0.885 / ratio)
        vanityTop?.zPosition = 1
        vanityTop?.position = CGPointMake(self.size.width / 2, ((self.size.height - topBar!.size.height) / 2) + vanityTop!.size.height / 2)
        self.addChild(vanityTop!)
        
        let vbTexture = SKTexture(imageNamed: "vanity_bottom")
        ratio = vbTexture.size().width / vbTexture.size().height
        vanityBottom = SKSpriteNode(texture: vbTexture)
        vanityBottom?.size = CGSizeMake(vanityWidth, vanityWidth / ratio)
        vanityBottom?.zPosition = 2
        vanityBottom?.position = CGPointMake(self.size.width / 2, ((self.size.height - topBar!.size.height) / 2) - (vanityBottom!.size.height / 2) + 6)
        self.addChild(vanityBottom!)
        
        let mirrorWidth = vanityTop!.size.width / 3
        let photoWidth = vanityWidth * 0.065
        
        let photo = TextureHelper.getPortraitTexture(self.birthdayPerson!)
        let photoSprite = SKSpriteNode(texture: photo)
        photoSprite.position = CGPointMake(vanityTop!.position.x + mirrorWidth - 3, vanityTop!.position.y - 10)
        let pr = photo!.size().width / photo!.size().height
        photoSprite.size.width = photoWidth
        photoSprite.size.height = (photoWidth) / pr
        photoSprite.zPosition = 3
        self.addChild(photoSprite)
        peopleSprites.append(photoSprite)
        
        let photo2 = TextureHelper.getPortraitTexture(self.selectedPerson!)
        let photoSprite2 = SKSpriteNode(texture: photo2)
        photoSprite2.position = CGPointMake(vanityTop!.position.x + mirrorWidth + photoSprite.size.width, vanityTop!.position.y - 10)
        let pr2 = photo2!.size().width / photo2!.size().height
        photoSprite2.size.width = photoWidth
        photoSprite2.size.height = (photoWidth) / pr2
        photoSprite2.zPosition = 3
        self.addChild(photoSprite2)
        peopleSprites.append(photoSprite2)
        
        let wordRect = CGRect(x: vanityTop!.position.x - mirrorWidth * 1.5, y: vanityTop!.position.y + vanityTop!.size.height / 3 - CGFloat(20), width: mirrorWidth, height: vanityTop!.size.height / 4)
        stickerRects.append(wordRect)
        let bottleRect = CGRect(x: vanityTop!.position.x + mirrorWidth / 2, y: vanityTop!.position.y + vanityTop!.size.height / 3 - CGFloat(20), width: mirrorWidth, height: vanityTop!.size.height/4)
        stickerRects.append(bottleRect)
        
        var cx = vanityBottom!.position.x - vanityWidth / 12
        var cy = vanityBottom!.position.y + 10 + vanityWidth / 4
        for c in 1..<6 {
            let cs = EventSprite(imageNamed: "stickers/cards/card\(c).png")
            let cr = cs.size.width / cs.size.height
            cs.size.width = vanityWidth / 6
            cs.size.height = (vanityWidth / 6) / cr
            cs.position = CGPointMake(vanityBottom!.position.x + vanityWidth / 4, vanityBottom!.position.y)
            cs.zPosition = 3
            cs.topic = BirthdayPeopleScene.TOPIC_CARD_SELECTED
            cs.userInteractionEnabled = true
            let act = SKAction.moveTo(CGPointMake(cx, cy), duration: 1.0)
            cs.runAction(act)
            self.addChild(cs)
            onMirror.append(cs)
            
            cx = cx + cs.size.width + 10
            if c == 2 {
                cx = vanityBottom!.position.x + cs.size.width / 2 - vanityWidth / 3.5
                cy = cy - cs.size.height - 10
            }
        }
        
        for r in stickerRects {
            let t = SKShapeNode(rect: r)
            t.zPosition = 20
            self.addChild(t)
        }
    }
    
    func cardSelected(card:EventSprite) {
        card.userInteractionEnabled = false
        for cs in onMirror {
            if cs != card {
                cs.removeFromParent()
            }
        }
        onMirror.removeAll()
        cardSprite = card
        let act1 = SKAction.moveTo(CGPointMake(self.vanityBottom!.position.x, self.vanityBottom!.position.y - 5), duration: 1.0)
        let cr = card.size.height / card.size.width
        let act2 = SKAction.resizeToWidth(vanityBottom!.size.width, height: vanityBottom!.size.width * cr, duration: 1.0)
        let act3 = SKAction.group([act1, act2])
        card.runAction(act3)
    }
	
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        for touch in touches {
            lastPoint = touch.locationInNode(self)
            break
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var nextPoint = CGPointMake(0,0)
        for touch in touches {
            nextPoint = touch.locationInNode(self)
			break
        }
        if self.birthdayPerson == nil {
            var dy = nextPoint.y - lastPoint.y
            if abs(dy) > 5 {
                moved = true
            }
            clipY += dy
            if clipY < minY {
                clipY = minY
                dy = CGFloat(0)
            }
            if clipY > 0 {
                clipY = 0
                dy = 0
            }
            if dy > 1 {
                for cs in cupcakes {
                    cs.position.y += dy
                }
            }
        }
        lastPoint = nextPoint
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
		for touch in touches {
			lastPoint = touch.locationInNode(self)
			if !moved && birthdayPerson == nil {
				let touchedNode = nodeAtPoint(lastPoint!)
				if touchedNode.parent is CupcakeSprite {
					let cupcake = touchedNode.parent as! CupcakeSprite
					self.birthdayPerson = cupcake.person
                    self.setupVanity()
				}
			}
            if !moved && cardSprite != nil {
            }
            break
		}
        moved = false
    }
    
    override func update(currentTime: NSTimeInterval) {
        super.update(currentTime)
	
    }
    
}


