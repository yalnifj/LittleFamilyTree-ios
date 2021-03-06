//
//  GameScene.swift
//  Little Family Tree
//
//  Created by Melissa on 9/12/15.
//  Copyright (c) 2015 Melissa. All rights reserved.
//

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

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class GameScene: LittleFamilyScene {
    static var TOPIC_START_MATCH = "start_match"
    static var TOPIC_START_DRESSUP = "start_dressup"
    static var TOPIC_START_PUZZLE = "start_puzzle"
	static var TOPIC_START_SCRATCH = "start_scratch"
	static var TOPIC_START_COLORING = "start_coloring"
	static var TOPIC_START_TREE = "start_tree"
	static var TOPIC_START_BUBBLES = "start_bubbles"
    static var TOPIC_START_SONG = "start_song"
    static var TOPIC_START_CARD = "start_card"
    static var TOPIC_START_BIRD = "start_bird"
    
    var maxHeight : CGFloat!
    var lfScale : CGFloat = 1;
    var diffY : CGFloat!
    var clipX : CGFloat = -200.0
    var clipY : CGFloat = 0.0
    var minX : CGFloat = 295.0
    var minY : CGFloat = 0
    var oHeight : CGFloat = 800
    var oWidth : CGFloat = 1280
    var lastPoint : CGPoint!
    var background : SKSpriteNode!
    var spriteContainer : SKSpriteNode!
	var updateSprites = [AnimatedStateSprite]()
    var touchableSprites = [SKNode]()
	var starSprites = [SKSpriteNode]()
    var premiumSprites = [SKSpriteNode]()
    var minScale : CGFloat = 0.5
    var maxScale : CGFloat = 2.0
    var moved = false
	
	var starWait = 100
    var pStarWait = 200
    
    var previousScale:CGFloat? = nil
    
    var personLeaves : PersonLeavesButton?
    
    override func didMove(to view: SKView) {
		super.didMove(to: view)
        let pinch:UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(GameScene.pinched(_:)))
        view.addGestureRecognizer(pinch)
        
        /* Setup your scene here */
        var z:CGFloat = 0
        background = SKSpriteNode(imageNamed: "house_background2")
        background.anchorPoint = CGPoint.zero
        background.position = CGPoint.zero
        z += 1
        background.zPosition =  z
        maxHeight = self.size.height*1.1
        if maxHeight < oHeight {
            maxHeight = oHeight
        }
        if (maxHeight > oHeight) {
            lfScale = maxHeight / oHeight;
        }
        else if oHeight > self.size.height {
            lfScale = self.size.height * 1.1 / oHeight
        }
        maxScale = lfScale * 2.5
        minScale = self.size.height / oHeight
        diffY = maxHeight - self.size.height
        background.size = CGSize(width: self.size.width * 3, height: maxHeight);
        self.addChild(background);
        
        spriteContainer = SKSpriteNode()
        spriteContainer.anchorPoint = CGPoint.zero
        spriteContainer.position = CGPoint(x: clipX, y: minY)
        spriteContainer.setScale(lfScale)
        z += 1
        spriteContainer.zPosition =  z
        self.addChild(spriteContainer)
        
        let cloud1 = MovingAnimatedStateSprite(imageNamed: "house_cloud1")
        cloud1.anchorPoint = CGPoint.zero
        cloud1.position = CGPoint(x: 0, y: oHeight - cloud1.size.height - 25)
        z += 1
        cloud1.zPosition =  z
        touchableSprites.append(cloud1)
        cloud1.addTexture(1, texture: SKTexture(imageNamed: "house_cloud1a"))
        cloud1.addTexture(2, texture: SKTexture(imageNamed: "house_cloud1b"))
        cloud1.addTexture(3, texture: SKTexture(imageNamed: "house_cloud1c"))
        let cloudrain:[SKTexture] = [
            SKTexture(imageNamed: "house_cloud1d"),
            SKTexture(imageNamed: "house_cloud1e")
        ]
        let rainAction = SKAction.repeat(SKAction.animate(with: cloudrain, timePerFrame: 0.06, resize: false, restore: false), count: 20)
        cloud1.addAction(4, action: rainAction)
        cloud1.addSound(4, soundFile: "rain")
		cloud1.moveAction = SKAction.repeatForever(SKAction.moveBy(x: 5, y:0, duration: 1))
		cloud1.maxX = oWidth
		cloud1.maxY = oHeight
        spriteContainer.addChild(cloud1)
		updateSprites.append(cloud1)
		cloud1.run(cloud1.moveAction!)
        
        let cloud2 = MovingAnimatedStateSprite(imageNamed: "house_cloud2")
        cloud2.anchorPoint = CGPoint.zero
        cloud2.position = CGPoint(x: minY + oWidth*0.75, y: oHeight - cloud1.size.height - 15)
        z += 1
        cloud2.zPosition =  z
		cloud2.moveAction = SKAction.repeatForever(SKAction.moveBy(x: 5, y:0, duration: 1))
		cloud2.maxX = oWidth
		cloud2.maxY = oHeight
        spriteContainer.addChild(cloud2)
		updateSprites.append(cloud2)
		cloud2.run(cloud2.moveAction!)
        
        let tree = SKSpriteNode(imageNamed: "house_tree1")
        tree.anchorPoint = CGPoint.zero
        tree.position = CGPoint(x: 50, y: oHeight - tree.size.height - 250)
        z += 1
        tree.zPosition =  z
        spriteContainer.addChild(tree)
        
        let flowers1 = AnimatedStateSprite(imageNamed: "house_flowers_a1")
        flowers1.anchorPoint = CGPoint.zero
        flowers1.position = CGPoint(x: 90+flowers1.size.width, y: 200-flowers1.size.height)
        flowers1.xScale = flowers1.xScale * -1
        z += 1
        flowers1.zPosition =  z
        touchableSprites.append(flowers1)
        let flowersSpin:[SKTexture] = [
            SKTexture(imageNamed: "house_flowers_a2"),
            SKTexture(imageNamed: "house_flowers_a3"),
            SKTexture(imageNamed: "house_flowers_a4"),
            SKTexture(imageNamed: "house_flowers_a5")
        ]
        let spinAction = SKAction.repeat(SKAction.animate(with: flowersSpin, timePerFrame: 0.06, resize: false, restore: false), count: 3)
        flowers1.addAction(1, action: spinAction)
        flowers1.addSound(1, soundFile: "spinning")
        spriteContainer.addChild(flowers1)
        
        let flowers2 = AnimatedStateSprite(imageNamed: "house_flowers_a1")
        flowers2.anchorPoint = CGPoint.zero
        flowers2.position = CGPoint(x: 265, y: 200-flowers2.size.height)
        z += 1
        flowers2.zPosition =  z
        touchableSprites.append(flowers2)
        flowers2.addAction(1, action: spinAction)
        flowers2.addSound(1, soundFile: "spinning")
        spriteContainer.addChild(flowers2)
		
		personLeaves = PersonLeavesButton()
		personLeaves?.anchorPoint = CGPoint.zero
		personLeaves?.size.width = 65
		personLeaves?.size.height = 65
		personLeaves?.position = CGPoint(x: 245, y: 455-(personLeaves?.size.height)!)
        z += 1
		personLeaves?.zPosition =  z
		touchableSprites.append(personLeaves!)
		spriteContainer.addChild(personLeaves!)
		starSprites.append(personLeaves!)
		
		DataService.getInstance().getFamilyMembers(selectedPerson!, loadSpouse: true, onCompletion: { people, err in
			self.personLeaves?.people = people
		});
        
        let bird = BirdHomeSprite(imageNamed: "house_tree_bird")
        bird.topic = GameScene.TOPIC_START_BIRD
        bird.anchorPoint = CGPoint.zero
        bird.position = CGPoint(x: 110, y: 445-(personLeaves?.size.height)!)
        bird.oposition = CGFloat(110)
        z += 1
        bird.zPosition =  z
        bird.createActions()
        touchableSprites.append(bird)
        spriteContainer.addChild(bird)
        premiumSprites.append(bird)
		
        
        let tileY:CGFloat = 600
        let tile01 = SKSpriteNode(imageNamed: "house_rooms_0_1")
        tile01.anchorPoint = CGPoint.zero
        tile01.position = CGPoint(x: 450, y: tileY - tile01.size.height)
        z += 1
        tile01.zPosition =  z
        spriteContainer.addChild(tile01)
        
        let tile02 = SKSpriteNode(imageNamed: "house_rooms_0_2")
        tile02.anchorPoint = CGPoint.zero
        tile02.position = CGPoint(x: 450, y: tileY - (tile01.size.height*2))
        z += 1
        tile02.zPosition =  z
        spriteContainer.addChild(tile02)
        
        let tile03 = SKSpriteNode(imageNamed: "house_rooms_0_3")
        tile03.anchorPoint = CGPoint.zero
        tile03.position = CGPoint(x: 450, y: tileY - (tile01.size.height*3))
        z += 1
        tile03.zPosition =  z
        spriteContainer.addChild(tile03)
        
        let tile04 = SKSpriteNode(imageNamed: "house_rooms_0_4")
        tile04.anchorPoint = CGPoint.zero
        tile04.position = CGPoint(x: 450, y: tileY - (tile01.size.height*4))
        z += 1
        tile04.zPosition =  z
        spriteContainer.addChild(tile04)
        
        
        let tile10 = SKSpriteNode(imageNamed: "house_rooms_1_0")
        tile10.anchorPoint = CGPoint.zero
        tile10.position = CGPoint(x: 450 + tile10.size.width, y: tileY)
        z += 1
        tile10.zPosition =  z
        spriteContainer.addChild(tile10)
        
        let tile11 = SKSpriteNode(imageNamed: "house_rooms_1_1")
        tile11.anchorPoint = CGPoint.zero
        tile11.position = CGPoint(x: 450 + tile10.size.width, y: tileY - tile11.size.height)
        z += 1
        tile11.zPosition =  z
        spriteContainer.addChild(tile11)
        
        let tile12 = SKSpriteNode(imageNamed: "house_rooms_1_2")
        tile12.anchorPoint = CGPoint.zero
        tile12.position = CGPoint(x: 450 + tile10.size.width, y: tileY - (tile12.size.height*2))
        z += 1
        tile12.zPosition =  z
        spriteContainer.addChild(tile12)
        
        let tile13 = SKSpriteNode(imageNamed: "house_rooms_1_3")
        tile13.anchorPoint = CGPoint.zero
        tile13.position = CGPoint(x: 450 + tile10.size.width, y: tileY - (tile13.size.height*3))
        z += 1
        tile13.zPosition =  z
        spriteContainer.addChild(tile13)
        
        let tile14 = SKSpriteNode(imageNamed: "house_rooms_1_4")
        tile14.anchorPoint = CGPoint.zero
        tile14.position = CGPoint(x: 450 + tile10.size.width, y: tileY - (tile14.size.height*4))
        z += 1
        tile14.zPosition =  z
        spriteContainer.addChild(tile14)
        
        
        let tile20 = SKSpriteNode(imageNamed: "house_rooms_2_0")
        tile20.anchorPoint = CGPoint.zero
        tile20.position = CGPoint(x: 450 + (tile20.size.width*2), y: tileY)
        z += 1
        tile20.zPosition =  z
        spriteContainer.addChild(tile20)
        
        let tile21 = SKSpriteNode(imageNamed: "house_rooms_2_1")
        tile21.anchorPoint = CGPoint.zero
        tile21.position = CGPoint(x: 450 + (tile20.size.width*2), y: tileY - tile21.size.height)
        z += 1
        tile21.zPosition =  z
        spriteContainer.addChild(tile21)
        
        let tile22 = SKSpriteNode(imageNamed: "house_rooms_2_2")
        tile22.anchorPoint = CGPoint.zero
        tile22.position = CGPoint(x: 450 + (tile20.size.width*2), y: tileY - (tile22.size.height*2))
        z += 1
        tile22.zPosition =  z
        spriteContainer.addChild(tile22)
        
        let tile23 = SKSpriteNode(imageNamed: "house_rooms_2_3")
        tile23.anchorPoint = CGPoint.zero
        tile23.position = CGPoint(x: 450 + (tile20.size.width*2), y: tileY - (tile23.size.height*3))
        z += 1
        tile23.zPosition =  z
        spriteContainer.addChild(tile23)
        
        let tile24 = SKSpriteNode(imageNamed: "house_rooms_2_4")
        tile24.anchorPoint = CGPoint.zero
        tile24.position = CGPoint(x: 450 + (tile20.size.width*2), y: tileY - (tile24.size.height*4))
        z += 1
        tile24.zPosition =  z
        spriteContainer.addChild(tile24)
        
        let tile30 = SKSpriteNode(imageNamed: "house_rooms_3_0")
        tile30.anchorPoint = CGPoint.zero
        tile30.position = CGPoint(x: 450 + (tile30.size.width*3), y: tileY)
        z += 1
        tile30.zPosition =  z
        spriteContainer.addChild(tile30)
        
        let tile31 = SKSpriteNode(imageNamed: "house_rooms_3_1")
        tile31.anchorPoint = CGPoint.zero
        tile31.position = CGPoint(x: 450 + (tile30.size.width*3), y: tileY - tile31.size.height)
        z += 1
        tile31.zPosition =  z
        spriteContainer.addChild(tile31)
        
        let tile32 = SKSpriteNode(imageNamed: "house_rooms_3_2")
        tile32.anchorPoint = CGPoint.zero
        tile32.position = CGPoint(x: 450 + (tile30.size.width*3), y: tileY - (tile32.size.height*2))
        z += 1
        tile32.zPosition =  z
        spriteContainer.addChild(tile32)
        
        let tile33 = SKSpriteNode(imageNamed: "house_rooms_3_3")
        tile33.anchorPoint = CGPoint.zero
        tile33.position = CGPoint(x: 450 + (tile30.size.width*3), y: tileY - (tile33.size.height*3))
        z += 1
        tile33.zPosition =  z
        spriteContainer.addChild(tile33)
        
        let tile34 = SKSpriteNode(imageNamed: "house_rooms_3_4")
        tile34.anchorPoint = CGPoint.zero
        tile34.position = CGPoint(x: 450 + (tile30.size.width*3), y: tileY - (tile34.size.height*4))
        z += 1
        tile34.zPosition =  z
        spriteContainer.addChild(tile34)

        
        let tile41 = SKSpriteNode(imageNamed: "house_rooms_4_1")
        tile41.anchorPoint = CGPoint.zero
        tile41.position = CGPoint(x: 450 + (tile41.size.width*4), y: tileY - tile41.size.height)
        z += 1
        tile41.zPosition =  z
        spriteContainer.addChild(tile41)
        
        let tile42 = SKSpriteNode(imageNamed: "house_rooms_4_2")
        tile42.anchorPoint = CGPoint.zero
        tile42.position = CGPoint(x: 450 + (tile41.size.width*4), y: tileY - (tile42.size.height*2))
        z += 1
        tile42.zPosition =  z
        spriteContainer.addChild(tile42)
        
        let tile43 = SKSpriteNode(imageNamed: "house_rooms_4_3")
        tile43.anchorPoint = CGPoint.zero
        tile43.position = CGPoint(x: 450 + (tile41.size.width*4), y: tileY - (tile43.size.height*3))
        z += 1
        tile43.zPosition =  z
        spriteContainer.addChild(tile43)
        
        let tile44 = SKSpriteNode(imageNamed: "house_rooms_4_4")
        tile44.anchorPoint = CGPoint.zero
        tile44.position = CGPoint(x: 450 + (tile41.size.width*4), y: tileY - (tile44.size.height*4))
        z += 1
        tile44.zPosition =  z
        spriteContainer.addChild(tile44)


        let couch = SKSpriteNode(imageNamed: "house_familyroom_couch")
        couch.anchorPoint = CGPoint.zero
        couch.position = CGPoint(x: 555, y: 140)
        z += 1
        couch.zPosition =  z
        spriteContainer.addChild(couch)
        
        let table1 = SKSpriteNode(imageNamed: "house_familyroom_table")
        table1.anchorPoint = CGPoint.zero
        table1.position = CGPoint(x: 491, y: 140)
        z += 1
        table1.zPosition =  z
        spriteContainer.addChild(table1)
        
        let table2 = SKSpriteNode(imageNamed: "house_familyroom_table")
        table2.anchorPoint = CGPoint.zero
        table2.position = CGPoint(x: 735, y: 140)
        z += 1
        table2.zPosition =  z
        spriteContainer.addChild(table2)
        
        let lamp1 = AnimatedStateSprite(imageNamed: "house_familyroom_lamp1")
        lamp1.anchorPoint = CGPoint.zero
        lamp1.position = CGPoint(x: 482, y: 170)
        z += 1
        lamp1.zPosition =  z
        touchableSprites.append(lamp1)
        lamp1.addTexture(1, texture: SKTexture(imageNamed: "house_familyroom_lamp2"))
        lamp1.addSound(0, soundFile: "pullchainslowon")
        lamp1.addSound(1, soundFile: "pullchainslowon")
        spriteContainer.addChild(lamp1)
        
        let lamp2 = AnimatedStateSprite(imageNamed: "house_familyroom_lamp1")
        lamp2.anchorPoint = CGPoint.zero
        lamp2.position = CGPoint(x: 725, y: 170)
        z += 1
        lamp2.zPosition =  z
        touchableSprites.append(lamp2)
        lamp2.addTexture(1, texture: SKTexture(imageNamed: "house_familyroom_lamp2"))
        lamp2.addSound(0, soundFile: "pullchainslowon")
        lamp2.addSound(1, soundFile: "pullchainslowon")
        spriteContainer.addChild(lamp2)
        
        let frame = AnimatedStateSprite(imageNamed: "house_familyroom_frame")
        frame.anchorPoint = CGPoint.zero
        frame.position = CGPoint(x: 612, y: 225)
        z += 1
        frame.zPosition =  z
		touchableSprites.append(frame)
        let jumping:[SKTexture] = [
            SKTexture(imageNamed: "house_familyroom_frame1"),
            SKTexture(imageNamed: "house_familyroom_frame2"),
            SKTexture(imageNamed: "house_familyroom_frame3"),
            SKTexture(imageNamed: "house_familyroom_frame4"),
			SKTexture(imageNamed: "house_familyroom_frame5"),
			SKTexture(imageNamed: "house_familyroom_frame6"),
			SKTexture(imageNamed: "house_familyroom_frame7"),
			SKTexture(imageNamed: "house_familyroom_frame8"),
			SKTexture(imageNamed: "house_familyroom_frame9"),
			SKTexture(imageNamed: "house_familyroom_frame10"),
			SKTexture(imageNamed: "house_familyroom_frame11"),
			SKTexture(imageNamed: "house_familyroom_frame12"),
			SKTexture(imageNamed: "house_familyroom_frame13"),
			SKTexture(imageNamed: "house_familyroom_frame14"),
			SKTexture(imageNamed: "house_familyroom_frame15"),
			SKTexture(imageNamed: "house_familyroom_frame16"),
			SKTexture(imageNamed: "house_familyroom_frame17"),
			SKTexture(imageNamed: "house_familyroom_frame18"),
			SKTexture(imageNamed: "house_familyroom_frame19"),
			SKTexture(imageNamed: "house_familyroom_frame21"),
			SKTexture(imageNamed: "house_familyroom_frame22"),
			SKTexture(imageNamed: "house_familyroom_frame23"),
			SKTexture(imageNamed: "house_familyroom_frame24"),
            SKTexture(imageNamed: "house_familyroom_frame25")
        ]
        let jumpAction = SKAction.repeat(SKAction.animate(with: jumping, timePerFrame: 0.06, resize: false, restore: false), count: 1)
        frame.addAction(1, action: jumpAction)
        frame.addClick(1, val: false)
        frame.addEvent(0, topic: GameScene.TOPIC_START_MATCH)
        spriteContainer.addChild(frame)
		starSprites.append(frame)
        
        let childBed = SKSpriteNode(imageNamed: "house_chilldroom_bed")
        childBed.anchorPoint = CGPoint.zero
        childBed.position = CGPoint(x: 827, y: 307)
        z += 1
        childBed.zPosition =  z
        spriteContainer.addChild(childBed)
        
        let childPaint = AnimatedStateSprite(imageNamed: "house_chilldroom_paint")
        childPaint.anchorPoint = CGPoint.zero
        childPaint.position = CGPoint(x: 1000, y: 312)
        z += 1
        childPaint.zPosition =  z
		touchableSprites.append(childPaint)
        let painting:[SKTexture] = [
            SKTexture(imageNamed: "house_chilldroom_paint1"),
            SKTexture(imageNamed: "house_chilldroom_paint2"),
            SKTexture(imageNamed: "house_chilldroom_paint3"),
            SKTexture(imageNamed: "house_chilldroom_paint4"),
			SKTexture(imageNamed: "house_chilldroom_paint5"),
			SKTexture(imageNamed: "house_chilldroom_paint6"),
			SKTexture(imageNamed: "house_chilldroom_paint7"),
			SKTexture(imageNamed: "house_chilldroom_paint8"),
			SKTexture(imageNamed: "house_chilldroom_paint9"),
			SKTexture(imageNamed: "house_chilldroom_paint10"),
			SKTexture(imageNamed: "house_chilldroom_paint11"),
			SKTexture(imageNamed: "house_chilldroom_paint12"),
			SKTexture(imageNamed: "house_chilldroom_paint13"),
			SKTexture(imageNamed: "house_chilldroom_paint14"),
			SKTexture(imageNamed: "house_chilldroom_paint15")
        ]
        let paintAction = SKAction.repeat(SKAction.animate(with: painting, timePerFrame: 0.06, resize: false, restore: false), count: 1)
        childPaint.addAction(1, action: paintAction)
        childPaint.addClick(1, val: false)
		childPaint.addEvent(0, topic: GameScene.TOPIC_START_COLORING)
        spriteContainer.addChild(childPaint)
		premiumSprites.append(childPaint)
        
        let childDesk = AnimatedStateSprite(imageNamed: "house_chilldroom_desk")
        childDesk.anchorPoint = CGPoint.zero
        childDesk.position = CGPoint(x: 1065, y: 312)
        z += 1
        childDesk.zPosition =  z
		touchableSprites.append(childDesk)
        let erasing:[SKTexture] = [
            SKTexture(imageNamed: "house_chilldroom_desk1"),
            SKTexture(imageNamed: "house_chilldroom_desk2"),
            SKTexture(imageNamed: "house_chilldroom_desk3"),
            SKTexture(imageNamed: "house_chilldroom_desk4"),
			SKTexture(imageNamed: "house_chilldroom_desk5"),
			SKTexture(imageNamed: "house_chilldroom_desk6"),
			SKTexture(imageNamed: "house_chilldroom_desk7"),
			SKTexture(imageNamed: "house_chilldroom_desk8"),
			SKTexture(imageNamed: "house_chilldroom_desk9"),
			SKTexture(imageNamed: "house_chilldroom_desk10"),
			SKTexture(imageNamed: "house_chilldroom_desk11"),
			SKTexture(imageNamed: "house_chilldroom_desk12"),
			SKTexture(imageNamed: "house_chilldroom_desk13"),
			SKTexture(imageNamed: "house_chilldroom_desk14"),
			SKTexture(imageNamed: "house_chilldroom_desk15"),
			SKTexture(imageNamed: "house_chilldroom_desk16"),
			SKTexture(imageNamed: "house_chilldroom_desk17"),
			SKTexture(imageNamed: "house_chilldroom_desk18"),
			SKTexture(imageNamed: "house_chilldroom_desk19")
        ]
        let eraseAction = SKAction.repeat(SKAction.animate(with: erasing, timePerFrame: 0.06, resize: false, restore: false), count: 1)
        childDesk.addAction(1, action: eraseAction)
        childDesk.addClick(1, val: false)
		childDesk.addEvent(0, topic: GameScene.TOPIC_START_SCRATCH)
        childDesk.addSound(1, soundFile: "erasing")
        spriteContainer.addChild(childDesk)
		starSprites.append(childDesk)
        
        let teddy = AnimatedStateSprite(imageNamed: "house_chilldroom_teddy")
        teddy.anchorPoint = CGPoint.zero
        teddy.position = CGPoint(x: 928, y: 310)
        z += 1
        teddy.zPosition =  z
        touchableSprites.append(teddy)
        let teddyfalling:[SKTexture] = [
            SKTexture(imageNamed: "house_chilldroom_teddy2"),
            SKTexture(imageNamed: "house_chilldroom_teddy3"),
            SKTexture(imageNamed: "house_chilldroom_teddy4"),
            SKTexture(imageNamed: "house_chilldroom_teddy5"),
            SKTexture(imageNamed: "house_chilldroom_teddy6")
        ]
        let fallaction = SKAction.repeat(SKAction.animate(with: teddyfalling, timePerFrame: 0.06, resize: false, restore: false), count: 1)
        teddy.addAction(1, action: fallaction)
        teddy.addClick(1, val: false)
        teddy.addSound(1, soundFile: "slide_whistle_down01")
        let riseaction = SKAction.reversed(fallaction)()
        teddy.addAction(3, action: riseaction)
        teddy.addSound(3, soundFile: "slide_whistle_up04")
        teddy.addClick(2, val: true)
        teddy.addClick(3, val: false)
        spriteContainer.addChild(teddy)
        
        
        let kitchenA = SKSpriteNode(imageNamed: "house_kitchen_a")
        kitchenA.anchorPoint = CGPoint.zero
        kitchenA.position = CGPoint(x: 840, y: 140)
        z += 1
        kitchenA.zPosition =  z
        spriteContainer.addChild(kitchenA)
        
        let kitchenB = SKSpriteNode(imageNamed: "house_kitchen_b")
        kitchenB.anchorPoint = CGPoint.zero
        kitchenB.position = CGPoint(x: kitchenA.position.x+kitchenA.size.width, y: 140)
        z += 1
        kitchenB.zPosition =  z
        spriteContainer.addChild(kitchenB)
        
        let kitchenC = SKSpriteNode(imageNamed: "house_kitchen_c")
        kitchenC.anchorPoint = CGPoint.zero
        kitchenC.position = CGPoint(x: kitchenB.position.x+kitchenB.size.width, y: 140)
        z += 1
        kitchenC.zPosition =  z
        spriteContainer.addChild(kitchenC)
        
        let kitchenD = SKSpriteNode(imageNamed: "house_kitchen_d")
        kitchenD.anchorPoint = CGPoint.zero
        kitchenD.position = CGPoint(x: kitchenC.position.x+kitchenC.size.width, y: 265)
        z += 1
        kitchenD.zPosition =  z
        spriteContainer.addChild(kitchenD)
        
        let kitchenE = SKSpriteNode(imageNamed: "house_kitchen_e")
        kitchenE.anchorPoint = CGPoint.zero
        kitchenE.position = CGPoint(x: kitchenD.position.x+kitchenD.size.width, y: 140)
        z += 1
        kitchenE.zPosition =  z
        spriteContainer.addChild(kitchenE)
        
        let toaster = AnimatedStateSprite(imageNamed: "house_toaster1")
        toaster.anchorPoint = CGPoint.zero
        toaster.position = CGPoint(x: 1085, y: 195)
        z += 1
        toaster.zPosition =  z
		touchableSprites.append(toaster)
        let toastDown:[SKTexture] = [
            SKTexture(imageNamed: "house_toaster2"),
            SKTexture(imageNamed: "house_toaster3")
        ]
        let toastDownAction = SKAction.repeat(SKAction.animate(with: toastDown, timePerFrame: 0.06, resize: false, restore: false), count: 1)
        toaster.addAction(1, action: toastDownAction)
        toaster.addClick(1, val: false)
		let toastIn:[SKTexture] = [
            SKTexture(imageNamed: "house_toaster4"),
            SKTexture(imageNamed: "house_toaster4")
        ]
        let toastInAction = SKAction.repeat(SKAction.animate(with: toastIn, timePerFrame: 0.06, resize: false, restore: false), count: 10)
        toaster.addAction(2, action: toastInAction)
        toaster.addClick(2, val: false)
		let toastUp:[SKTexture] = [
            SKTexture(imageNamed: "house_toaster5"),
			SKTexture(imageNamed: "house_toaster6"),
			SKTexture(imageNamed: "house_toaster7"),
			SKTexture(imageNamed: "house_toaster8"),
			SKTexture(imageNamed: "house_toaster9"),
			SKTexture(imageNamed: "house_toaster10"),
			SKTexture(imageNamed: "house_toaster11"),
			SKTexture(imageNamed: "house_toaster12"),
			SKTexture(imageNamed: "house_toaster13"),
			SKTexture(imageNamed: "house_toaster14"),
			SKTexture(imageNamed: "house_toaster15"),
			SKTexture(imageNamed: "house_toaster16"),
			SKTexture(imageNamed: "house_toaster17"),
			SKTexture(imageNamed: "house_toaster18"),
			SKTexture(imageNamed: "house_toaster19"),
			SKTexture(imageNamed: "house_toaster20"),
            SKTexture(imageNamed: "house_toaster21")
        ]
        let toastUpAction = SKAction.repeat(SKAction.animate(with: toastUp, timePerFrame: 0.06, resize: false, restore: false), count: 1)
        toaster.addAction(3, action: toastUpAction)
        toaster.addClick(3, val: false)
		toaster.addSound(1, soundFile: "toaster1")
		toaster.addSound(3, soundFile: "toaster2")
        spriteContainer.addChild(toaster)
        
        let kettle = AnimatedStateSprite(imageNamed: "house_kitchen_kettle")
        kettle.anchorPoint = CGPoint.zero
        kettle.position = CGPoint(x: 1120, y: 203)
        z += 1
        kettle.zPosition =  z
		touchableSprites.append(kettle)
        let warming:[SKTexture] = [
            SKTexture(imageNamed: "house_kitchen_kettle2"),
			SKTexture(imageNamed: "house_kitchen_kettle3"),
			SKTexture(imageNamed: "house_kitchen_kettle4"),
			SKTexture(imageNamed: "house_kitchen_kettle5"),
            SKTexture(imageNamed: "house_kitchen_kettle6")
        ]
        let warmingAction = SKAction.repeat(SKAction.animate(with: warming, timePerFrame: 0.06, resize: false, restore: false), count: 3)
        kettle.addAction(1, action: warmingAction)
        kettle.addClick(1, val: false)
        let steaming:[SKTexture] = [
            SKTexture(imageNamed: "house_kitchen_kettle7"),
			SKTexture(imageNamed: "house_kitchen_kettle8"),
			SKTexture(imageNamed: "house_kitchen_kettle9"),
			SKTexture(imageNamed: "house_kitchen_kettle10"),
            SKTexture(imageNamed: "house_kitchen_kettle11")
        ]
        let steamingAction = SKAction.repeat(SKAction.animate(with: steaming, timePerFrame: 0.06, resize: false, restore: false), count: 3)
        kettle.addAction(2, action: steamingAction)
        kettle.addClick(2, val: false)
		kettle.addSound(1, soundFile: "kettle")
        spriteContainer.addChild(kettle)
        
        let freezer = AnimatedStateSprite(imageNamed: "house_kitchen_freezer")
        freezer.anchorPoint = CGPoint.zero
        freezer.position = CGPoint(x: 1043, y: 212)
        z += 1
        freezer.zPosition =  z
		touchableSprites.append(freezer)
        let freezerOpening:[SKTexture] = [
            SKTexture(imageNamed: "house_kitchen_freezer1"),
            SKTexture(imageNamed: "house_kitchen_freezer2"),
            SKTexture(imageNamed: "house_kitchen_freezer3"),
            SKTexture(imageNamed: "house_kitchen_freezer4"),
			SKTexture(imageNamed: "house_kitchen_freezer5"),
            SKTexture(imageNamed: "house_kitchen_freezer6")
        ]
        let openingAction = SKAction.repeat(SKAction.animate(with: freezerOpening, timePerFrame: 0.06, resize: false, restore: false), count: 1)
        freezer.addAction(1, action: openingAction)
        freezer.addClick(1, val: false)
        let closeAction = SKAction.reversed(openingAction)()
        freezer.addAction(3, action: closeAction)
        freezer.addClick(2, val: true)
        freezer.addClick(3, val: false)
        spriteContainer.addChild(freezer)
        
        let fridge = AnimatedStateSprite(imageNamed: "house_kitchen_fridge")
        fridge.anchorPoint = CGPoint.zero
        fridge.position = CGPoint(x: 1043, y: 140)
        z += 1
        fridge.zPosition =  z
		touchableSprites.append(fridge)
        let fridgeOpening:[SKTexture] = [
            SKTexture(imageNamed: "house_kitchen_fridge1"),
            SKTexture(imageNamed: "house_kitchen_fridge2"),
            SKTexture(imageNamed: "house_kitchen_fridge3"),
            SKTexture(imageNamed: "house_kitchen_fridge4"),
			SKTexture(imageNamed: "house_kitchen_fridge5"),
            SKTexture(imageNamed: "house_kitchen_fridge6")
        ]
        let openingAction2 = SKAction.repeat(SKAction.animate(with: fridgeOpening, timePerFrame: 0.06, resize: false, restore: false), count: 1)
        fridge.addAction(1, action: openingAction2)
        fridge.addClick(1, val: false)
        let closeAction2 = SKAction.reversed(openingAction2)()
        fridge.addAction(3, action: closeAction2)
        fridge.addClick(2, val: true)
        fridge.addClick(3, val: false)
        spriteContainer.addChild(fridge)
		
		let bubbles = AnimatedStateSprite(imageNamed: "bubbles1")
		bubbles.anchorPoint = CGPoint.zero
		bubbles.position = CGPoint(x: 916, y: 205)
        z += 1
		bubbles.zPosition =  z
		touchableSprites.append(bubbles)
		let bubbleTextures:[SKTexture] = [
			SKTexture(imageNamed: "bubbles1"),
            SKTexture(imageNamed: "bubbles2"),
            SKTexture(imageNamed: "bubbles3"),
            SKTexture(imageNamed: "bubbles4"),
			SKTexture(imageNamed: "bubbles5"),
			SKTexture(imageNamed: "bubbles6"),
			SKTexture(imageNamed: "bubbles7"),
            SKTexture(imageNamed: "bubbles8")
		]
		let bubbleAction = SKAction.repeatForever(SKAction.animate(with: bubbleTextures, timePerFrame: 0.08, resize: false, restore: false))
		bubbles.addAction(0, action: bubbleAction)
		bubbles.addAction(1, action: bubbleAction)
		bubbles.addEvent(1, topic: GameScene.TOPIC_START_BUBBLES)
        bubbles.run(bubbleAction)
		spriteContainer.addChild(bubbles)
		starSprites.append(bubbles)
        
        let adultBed = SKSpriteNode(imageNamed: "house_adult_bed")
        adultBed.anchorPoint = CGPoint.zero
        adultBed.position = CGPoint(x: 487, y: 312)
        z += 1
        adultBed.zPosition =  z
        spriteContainer.addChild(adultBed)
        
        let adultVanity = AnimatedStateSprite(imageNamed: "house_adult_vanity")
        adultVanity.anchorPoint = CGPoint.zero
        adultVanity.position = CGPoint(x: 673, y: 312)
        z += 1
        adultVanity.zPosition =  z
        
        touchableSprites.append(adultVanity)
        let vanityAction:[SKTexture] = [
            SKTexture(imageNamed: "house_adult_vanity1"),
            SKTexture(imageNamed: "house_adult_vanity2"),
            SKTexture(imageNamed: "house_adult_vanity3"),
            SKTexture(imageNamed: "house_adult_vanity4"),
            SKTexture(imageNamed: "house_adult_vanity5"),
            SKTexture(imageNamed: "house_adult_vanity6"),
            SKTexture(imageNamed: "house_adult_vanity7"),
            SKTexture(imageNamed: "house_adult_vanity8"),
            SKTexture(imageNamed: "house_adult_vanity9"),
            SKTexture(imageNamed: "house_adult_vanity10"),
            SKTexture(imageNamed: "house_adult_vanity11"),
            SKTexture(imageNamed: "house_adult_vanity12"),
            SKTexture(imageNamed: "house_adult_vanity12"),
            SKTexture(imageNamed: "house_adult_vanity12")
        ]
        let vanityAction3 = SKAction.repeat(SKAction.animate(with: vanityAction, timePerFrame: 0.12, resize: false, restore: false), count: 1)
        adultVanity.addAction(1, action: vanityAction3)
        adultVanity.addClick(1, val: false)
        adultVanity.addEvent(0, topic: GameScene.TOPIC_START_CARD)
 
        spriteContainer.addChild(adultVanity)
        premiumSprites.append(adultVanity)
        
        let wardrobe = AnimatedStateSprite(imageNamed: "house_adult_wardrobe")
        wardrobe.anchorPoint = CGPoint.zero
        wardrobe.position = CGPoint(x: 747, y: 312)
        z += 1
        wardrobe.zPosition =  z
		touchableSprites.append(wardrobe)
        let wardrobeOpening:[SKTexture] = [
            SKTexture(imageNamed: "house_adult_wardrobe1"),
            SKTexture(imageNamed: "house_adult_wardrobe2"),
            SKTexture(imageNamed: "house_adult_wardrobe3"),
            SKTexture(imageNamed: "house_adult_wardrobe4"),
			SKTexture(imageNamed: "house_adult_wardrobe5"),
			SKTexture(imageNamed: "house_adult_wardrobe6"),
			SKTexture(imageNamed: "house_adult_wardrobe7"),
            SKTexture(imageNamed: "house_adult_wardrobe8")
        ]
        let openingAction3 = SKAction.repeat(SKAction.animate(with: wardrobeOpening, timePerFrame: 0.06, resize: false, restore: false), count: 1)
        wardrobe.addAction(1, action: openingAction3)
        wardrobe.addClick(1, val: false)
        wardrobe.addEvent(0, topic: GameScene.TOPIC_START_DRESSUP)
        spriteContainer.addChild(wardrobe)
		premiumSprites.append(wardrobe)
        
        let lightA = AnimatedStateSprite(imageNamed: "house_light_a1")
        lightA.anchorPoint = CGPoint.zero
        lightA.position = CGPoint(x: 670, y: 401)
        z += 1
        lightA.zPosition =  z
		touchableSprites.append(lightA)
        lightA.addTexture(1, texture: SKTexture(imageNamed: "house_light_a2"))
        lightA.addSound(0, soundFile: "pullchainslowon")
        lightA.addSound(1, soundFile: "pullchainslowon")
        spriteContainer.addChild(lightA)
        
        let lightB = AnimatedStateSprite(imageNamed: "house_light_b1")
        lightB.anchorPoint = CGPoint.zero
        lightB.position = CGPoint(x: 522, y: 418)
        z += 1
        lightB.zPosition =  z
		touchableSprites.append(lightB)
        lightB.addTexture(1, texture: SKTexture(imageNamed: "house_light_b2"))
        lightB.addSound(0, soundFile: "pullchainslowon")
        lightB.addSound(1, soundFile: "pullchainslowon")
        spriteContainer.addChild(lightB)
        
        let blocks = AnimatedStateSprite(imageNamed: "house_toys_blocks")
        blocks.anchorPoint = CGPoint.zero
        blocks.position = CGPoint(x: 1020, y: 490)
        z += 1
        blocks.zPosition =  z
		touchableSprites.append(blocks)
        let blocksAnim:[SKTexture] = [
            SKTexture(imageNamed: "house_toys_blocks1"),
            SKTexture(imageNamed: "house_toys_blocks2"),
            SKTexture(imageNamed: "house_toys_blocks3"),
            SKTexture(imageNamed: "house_toys_blocks4"),
			SKTexture(imageNamed: "house_toys_blocks5"),
			SKTexture(imageNamed: "house_toys_blocks6"),
			SKTexture(imageNamed: "house_toys_blocks7"),
            SKTexture(imageNamed: "house_toys_blocks8")
        ]
        let blocksAction = SKAction.repeat(SKAction.animate(with: blocksAnim, timePerFrame: 0.06, resize: false, restore: false), count: 1)
        blocks.addAction(1, action: blocksAction)
        blocks.addClick(1, val: false)
        blocks.addEvent(0, topic: GameScene.TOPIC_START_PUZZLE)
        spriteContainer.addChild(blocks)
		starSprites.append(blocks)
        
        let horse = AnimatedStateSprite(imageNamed: "house_toys_horse")
        horse.anchorPoint = CGPoint.zero
        horse.position = CGPoint(x: 925, y: 490)
        z += 1
        horse.zPosition =  z
		touchableSprites.append(horse)
        let horseAnim:[SKTexture] = [
            SKTexture(imageNamed: "house_toys_horse1"),
            SKTexture(imageNamed: "house_toys_horse2"),
            SKTexture(imageNamed: "house_toys_horse3"),
            SKTexture(imageNamed: "house_toys_horse2"),
			SKTexture(imageNamed: "house_toys_horse1"),
			SKTexture(imageNamed: "house_toys_horse"),
			SKTexture(imageNamed: "house_toys_horse4"),
            SKTexture(imageNamed: "house_toys_horse5"),
			SKTexture(imageNamed: "house_toys_horse6"),
			SKTexture(imageNamed: "house_toys_horse5"),
			SKTexture(imageNamed: "house_toys_horse4")
        ]
        let horseAction = SKAction.repeat(SKAction.animate(with: horseAnim, timePerFrame: 0.06, resize: false, restore: false), count: 3)
        horse.addAction(1, action: horseAction)
        horse.addClick(1, val: false)
        spriteContainer.addChild(horse)
        
        let bat = AnimatedStateSprite(imageNamed: "house_toys_bat")
        bat.anchorPoint = CGPoint.zero
        bat.position = CGPoint(x: 802, y: 490)
        z += 1
        bat.zPosition =  z
		touchableSprites.append(bat)
        let batAnim:[SKTexture] = [
            SKTexture(imageNamed: "house_toys_bat1"),
            SKTexture(imageNamed: "house_toys_bat2"),
            SKTexture(imageNamed: "house_toys_bat3"),
            SKTexture(imageNamed: "house_toys_bat4"),
			SKTexture(imageNamed: "house_toys_bat5"),
			SKTexture(imageNamed: "house_toys_bat6"),
			SKTexture(imageNamed: "house_toys_bat7"),
			SKTexture(imageNamed: "house_toys_bat8")
        ]
        let batAction = SKAction.repeat(SKAction.animate(with: batAnim, timePerFrame: 0.06, resize: false, restore: false), count: 1)
        bat.addAction(1, action: batAction)
        bat.addClick(1, val: false)
		let batAnim2:[SKTexture] = [
            SKTexture(imageNamed: "house_toys_bat9"),
            SKTexture(imageNamed: "house_toys_bat10"),
            SKTexture(imageNamed: "house_toys_bat11"),
            SKTexture(imageNamed: "house_toys_bat12"),
			SKTexture(imageNamed: "house_toys_bat13"),
			SKTexture(imageNamed: "house_toys_bat14")
        ]
        let batAction2 = SKAction.repeat(SKAction.animate(with: batAnim2, timePerFrame: 0.06, resize: false, restore: false), count: 1)
        bat.addAction(2, action: batAction2)
        bat.addClick(2, val: false)
		bat.addSound(2, soundFile: "baseball_bat")
		let batAnim3:[SKTexture] = [
            SKTexture(imageNamed: "house_toys_bat15"),
            SKTexture(imageNamed: "house_toys_bat16"),
            SKTexture(imageNamed: "house_toys_bat17"),
            SKTexture(imageNamed: "house_toys_bat18"),
			SKTexture(imageNamed: "house_toys_bat19"),
			SKTexture(imageNamed: "house_toys_bat20"),
			SKTexture(imageNamed: "house_toys_bat21"),
			SKTexture(imageNamed: "house_toys_bat22")
        ]
        let batAction3 = SKAction.repeat(SKAction.animate(with: batAnim3, timePerFrame: 0.06, resize: false, restore: false), count: 1)
        bat.addAction(3, action: batAction3)
        bat.addClick(3, val: false)
		bat.addSound(3, soundFile: "glass_break")
        spriteContainer.addChild(bat)
        
        let piano = AnimatedStateSprite(imageNamed: "house_music_piano")
        piano.anchorPoint = CGPoint.zero
        piano.position = CGPoint(x: 625, y: 490)
        z += 1
        piano.zPosition =  z
        touchableSprites.append(piano)
		let pianoAnim:[SKTexture] = [
            SKTexture(imageNamed: "house_music_piano1"),
            SKTexture(imageNamed: "house_music_piano2"),
            SKTexture(imageNamed: "house_music_piano3")
        ]
        let pianoAction = SKAction.animate(with: pianoAnim, timePerFrame: 0.12, resize: false, restore: false)
		let pianoReverse = SKAction.reversed(pianoAction)()
		let pianoSeqAction = SKAction.sequence([pianoAction, pianoReverse])
		let pianoRepeatAction = SKAction.repeat(pianoSeqAction, count: 4)
        piano.addAction(1, action: pianoRepeatAction)
        piano.addClick(1, val: false)
        piano.addSound(1, soundFile: "piano")
        piano.addEvent(0, topic: GameScene.TOPIC_START_SONG)
        premiumSprites.append(piano)
        spriteContainer.addChild(piano)
        
        let trumpet = AnimatedStateSprite(imageNamed: "house_music_trumpet")
        trumpet.anchorPoint = CGPoint.zero
        trumpet.position = CGPoint(x: 660, y: 574)
        z += 1
        trumpet.zPosition =  z
		touchableSprites.append(trumpet)
        let trumpetAnim:[SKTexture] = [
            SKTexture(imageNamed: "house_music_trumpet1"),
            SKTexture(imageNamed: "house_music_trumpet2"),
            SKTexture(imageNamed: "house_music_trumpet3"),
            SKTexture(imageNamed: "house_music_trumpet2")
        ]
        let trumpetAction = SKAction.repeat(SKAction.animate(with: trumpetAnim, timePerFrame: 0.06, resize: false, restore: false), count: 5)
        trumpet.addAction(1, action: trumpetAction)
        trumpet.addClick(1, val: false)
		trumpet.addSound(1, soundFile: "trumpet")
        spriteContainer.addChild(trumpet)
        
        let drums = AnimatedStateSprite(imageNamed: "house_music_drums")
        drums.anchorPoint = CGPoint.zero
        drums.position = CGPoint(x: 585, y: 490)
        z += 1
        drums.zPosition =  z
		touchableSprites.append(drums)
        let drumsAnim:[SKTexture] = [
            SKTexture(imageNamed: "house_music_drums1"),
            SKTexture(imageNamed: "house_music_drums2"),
            SKTexture(imageNamed: "house_music_drums3"),
			SKTexture(imageNamed: "house_music_drums4"),
			SKTexture(imageNamed: "house_music_drums5"),
			SKTexture(imageNamed: "house_music_drums6"),
			SKTexture(imageNamed: "house_music_drums7"),
            SKTexture(imageNamed: "house_music_drums8")
        ]
        let drumsAction = SKAction.repeat(SKAction.animate(with: drumsAnim, timePerFrame: 0.06, resize: false, restore: false), count: 3)
        drums.addAction(1, action: drumsAction)
        drums.addClick(1, val: false)
		drums.addSound(1, soundFile: "drums")
        spriteContainer.addChild(drums)
        
        let guitar = AnimatedStateSprite(imageNamed: "house_music_guitar")
        guitar.anchorPoint = CGPoint.zero
        guitar.position = CGPoint(x: 700, y: 490)
        z += 1
        guitar.zPosition =  z
		touchableSprites.append(guitar)
        let guitarAnim:[SKTexture] = [
            SKTexture(imageNamed: "house_music_guitar1"),
            SKTexture(imageNamed: "house_music_guitar2"),
            SKTexture(imageNamed: "house_music_guitar3"),
			SKTexture(imageNamed: "house_music_guitar2")
        ]
        let guitarAction = SKAction.repeat(SKAction.animate(with: guitarAnim, timePerFrame: 0.06, resize: false, restore: false), count: 5)
        guitar.addAction(1, action: guitarAction)
        guitar.addClick(1, val: false)
		guitar.addSound(1, soundFile: "guitar")
        spriteContainer.addChild(guitar)
        
        let personSprite = PersonNameSprite()
        touchableSprites.append(personSprite)
        personSprite.position = CGPoint(x: self.size.width - (100 * lfScale), y: 10)
        z += 1
        personSprite.zPosition =  z
        personSprite.size.width = 50 * lfScale
        personSprite.size.height = 50 * lfScale
        personSprite.person = selectedPerson
        personSprite.showLabel = false
        personSprite.topic = LittleFamilyScene.TOPIC_START_CHOOSE
        self.addChild(personSprite)
		
		let settingsSprite = AnimatedStateSprite(imageNamed: "settings")
		settingsSprite.size.height = 30 * lfScale
		settingsSprite.size.width = 30 * lfScale
		settingsSprite.position = CGPoint(x: self.size.width - settingsSprite.size.width, y: settingsSprite.size.height + 8)
        z += 1
		settingsSprite.zPosition =  z
		settingsSprite.addEvent(0, topic: LittleFamilyScene.TOPIC_START_SETTINGS)
		touchableSprites.append(settingsSprite)
		self.addChild(settingsSprite)
		
		starWait = Int(arc4random_uniform(200))
        
        EventHandler.getInstance().subscribe(GameScene.TOPIC_START_MATCH, listener: self)
        EventHandler.getInstance().subscribe(GameScene.TOPIC_START_DRESSUP, listener: self)
        EventHandler.getInstance().subscribe(GameScene.TOPIC_START_PUZZLE, listener: self)
        EventHandler.getInstance().subscribe(GameScene.TOPIC_START_SCRATCH, listener: self)
        EventHandler.getInstance().subscribe(GameScene.TOPIC_START_COLORING, listener: self)
        EventHandler.getInstance().subscribe(GameScene.TOPIC_START_TREE, listener: self)
		EventHandler.getInstance().subscribe(GameScene.TOPIC_START_BUBBLES, listener: self)
        EventHandler.getInstance().subscribe(GameScene.TOPIC_START_SONG, listener: self)
        EventHandler.getInstance().subscribe(GameScene.TOPIC_START_CARD, listener: self)
        EventHandler.getInstance().subscribe(GameScene.TOPIC_START_BIRD, listener: self)
        self.speak("Hi")
		let delayAction = SKAction.wait(forDuration: 0.35)
        run(delayAction, completion: {
            self.sayGivenName(self.selectedPerson!)
        }) 
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        EventHandler.getInstance().unSubscribe(GameScene.TOPIC_START_MATCH, listener: self)
        EventHandler.getInstance().unSubscribe(GameScene.TOPIC_START_DRESSUP, listener: self)
        EventHandler.getInstance().unSubscribe(GameScene.TOPIC_START_PUZZLE, listener: self)
        EventHandler.getInstance().unSubscribe(GameScene.TOPIC_START_SCRATCH, listener: self)
        EventHandler.getInstance().unSubscribe(GameScene.TOPIC_START_COLORING, listener: self)
        EventHandler.getInstance().unSubscribe(GameScene.TOPIC_START_TREE, listener: self)
		EventHandler.getInstance().unSubscribe(GameScene.TOPIC_START_BUBBLES, listener: self)
        EventHandler.getInstance().unSubscribe(GameScene.TOPIC_START_SONG, listener: self)
        EventHandler.getInstance().unSubscribe(GameScene.TOPIC_START_CARD, listener: self)
        EventHandler.getInstance().unSubscribe(GameScene.TOPIC_START_BIRD, listener: self)
    }
    
    func pinched(_ sender:UIPinchGestureRecognizer){
        if sender.state == UIGestureRecognizerState.ended || sender.state == UIGestureRecognizerState.cancelled {
            previousScale = nil
        }
        else if sender.state == UIGestureRecognizerState.began {
            previousScale = sender.scale
        }
        else if previousScale != nil {
            if sender.scale != previousScale! {
                var diff = (sender.scale - previousScale!) / 20
                if diff > 0 {
                    diff = diff / 6
                }
                lfScale += diff
                print("pinched \(lfScale) diff=\(diff)")
                if lfScale < minScale {
                    lfScale = minScale
                }
                if lfScale > maxScale {
                    lfScale = maxScale
                }
                let zoomIn = SKAction.scale(to: lfScale, duration:0)
                spriteContainer.run(zoomIn)
                
                let zoomIn2 = SKAction.scale(to: lfScale, duration:0)
                background.run(zoomIn2)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        for touch in touches {
            lastPoint = touch.location(in: self)
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        var nextPoint = CGPoint(x: 0,y: 0)
        for touch in touches {
            nextPoint = touch.location(in: self)
        }
        
        clipX = nextPoint.x - lastPoint.x;
        clipY = nextPoint.y - lastPoint.y;
		
		if abs(clipX) > 8 || abs(clipY) > 8 {
			moved = true
		}
        
        background.position.y += clipY;
        if background.position.y > 0 {
            background.position.y = 0
        }
        if background.position.y < self.size.height - (oHeight * lfScale) {
            background.position.y = self.size.height - (oHeight * lfScale)
        }
        
        spriteContainer.position.y += clipY
        if spriteContainer.position.y > minY*lfScale {
            spriteContainer.position.y = minY*lfScale
        }
        if spriteContainer.position.y < self.size.height - (oHeight * lfScale)  {
            spriteContainer.position.y = self.size.height - (oHeight * lfScale)
        }
        
        spriteContainer.position.x += clipX
        if spriteContainer.position.x < self.size.width - (oWidth * lfScale) {
            spriteContainer.position.x = self.size.width - (oWidth * lfScale)
        }
        if spriteContainer.position.x > (oWidth * lfScale) - self.size.width {
            spriteContainer.position.x = (oWidth * lfScale) - self.size.width
        }
        
        lastPoint = nextPoint
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        previousScale = nil
        if !moved {
            for touch in touches {
                lastPoint = touch.location(in: self)
                let touchedNode = atPoint(lastPoint)
                if self.touchableSprites.contains(touchedNode) {
                    touchedNode.touchesEnded(touches, with: event)
                }
				else if touchedNode.parent != nil && self.touchableSprites.contains(touchedNode.parent!) {
					touchedNode.parent!.touchesEnded(touches, with: event)
				}
                else if personLeaves!.children.contains(touchedNode) == true {
                    personLeaves!.touchesEnded(touches, with: event)
                }
            }
        }
        moved = false
    }
   
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        super.update(currentTime)
		var notRemoving = [AnimatedStateSprite]()
		for sprite in updateSprites {
			if sprite.removeMe == true {
                sprite.removeFromParent()
			} else {
				sprite.update()
                notRemoving.append(sprite)
			}
		}
		
		self.updateSprites = notRemoving
		
		if starWait > 0 {
			starWait -= 1
		} else {
			starWait = 70 + Int(arc4random_uniform(70))
			let s = Int(arc4random_uniform(UInt32(starSprites.count)))
			let sprite = starSprites[s]
            showStars(sprite.frame, starsInRect: true, count: 2, container: spriteContainer)
		}
        
        if pStarWait > 0 {
            pStarWait -= 1
        } else {
            pStarWait = 70 + Int(arc4random_uniform(70))
            let s = Int(arc4random_uniform(UInt32(premiumSprites.count)))
            let sprite = premiumSprites[s]
            showRedStars(sprite.frame, starsInRect: true, count: 2, container: spriteContainer)
        }
    }
    
    override func onEvent(_ topic: String, data: NSObject?) {
        super.onEvent(topic, data: data)
    }

}
