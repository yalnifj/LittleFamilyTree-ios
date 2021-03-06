//
//  BirthdayPeopleScene
//  Little Family Tree
//
//  Created by Melissa on 12/5/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit
import Firebase

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
	var cardBottomSprite:SKSpriteNode?
	var cardBottomLogo:SKSpriteNode?
	var cardBottomText:SKLabelNode?
	var movingSprite: SKSpriteNode?
    var minY = CGFloat(0)
    var maxY = CGFloat(0)
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
    var originalPosition = CGPoint.zero
	
	var previousScale:CGFloat? = nil
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.size.width = view.bounds.width
        self.size.height = view.bounds.height
        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        let background = SKSpriteNode(imageNamed: "dressup_background")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.size.width = self.size.width
        background.size.height = self.size.height
        background.zPosition = 0
        self.addChild(background)
		
		let pinch:UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(BirthdayPeopleScene.pinched(_:)))
        view.addGestureRecognizer(pinch)
        
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
        
        let todayComponents = (Calendar.current as NSCalendar).components([.month, .day],
                                                                     from: Foundation.Date())
        let month = todayComponents.month
        
        //-- sort the people by birth date
        birthdayPeople.sort(by: {
            let ageComponents1 = (Calendar.current as NSCalendar).components([.month, .day],
                from: $0.birthDate!)
            var month1 = ageComponents1.month!
            if month1 < month {
                month1 = month1 + 12
            }
            let day1 = ageComponents1.day
            
            let ageComponents2 = (Calendar.current as NSCalendar).components([.month, .day],
                from: $1.birthDate!)
            var month2 = ageComponents2.month!
            if month2 < month {
                month2 = month2 + 12
            }
            let day2 = ageComponents2.day
            
            if month1 != month2 {
                return month1 < month2
            }
            return day1 < day2
        })

		if birthdayPerson == nil {
			setupCupcakes()
		} else {
			setupVanity()
		}
		
		EventHandler.getInstance().subscribe(BirthdayPeopleScene.TOPIC_PERSON_TOUCHED, listener: self)
        EventHandler.getInstance().subscribe(BirthdayPeopleScene.TOPIC_BIRTHDAY_PERSON_SELECTED, listener: self)
		EventHandler.getInstance().subscribe(BirthdayPeopleScene.TOPIC_CARD_SELECTED, listener: self)
		EventHandler.getInstance().subscribe(BirthdayPeopleScene.TOPIC_SHARE_IMAGE, listener: self)
		EventHandler.getInstance().subscribe(BirthdayPeopleScene.TOPIC_SHOW_CUPCAKES, listener: self)
        
        Analytics.logEvent(AnalyticsEventViewItem, parameters: [
            AnalyticsParameterItemName: String(describing: BirthdayPeopleScene.self) as NSObject
        ])
    }
	
	override func willMove(from view: SKView) {
        super.willMove(from: view)
        EventHandler.getInstance().unSubscribe(BirthdayPeopleScene.TOPIC_PERSON_TOUCHED, listener: self)
        EventHandler.getInstance().unSubscribe(BirthdayPeopleScene.TOPIC_BIRTHDAY_PERSON_SELECTED, listener: self)
		EventHandler.getInstance().unSubscribe(BirthdayPeopleScene.TOPIC_CARD_SELECTED, listener: self)
		EventHandler.getInstance().unSubscribe(BirthdayPeopleScene.TOPIC_SHARE_IMAGE, listener: self)
		EventHandler.getInstance().unSubscribe(BirthdayPeopleScene.TOPIC_SHOW_CUPCAKES, listener: self)
    }
	
	override func onEvent(_ topic: String, data: NSObject?) {
		super.onEvent(topic, data: data)
        if topic == BirthdayPeopleScene.TOPIC_PERSON_TOUCHED {
		} else if topic == BirthdayPeopleScene.TOPIC_BIRTHDAY_PERSON_SELECTED {
            setupVanity()
		} else if topic == BirthdayPeopleScene.TOPIC_CARD_SELECTED {
            if data is EventSprite {
                cardSelected(data as! EventSprite)
            }
		} else if topic == BirthdayPeopleScene.TOPIC_SHARE_IMAGE {
			showParentAuth()
		} else if topic == BirthdayPeopleScene.TOPIC_SHOW_CUPCAKES {
			setupCupcakes()
        } else if topic == LittleFamilyScene.TOPIC_TRY_PRESSED {
            let tryCount = getTryCount("try_birthday_count")
            DataService.getInstance().dbHelper.saveProperty("try_birthday_count", value: "\(tryCount)")
        }
	}
	
	func setupCupcakes() {
        if cardSprite != nil {
            cardSprite!.removeFromParent()
			cardBottomLogo!.removeFromParent()
			cardBottomSprite!.removeFromParent()
			cardBottomText!.removeFromParent()
        }
        cardSprite = nil
		cardBottomLogo = nil
		cardBottomSprite = nil
		cardBottomText = nil
        
        for s in onMirror {
            s.removeFromParent()
        }
        onMirror.removeAll()
        
        for s in stickerSprites {
            s.removeFromParent()
        }
        stickerSprites.removeAll()
        
        for s in cupcakes {
            s.removeFromParent()
        }
        cupcakes.removeAll()
        
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
		var y = self.size.height - topBar!.size.height - cupcakeWidth
		for person in birthdayPeople {
            DataService.getInstance().addToSyncQ(person)
			let num = 1 + arc4random_uniform(UInt32(4))
			let cupcake = CupcakeSprite(imageNamed: "cupcake\(num)")
			let ratio = cupcake.size.width / cupcake.size.height
			cupcake.size = CGSize(width: cupcakeWidth, height: cupcakeWidth / ratio)
			cupcake.position = CGPoint(x: x, y: y)
			cupcake.zPosition = 3
			cupcake.person = person
			self.addChild(cupcake)
			self.cupcakes.append(cupcake)
			
			x = x + cupcakeWidth + 10
			if x > self.size.width {
				x = CGFloat(10 + cupcakeWidth / 2)
				y = y - (60 + cupcakeWidth / ratio)
			}
		}
        minY = y - cupcakeWidth/2
        maxY = abs(y)
        clipY = y
        speak("Look who has birthdays coming up!")
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
        
        var vanityWidth = width
        
        let vtTexture = SKTexture(imageNamed: "vanity_top")
        let ratio = vtTexture.size().width / vtTexture.size().height
        var theight = vanityWidth * 0.885 / ratio
        let vbTexture = SKTexture(imageNamed: "vanity_bottom")
        let bratio = vbTexture.size().width / vbTexture.size().height
        var bheight = vanityWidth / bratio
        
        if theight + bheight > self.size.height {
            bheight = (self.size.height - (topBar!.size.height * 2)) / 2
            vanityWidth = bheight * bratio
            
            theight = vanityWidth * 0.885 / ratio
        }
        
        vanityTop = SKSpriteNode(texture: vtTexture)
        vanityTop?.size = CGSize(width: vanityWidth * 0.885, height: theight)
        vanityTop?.zPosition = 1
        vanityTop?.position = CGPoint(x: self.size.width / 2, y: self.size.height - (topBar!.size.height + 10) - (vanityTop!.size.height / 2))
        self.addChild(vanityTop!)
        
        vanityBottom = SKSpriteNode(texture: vbTexture)
        vanityBottom?.size = CGSize(width: vanityWidth, height: bheight)
        vanityBottom?.zPosition = 2
        vanityBottom?.position = CGPoint(x: self.size.width / 2, y: self.size.height - (topBar!.size.height + 10) - vanityTop!.size.height - (vanityBottom!.size.height / 2) + 6)
        self.addChild(vanityBottom!)
        
        mirrorWidth = vanityTop!.size.width / 3
        let photoWidth = vanityWidth * 0.065
        
        let photo = TextureHelper.getPortraitTexture(self.birthdayPerson!)
        let photoSprite = SKSpriteNode(texture: photo)
        photoSprite.position = CGPoint(x: vanityTop!.position.x + mirrorWidth - 3, y: vanityTop!.position.y - 10)
        let pr = photo!.size().width / photo!.size().height
        photoSprite.size.width = photoWidth
        photoSprite.size.height = (photoWidth) / pr
        photoSprite.zPosition = 3
        self.addChild(photoSprite)
        peopleSprites.append(photoSprite)
        
        let photo2 = TextureHelper.getPortraitTexture(self.selectedPerson!)
        let photoSprite2 = SKSpriteNode(texture: photo2)
        photoSprite2.position = CGPoint(x: vanityTop!.position.x + mirrorWidth + photoSprite.size.width, y: vanityTop!.position.y - 10)
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
        DataService.getInstance().getFamilyMembers(birthdayPerson!, loadSpouse: false, onCompletion: { family, err in
            if family != nil {
                for p in family! {
                    if self.birthdayPerson != nil && p != self.birthdayPerson! && self.selectedPerson != nil && p != self.selectedPerson! && self.rectStickers[3]?.count<10 {
                        self.rectStickers[3]!.append(TextureHelper.getPortraitTexture(p)!)
                    }
                }
            }
        })
        
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
            cs.position = CGPoint(x: vanityBottom!.position.x + vanityWidth / 4, y: vanityBottom!.position.y)
            cs.zPosition = 3
            cs.topic = BirthdayPeopleScene.TOPIC_CARD_SELECTED
            cs.userData = NSMutableDictionary()
			cs.userData!.setValue(c, forKey: "cardNum")
            cs.isUserInteractionEnabled = true
            let act = SKAction.move(to: CGPoint(x: cx, y: cy), duration: 1.0)
            cs.run(act)
            self.addChild(cs)
            onMirror.append(cs)
            
            cx = cx + cs.size.width + 10
            if c == 2 {
                cx = vanityBottom!.position.x + cs.size.width / 2 - vanityWidth / 3.5
                cy = cy - cs.size.height - 10
            }
        }
        
        speak("Choose a birthday card to decorate for")
        let delayAction = SKAction.wait(forDuration: 1.4)
        run(delayAction, completion: {
            if (self.birthdayPerson != nil ) {
                self.sayGivenName(self.birthdayPerson!)
            }
        })
		
		self.userHasPremium({ premium in
			if !premium {
				let tryCount = self.getTryCount("try_birthday_count")
				
				var tryAvailable = true
				if tryCount > 3 {
					tryAvailable = false
				}
				
				self.showLockDialog(tryAvailable, tries: LittleFamilyScene.FREE_TRIES - (tryCount-1))
			}
		})
    }
    
    func cardSelected(_ card:EventSprite) {
        card.isUserInteractionEnabled = false
        for cs in onMirror {
            if cs != card {
                cs.removeFromParent()
            }
        }
        onMirror.removeAll()
        cardSprite = card
        let act1 = SKAction.move(to: CGPoint(x: self.vanityBottom!.position.x, y: self.vanityBottom!.position.y - 5), duration: 1.0)
        let cr = card.size.height / card.size.width
        let act2 = SKAction.resize(toWidth: vanityBottom!.size.width, height: vanityBottom!.size.width * cr, duration: 1.0)
        let act3 = SKAction.group([act1, act2])
        card.run(act3, completion: {
            self.setupCardBottom()
        }) 
    }
    func setupCardBottom() {
		let cardNum = cardSprite!.userData!["cardNum"] as! Int
		cardBottomSprite = SKSpriteNode(imageNamed: "stickers/cards/card\(cardNum)bottom.png")
		let cbr = cardBottomSprite!.size.height / cardBottomSprite!.size.width
		cardBottomSprite!.size.width = vanityBottom!.size.width
		cardBottomSprite!.size.height = vanityBottom!.size.width * cbr
		cardBottomSprite!.position = CGPoint(x: cardSprite!.position.x, y: cardSprite!.position.y - (cardSprite!.size.height / 2) - (cardBottomSprite!.size.height / 2))
		cardBottomSprite!.zPosition = 500
		cardBottomSprite!.isHidden = true
		self.addChild(cardBottomSprite!)
		
		cardBottomLogo = SKSpriteNode(imageNamed: "logo")
		let cbl = cardBottomLogo!.size.width / cardBottomLogo!.size.height
		cardBottomLogo!.size.height = cardBottomSprite!.size.height
		cardBottomLogo!.size.width = cardBottomLogo!.size.height * cbl
		cardBottomLogo!.position = CGPoint(x: cardBottomSprite!.frame.minX + CGFloat(10) + cardBottomLogo!.size.width / 2, y: cardBottomSprite!.position.y)
		cardBottomLogo!.zPosition = cardBottomSprite!.zPosition + 1
		cardBottomLogo!.isHidden = true
		self.addChild(cardBottomLogo!)
        
        if birthdayPerson != nil && birthdayPerson?.birthDate != nil {
            let ageComponents = (Calendar.current as NSCalendar).components([.month, .day],
                                                                        from: birthdayPerson!.birthDate!)
            let month = ageComponents.month!
            let day = ageComponents.day!
            
            let ageComponentsNow = (Calendar.current as NSCalendar).components([.month, .day],
                                                                           from: Foundation.Date())
            var age = birthdayPerson!.age!
            let monthN = ageComponentsNow.month!
            let dayN = ageComponentsNow.day!
            if month > monthN || (month==monthN && day > dayN) {
                age += 1
            }

            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d"
            let dateString = formatter.string(from: birthdayPerson!.birthDate!)
            
            let message = "Happy \(age) Birthday to \(birthdayPerson!.name!) on \(dateString)"
            cardBottomText = SKLabelNode(text: message)
            cardBottomText!.fontSize = cardBottomSprite!.size.height / 3
            cardBottomText!.fontColor = UIColor.black
            cardBottomText!.position = CGPoint(x: cardBottomLogo!.frame.maxX + CGFloat(10) + cardBottomText!.frame.width / 2, y: cardBottomSprite!.position.y)
            cardBottomText!.zPosition = cardBottomSprite!.zPosition + 1
            cardBottomText!.isHidden = true
            self.addChild(cardBottomText!)
        }
    }
    
    func showStickers(_ r:Int, rect:CGRect) {
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
            s.position = CGPoint(x: rect.midX, y: rect.midY)
            s.zPosition = CGFloat(5 + stickerSprites.count)
            s.size.width = sw / 4
            s.size.height = sh / 4
            let act1 = SKAction.resize(toWidth: sw, height: sh, duration: 0.8)
            let act2 = SKAction.move(to: CGPoint(x: x, y: y), duration: 0.8)
            let act3 = SKAction.group([act1, act2])
            s.run(act3)
            self.addChild(s)
            onMirror.append(s)
            
            x += sw
        }
    }
    
    func restackStickers() {
        var z = CGFloat(5)
        for s in stickerSprites {
            s.zPosition = z
            z += 1
        }
    }
	
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        for touch in touches {
            lastPoint = touch.location(in: self)
            if cardSprite != nil {
                let node = atPoint(lastPoint!)
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
                        stickerSprites.removeObject(movingSprite!)
                        stickerSprites.append(movingSprite!)
                        restackStickers()
                    }
                }
            }
            break
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        var nextPoint = CGPoint(x: 0,y: 0)
        for touch in touches {
            nextPoint = touch.location(in: self)
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
            if clipY > maxY {
                clipY = maxY
                dy = CGFloat(0)
            }
            if moved {
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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
		for touch in touches {
			let nextPoint = touch.location(in: self)
            if cardSprite != nil && moved && movingSprite != nil {
                movingSprite!.position.x += nextPoint.x - lastPoint.x
                movingSprite!.position.y += nextPoint.y - lastPoint.y
                if cardSprite!.frame.contains(movingSprite!.position) {
                    overCard = true
                } else {
                    overCard = false
                }
                if mirrorSprite {
                    if !overCard {
                        movingSprite!.run(SKAction.move(to: originalPosition, duration: 0.6))
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
                let apoint = CGPoint(x: lastPoint.x, y: lastPoint.y)
				let touchedNode = atPoint(apoint)
				if touchedNode is CupcakeSprite {
					let cupcake = touchedNode as! CupcakeSprite
					self.birthdayPerson = cupcake.person
                    print("selecting cupcake \(cupcake.person!.name!) at \(apoint)")
                    self.setupVanity()
				}
                else if touchedNode.parent is CupcakeSprite {
                    let cupcake = touchedNode.parent as! CupcakeSprite
                    self.birthdayPerson = cupcake.person
                    print("selecting cupcake \(cupcake.person!.name!) at \(apoint)")
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
	
	func pinched(_ sender:UIPinchGestureRecognizer){
		if movingSprite != nil {			
			if sender.state == UIGestureRecognizerState.ended || sender.state == UIGestureRecognizerState.cancelled {
				previousScale = nil
			}
			else if sender.state == UIGestureRecognizerState.began {
				previousScale = sender.scale
			}
			else if previousScale != nil {
				if sender.scale != previousScale! {
					let diff = (sender.scale - previousScale!) / 16
					
					var xscale = movingSprite!.xScale
					xscale += diff
                    if xscale > 3.0 {
                        xscale = 3.0
                    }
                    if xscale < 0.3 {
                        xscale = 0.3
                    }
					
					let zoomIn = SKAction.scale(to: xscale, duration:0)
					movingSprite?.run(zoomIn)
				}
			}
		}
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
	
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
            var scene:BirthdayPeopleScene
            init(scene:BirthdayPeopleScene) {
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
        if cardBottomSprite != nil {
            cardBottomSprite!.isHidden = false
            cardBottomLogo!.isHidden = false
            cardBottomText!.isHidden = false
            
            DispatchQueue.main.async(execute: {
            
                let height = self.cardSprite!.frame.height + self.cardBottomSprite!.frame.height
                
                let imageTexture = self.scene!.view!.texture(from: self)
                if imageTexture != nil {
                    //let cropTexture = SKTexture(rect: cropRect, inTexture: imageTexture!)
                    let ratio = UIScreen.main.scale
                    let cropRect = CGRect(x: self.cardSprite!.frame.minX * ratio, y: (self.size.height - self.cardSprite!.frame.maxY) * ratio, width: self.cardSprite!.frame.width * ratio, height: height * ratio)
                    let cgimage = imageTexture!.cgImage()
                    let cgCropped = cgimage.cropping(to: cropRect)
                    let image = UIImage(cgImage: cgCropped!)
                    if image.size.width > 0 {
                        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                        if let wPPC = activityViewController.popoverPresentationController {
                            wPPC.sourceView = self.view!
                            wPPC.sourceRect = CGRect(x: self.size.width/4, y: self.size.height/2, width: self.size.width/2, height: self.size.height/2)
                        }
                        self.view!.window!.rootViewController!.present(activityViewController, animated: true, completion: nil)
                    } else {
                        print("Unable to create UIImage")
                    }
                
                } else {
                    print("Unable to generate image")
                }
                self.cardBottomSprite!.isHidden = true
                self.cardBottomLogo!.isHidden = true
                self.cardBottomText!.isHidden = true
            })
        }
	}
}


