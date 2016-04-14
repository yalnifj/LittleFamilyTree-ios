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
    var rectStickers = [Int:[SKTexture]]()
    var mirrorWidth = CGFloat(0)
	
	var moved = false
    var mirrorSprite = false
    var overCard = false
    var originalPosition = CGPointZero
    
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
        
        mirrorWidth = vanityTop!.size.width / 3
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
        
        let wordRect = CGRect(x: vanityTop!.position.x - mirrorWidth * 1.5, y: vanityTop!.position.y + vanityTop!.size.height / 5 - CGFloat(20), width: mirrorWidth * 0.9, height: vanityTop!.size.height / 3.5)
        stickerRects.append(wordRect)
        rectStickers[0] = [SKTexture(imageNamed: "stickers/words/word1.png"),
                           SKTexture(imageNamed: "stickers/words/word2.png"),
                           SKTexture(imageNamed: "stickers/words/word3.png"),
                           SKTexture(imageNamed: "stickers/words/word4.png"),
                           SKTexture(imageNamed: "stickers/words/word5.png")]
        
        let bottleRect = CGRect(x: vanityTop!.position.x + mirrorWidth * 0.75, y: vanityTop!.position.y + vanityTop!.size.height / 5 - CGFloat(20), width: mirrorWidth * 0.9, height: vanityTop!.size.height/3.5)
        stickerRects.append(bottleRect)
        rectStickers[1] = [SKTexture(imageNamed: "stickers/confetti/confetti1.png"),
                           SKTexture(imageNamed: "stickers/confetti/confetti2.png"),
                           SKTexture(imageNamed: "stickers/confetti/confetti3.png"),
                           SKTexture(imageNamed: "stickers/confetti/confetti4.png"),
                           SKTexture(imageNamed: "stickers/confetti/confetti5.png")]
        
        let heartRect = CGRect(x: vanityTop!.position.x - mirrorWidth * 1.5, y: wordRect.minY - wordRect.height, width: mirrorWidth * 0.6, height: vanityTop!.size.height / 3.5)
        stickerRects.append(heartRect)
        rectStickers[2] = [SKTexture(imageNamed: "stickers/hearts/heart1.png"),
                           SKTexture(imageNamed: "stickers/hearts/heart2.png"),
                           SKTexture(imageNamed: "stickers/hearts/heart3.png"),
                           SKTexture(imageNamed: "stickers/hearts/heart4.png"),
                           SKTexture(imageNamed: "stickers/hearts/heart5.png"),
                           SKTexture(imageNamed: "stickers/hearts/heart6.png")]
        
        let peopleRect = CGRect(x: vanityTop!.position.x + mirrorWidth * 0.75, y: bottleRect.minY - wordRect.height, width: mirrorWidth * 0.9, height: vanityTop!.size.height/3.5)
        stickerRects.append(peopleRect)
        rectStickers[3] = [TextureHelper.getPortraitTexture(selectedPerson!)!,
                           TextureHelper.getPortraitTexture(birthdayPerson!)!]
        
        let cakeRect = CGRect(x: vanityTop!.position.x - mirrorWidth * 1.5, y: heartRect.minY - heartRect.height, width: mirrorWidth * 0.6, height: vanityTop!.size.height / 3.5)
        stickerRects.append(cakeRect)
        rectStickers[4] = [SKTexture(imageNamed: "stickers/cakes/cake1.png"),
                           SKTexture(imageNamed: "stickers/cakes/cake2.png"),
                           SKTexture(imageNamed: "stickers/cakes/cake3.png"),
                           SKTexture(imageNamed: "stickers/cakes/cake4.png"),
                           SKTexture(imageNamed: "stickers/cakes/cake5.png"),
                           SKTexture(imageNamed: "stickers/cakes/cake6.png")]
        
        let balloonRect = CGRect(x: heartRect.maxX, y: wordRect.minY - wordRect.height * 2, width: mirrorWidth * 0.4, height: heartRect.height * 2)
        stickerRects.append(balloonRect)
        rectStickers[5] = [SKTexture(imageNamed: "stickers/balloons/balloons1.png"),
                           SKTexture(imageNamed: "stickers/balloons/balloons2.png"),
                           SKTexture(imageNamed: "stickers/balloons/balloons4.png"),
                           SKTexture(imageNamed: "stickers/balloons/balloons3.png"),
                           SKTexture(imageNamed: "stickers/balloons/balloons5.png")]
        
        let hatsRect = CGRect(x: vanityTop!.position.x + mirrorWidth * 0.75, y: peopleRect.minY - peopleRect.height, width: mirrorWidth * 0.9, height: vanityTop!.size.height/3.5)
        stickerRects.append(hatsRect)
        rectStickers[6] = [SKTexture(imageNamed: "stickers/hats/hat1.png"),
                           SKTexture(imageNamed: "stickers/hats/hat2.png"),
                           SKTexture(imageNamed: "stickers/hats/hat3.png"),
                           SKTexture(imageNamed: "stickers/hats/hat4.png"),
                           SKTexture(imageNamed: "stickers/hats/hat5.png"),
                           SKTexture(imageNamed: "stickers/hats/hat6.png")]
        
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
        
        /*
        for r in stickerRects {
            let t = SKShapeNode(rect: r)
            t.zPosition = 20
            self.addChild(t)
        }
 */
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
    
    func showStickers(r:Int, rect:CGRect) {
        //-- clear old stickers
        for s in onMirror {
            s.removeFromParent()
        }
        onMirror.removeAll()
        
        let stickers = rectStickers[r]
        var x = vanityTop!.position.x - mirrorWidth / 2.6
        var y = vanityTop!.position.y + vanityTop!.size.height / 2.7
        var prevHeight = CGFloat(0)
        for texture in stickers! {
            let sr = texture.size().width / texture.size().height
            var sw = mirrorWidth / CGFloat(3)
            var sh = sw / sr
            if sr > 1.7 {
                sw = mirrorWidth * 0.8
                sh = sw / sr
            }
            if x + sw / 2 > vanityTop!.position.x + mirrorWidth / 2 {
                x = vanityTop!.position.x - mirrorWidth / 2.6
                y = y - prevHeight / 2 - CGFloat(5)
                y -= sh / 2
            }
            x += sw / 2
            if prevHeight == 0 {
                y -= sh / 2
            }
            prevHeight = sh
            let s = SKSpriteNode(texture: texture)
            s.position = CGPointMake(rect.midX, rect.midY)
            s.zPosition = 5
            s.size.width = sw / 4
            s.size.height = sh / 4
            let act1 = SKAction.resizeToWidth(sw, height: sh, duration: 0.8)
            let act2 = SKAction.moveTo(CGPointMake(x, y), duration: 0.8)
            let act3 = SKAction.group([act1, act2])
            s.runAction(act3)
            self.addChild(s)
            onMirror.append(s)
            
            x += sw
        }
    }
	
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        for touch in touches {
            lastPoint = touch.locationInNode(self)
            if cardSprite != nil {
                let node = nodeAtPoint(lastPoint!)
                if node is SKSpriteNode {
                    mirrorSprite = false
                    if onMirror.contains(node as! SKSpriteNode) {
                        movingSprite = node as? SKSpriteNode
                        mirrorSprite = true
                        originalPosition = movingSprite!.position
                    }
                    else if stickerSprites.contains(node as! SKSpriteNode) {
                        movingSprite = node as? SKSpriteNode
                        mirrorSprite = false
                    }
                }
            }
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
        if cardSprite != nil && movingSprite != nil {
            movingSprite!.position.x += nextPoint.x - lastPoint.x
            movingSprite!.position.y += nextPoint.y - lastPoint.y
            moved = true
            
            if cardSprite!.frame.contains(movingSprite!.position) {
                overCard = true
                if mirrorSprite {
                    movingSprite?.setScale(1.5)
                }
            } else {
                overCard = false
                if mirrorSprite {
                    movingSprite?.setScale(1.0)
                }
            }
        }
        lastPoint = nextPoint
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
		for touch in touches {
			let nextPoint = touch.locationInNode(self)
            if moved && movingSprite != nil {
                movingSprite!.position.x += nextPoint.x - lastPoint.x
                movingSprite!.position.y += nextPoint.y - lastPoint.y
                if cardSprite!.frame.contains(movingSprite!.position) {
                    overCard = true
                } else {
                    overCard = false
                }
                if mirrorSprite {
                    if !overCard {
                        movingSprite!.runAction(SKAction.moveTo(originalPosition, duration: 0.6))
                    } else {
                        onMirror.removeObject(movingSprite!)
                        stickerSprites.append(movingSprite!)
                    }
                } else {
                    if !overCard {
                        movingSprite!.removeFromParent()
                        stickerSprites.removeObject(movingSprite!)
                    }
                }
            }
            
            lastPoint = nextPoint
			if !moved && birthdayPerson == nil {
				let touchedNode = nodeAtPoint(lastPoint!)
				if touchedNode is CupcakeSprite || touchedNode.parent is CupcakeSprite {
					let cupcake = touchedNode.parent as! CupcakeSprite
					self.birthdayPerson = cupcake.person
                    self.setupVanity()
				}
			}
            if !moved && cardSprite != nil {
                var r = 0
                for rect in stickerRects {
                    if rect.contains(lastPoint) {
                        showStickers(r, rect:rect)
                        break
                    }
                    r += 1
                }
            }
            break
		}
        moved = false
        movingSprite = nil
    }
    
    override func update(currentTime: NSTimeInterval) {
        super.update(currentTime)
	
    }
    
}


