//
//  GameScene.swift
//  Little Family Tree
//
//  Created by Melissa on 9/12/15.
//  Copyright (c) 2015 Melissa. All rights reserved.
//

import SpriteKit

class GameScene: LittleFamilyScene {
    static var TOPIC_START_MATCH = "start_match"
    static var TOPIC_START_DRESSUP = "start_dressup"
    static var TOPIC_START_PUZZLE = "start_puzzle"
	static var TOPIC_START_SCRATCH = "start_scratch"
	static var TOPIC_START_COLORING = "start_coloring"
	static var TOPIC_START_TREE = "start_tree"
	static var TOPIC_START_BUBBLES = "start_bubbles"
    
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
    var minScale : CGFloat = 0.5
    var maxScale : CGFloat = 2.0
    var moved = false
	
	var starWait = 100
    
    var previousScale:CGFloat? = nil
    
    var personLeaves : PersonLeavesButton?
    
    override func didMoveToView(view: SKView) {
		super.didMoveToView(view)
        let pinch:UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: Selector("pinched:"))
        view.addGestureRecognizer(pinch)
        
        /* Setup your scene here */
        var z:CGFloat = 0
        background = SKSpriteNode(imageNamed: "house_background2")
        background.anchorPoint = CGPoint.zero
        background.position = CGPoint.zero
        background.zPosition = z++
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
        background.size = CGSizeMake(self.size.width * 3, maxHeight);
        self.addChild(background);
        
        spriteContainer = SKSpriteNode()
        spriteContainer.anchorPoint = CGPoint.zero
        spriteContainer.position = CGPointMake(clipX, minY)
        spriteContainer.setScale(lfScale)
        spriteContainer.zPosition = z++
        self.addChild(spriteContainer)
        
        let cloud1 = MovingAnimatedStateSprite(imageNamed: "house_cloud1")
        cloud1.anchorPoint = CGPoint.zero
        cloud1.position = CGPointMake(0, oHeight - cloud1.size.height - 25)
        cloud1.zPosition = z++
        touchableSprites.append(cloud1)
        cloud1.addTexture(1, texture: SKTexture(imageNamed: "house_cloud1a"))
        cloud1.addTexture(2, texture: SKTexture(imageNamed: "house_cloud1b"))
        cloud1.addTexture(3, texture: SKTexture(imageNamed: "house_cloud1c"))
        let cloudrain:[SKTexture] = [
            SKTexture(imageNamed: "house_cloud1d"),
            SKTexture(imageNamed: "house_cloud1e")
        ]
        let rainAction = SKAction.repeatAction(SKAction.animateWithTextures(cloudrain, timePerFrame: 0.06, resize: false, restore: false), count: 20)
        cloud1.addAction(4, action: rainAction)
        cloud1.addSound(4, soundFile: "rain")
		cloud1.moveAction = SKAction.repeatActionForever(SKAction.moveByX(5, y:0, duration: 1))
		cloud1.maxX = oWidth
		cloud1.maxY = oHeight
        spriteContainer.addChild(cloud1)
		updateSprites.append(cloud1)
		cloud1.runAction(cloud1.moveAction!)
        
        let cloud2 = MovingAnimatedStateSprite(imageNamed: "house_cloud2")
        cloud2.anchorPoint = CGPoint.zero
        cloud2.position = CGPointMake(minY + oWidth*0.75, oHeight - cloud1.size.height - 15)
        cloud2.zPosition = z++
		cloud2.moveAction = SKAction.repeatActionForever(SKAction.moveByX(5, y:0, duration: 1))
		cloud2.maxX = oWidth
		cloud2.maxY = oHeight
        spriteContainer.addChild(cloud2)
		updateSprites.append(cloud2)
		cloud2.runAction(cloud2.moveAction!)
        
        let tree = SKSpriteNode(imageNamed: "house_tree1")
        tree.anchorPoint = CGPoint.zero
        tree.position = CGPointMake(50, oHeight - tree.size.height - 250)
        tree.zPosition = z++
        spriteContainer.addChild(tree)
        
        let flowers1 = AnimatedStateSprite(imageNamed: "house_flowers_a1")
        flowers1.anchorPoint = CGPoint.zero
        flowers1.position = CGPointMake(90+flowers1.size.width, 200-flowers1.size.height)
        flowers1.xScale = flowers1.xScale * -1
        flowers1.zPosition = z++
        touchableSprites.append(flowers1)
        let flowersSpin:[SKTexture] = [
            SKTexture(imageNamed: "house_flowers_a2"),
            SKTexture(imageNamed: "house_flowers_a3"),
            SKTexture(imageNamed: "house_flowers_a4"),
            SKTexture(imageNamed: "house_flowers_a5")
        ]
        let spinAction = SKAction.repeatAction(SKAction.animateWithTextures(flowersSpin, timePerFrame: 0.06, resize: false, restore: false), count: 3)
        flowers1.addAction(1, action: spinAction)
        flowers1.addSound(1, soundFile: "spinning")
        spriteContainer.addChild(flowers1)
        
        let flowers2 = AnimatedStateSprite(imageNamed: "house_flowers_a1")
        flowers2.anchorPoint = CGPoint.zero
        flowers2.position = CGPointMake(265, 200-flowers2.size.height)
        flowers2.zPosition = z++
        touchableSprites.append(flowers2)
        flowers2.addAction(1, action: spinAction)
        flowers2.addSound(1, soundFile: "spinning")
        spriteContainer.addChild(flowers2)
		
		personLeaves = PersonLeavesButton()
		personLeaves?.anchorPoint = CGPoint.zero
		personLeaves?.size.width = 65
		personLeaves?.size.height = 65
		personLeaves?.position = CGPointMake(245, 455-(personLeaves?.size.height)!)
		personLeaves?.zPosition = z++
		touchableSprites.append(personLeaves!)
		spriteContainer.addChild(personLeaves!)
		starSprites.append(personLeaves!)
		
		DataService.getInstance().getFamilyMembers(selectedPerson!, loadSpouse: true, onCompletion: { people, err in
			self.personLeaves?.people = people
		});
		
        
        let tileY:CGFloat = 600
        let tile01 = SKSpriteNode(imageNamed: "house_rooms_0_1")
        tile01.anchorPoint = CGPoint.zero
        tile01.position = CGPointMake(450, tileY - tile01.size.height)
        tile01.zPosition = z++
        spriteContainer.addChild(tile01)
        
        let tile02 = SKSpriteNode(imageNamed: "house_rooms_0_2")
        tile02.anchorPoint = CGPoint.zero
        tile02.position = CGPointMake(450, tileY - (tile01.size.height*2))
        tile02.zPosition = z++
        spriteContainer.addChild(tile02)
        
        let tile03 = SKSpriteNode(imageNamed: "house_rooms_0_3")
        tile03.anchorPoint = CGPoint.zero
        tile03.position = CGPointMake(450, tileY - (tile01.size.height*3))
        tile03.zPosition = z++
        spriteContainer.addChild(tile03)
        
        let tile04 = SKSpriteNode(imageNamed: "house_rooms_0_4")
        tile04.anchorPoint = CGPoint.zero
        tile04.position = CGPointMake(450, tileY - (tile01.size.height*4))
        tile04.zPosition = z++
        spriteContainer.addChild(tile04)
        
        
        let tile10 = SKSpriteNode(imageNamed: "house_rooms_1_0")
        tile10.anchorPoint = CGPoint.zero
        tile10.position = CGPointMake(450 + tile10.size.width, tileY)
        tile10.zPosition = z++
        spriteContainer.addChild(tile10)
        
        let tile11 = SKSpriteNode(imageNamed: "house_rooms_1_1")
        tile11.anchorPoint = CGPoint.zero
        tile11.position = CGPointMake(450 + tile10.size.width, tileY - tile11.size.height)
        tile11.zPosition = z++
        spriteContainer.addChild(tile11)
        
        let tile12 = SKSpriteNode(imageNamed: "house_rooms_1_2")
        tile12.anchorPoint = CGPoint.zero
        tile12.position = CGPointMake(450 + tile10.size.width, tileY - (tile12.size.height*2))
        tile12.zPosition = z++
        spriteContainer.addChild(tile12)
        
        let tile13 = SKSpriteNode(imageNamed: "house_rooms_1_3")
        tile13.anchorPoint = CGPoint.zero
        tile13.position = CGPointMake(450 + tile10.size.width, tileY - (tile13.size.height*3))
        tile13.zPosition = z++
        spriteContainer.addChild(tile13)
        
        let tile14 = SKSpriteNode(imageNamed: "house_rooms_1_4")
        tile14.anchorPoint = CGPoint.zero
        tile14.position = CGPointMake(450 + tile10.size.width, tileY - (tile14.size.height*4))
        tile14.zPosition = z++
        spriteContainer.addChild(tile14)
        
        
        let tile20 = SKSpriteNode(imageNamed: "house_rooms_2_0")
        tile20.anchorPoint = CGPoint.zero
        tile20.position = CGPointMake(450 + (tile20.size.width*2), tileY)
        tile20.zPosition = z++
        spriteContainer.addChild(tile20)
        
        let tile21 = SKSpriteNode(imageNamed: "house_rooms_2_1")
        tile21.anchorPoint = CGPoint.zero
        tile21.position = CGPointMake(450 + (tile20.size.width*2), tileY - tile21.size.height)
        tile21.zPosition = z++
        spriteContainer.addChild(tile21)
        
        let tile22 = SKSpriteNode(imageNamed: "house_rooms_2_2")
        tile22.anchorPoint = CGPoint.zero
        tile22.position = CGPointMake(450 + (tile20.size.width*2), tileY - (tile22.size.height*2))
        tile22.zPosition = z++
        spriteContainer.addChild(tile22)
        
        let tile23 = SKSpriteNode(imageNamed: "house_rooms_2_3")
        tile23.anchorPoint = CGPoint.zero
        tile23.position = CGPointMake(450 + (tile20.size.width*2), tileY - (tile23.size.height*3))
        tile23.zPosition = z++
        spriteContainer.addChild(tile23)
        
        let tile24 = SKSpriteNode(imageNamed: "house_rooms_2_4")
        tile24.anchorPoint = CGPoint.zero
        tile24.position = CGPointMake(450 + (tile20.size.width*2), tileY - (tile24.size.height*4))
        tile24.zPosition = z++
        spriteContainer.addChild(tile24)
        
        let tile30 = SKSpriteNode(imageNamed: "house_rooms_3_0")
        tile30.anchorPoint = CGPoint.zero
        tile30.position = CGPointMake(450 + (tile30.size.width*3), tileY)
        tile30.zPosition = z++
        spriteContainer.addChild(tile30)
        
        let tile31 = SKSpriteNode(imageNamed: "house_rooms_3_1")
        tile31.anchorPoint = CGPoint.zero
        tile31.position = CGPointMake(450 + (tile30.size.width*3), tileY - tile31.size.height)
        tile31.zPosition = z++
        spriteContainer.addChild(tile31)
        
        let tile32 = SKSpriteNode(imageNamed: "house_rooms_3_2")
        tile32.anchorPoint = CGPoint.zero
        tile32.position = CGPointMake(450 + (tile30.size.width*3), tileY - (tile32.size.height*2))
        tile32.zPosition = z++
        spriteContainer.addChild(tile32)
        
        let tile33 = SKSpriteNode(imageNamed: "house_rooms_3_3")
        tile33.anchorPoint = CGPoint.zero
        tile33.position = CGPointMake(450 + (tile30.size.width*3), tileY - (tile33.size.height*3))
        tile33.zPosition = z++
        spriteContainer.addChild(tile33)
        
        let tile34 = SKSpriteNode(imageNamed: "house_rooms_3_4")
        tile34.anchorPoint = CGPoint.zero
        tile34.position = CGPointMake(450 + (tile30.size.width*3), tileY - (tile34.size.height*4))
        tile34.zPosition = z++
        spriteContainer.addChild(tile34)

        
        let tile41 = SKSpriteNode(imageNamed: "house_rooms_4_1")
        tile41.anchorPoint = CGPoint.zero
        tile41.position = CGPointMake(450 + (tile41.size.width*4), tileY - tile41.size.height)
        tile41.zPosition = z++
        spriteContainer.addChild(tile41)
        
        let tile42 = SKSpriteNode(imageNamed: "house_rooms_4_2")
        tile42.anchorPoint = CGPoint.zero
        tile42.position = CGPointMake(450 + (tile41.size.width*4), tileY - (tile42.size.height*2))
        tile42.zPosition = z++
        spriteContainer.addChild(tile42)
        
        let tile43 = SKSpriteNode(imageNamed: "house_rooms_4_3")
        tile43.anchorPoint = CGPoint.zero
        tile43.position = CGPointMake(450 + (tile41.size.width*4), tileY - (tile43.size.height*3))
        tile43.zPosition = z++
        spriteContainer.addChild(tile43)
        
        let tile44 = SKSpriteNode(imageNamed: "house_rooms_4_4")
        tile44.anchorPoint = CGPoint.zero
        tile44.position = CGPointMake(450 + (tile41.size.width*4), tileY - (tile44.size.height*4))
        tile44.zPosition = z++
        spriteContainer.addChild(tile44)


        let couch = SKSpriteNode(imageNamed: "house_familyroom_couch")
        couch.anchorPoint = CGPoint.zero
        couch.position = CGPointMake(555, 140)
        couch.zPosition = z++
        spriteContainer.addChild(couch)
        
        let table1 = SKSpriteNode(imageNamed: "house_familyroom_table")
        table1.anchorPoint = CGPoint.zero
        table1.position = CGPointMake(491, 140)
        table1.zPosition = z++
        spriteContainer.addChild(table1)
        
        let table2 = SKSpriteNode(imageNamed: "house_familyroom_table")
        table2.anchorPoint = CGPoint.zero
        table2.position = CGPointMake(735, 140)
        table2.zPosition = z++
        spriteContainer.addChild(table2)
        
        let lamp1 = AnimatedStateSprite(imageNamed: "house_familyroom_lamp1")
        lamp1.anchorPoint = CGPoint.zero
        lamp1.position = CGPointMake(482, 170)
        lamp1.zPosition = z++
        touchableSprites.append(lamp1)
        lamp1.addTexture(1, texture: SKTexture(imageNamed: "house_familyroom_lamp2"))
        lamp1.addSound(0, soundFile: "pullchainslowon")
        lamp1.addSound(1, soundFile: "pullchainslowon")
        spriteContainer.addChild(lamp1)
        
        let lamp2 = AnimatedStateSprite(imageNamed: "house_familyroom_lamp1")
        lamp2.anchorPoint = CGPoint.zero
        lamp2.position = CGPointMake(725, 170)
        lamp2.zPosition = z++
        touchableSprites.append(lamp2)
        lamp2.addTexture(1, texture: SKTexture(imageNamed: "house_familyroom_lamp2"))
        lamp2.addSound(0, soundFile: "pullchainslowon")
        lamp2.addSound(1, soundFile: "pullchainslowon")
        spriteContainer.addChild(lamp2)
        
        let frame = AnimatedStateSprite(imageNamed: "house_familyroom_frame")
        frame.anchorPoint = CGPoint.zero
        frame.position = CGPointMake(612, 225)
        frame.zPosition = z++
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
        let jumpAction = SKAction.repeatAction(SKAction.animateWithTextures(jumping, timePerFrame: 0.06, resize: false, restore: false), count: 1)
        frame.addAction(1, action: jumpAction)
        frame.addClick(1, val: false)
        frame.addEvent(0, topic: GameScene.TOPIC_START_MATCH)
        spriteContainer.addChild(frame)
		starSprites.append(frame)
        
        let childBed = SKSpriteNode(imageNamed: "house_chilldroom_bed")
        childBed.anchorPoint = CGPoint.zero
        childBed.position = CGPointMake(827, 307)
        childBed.zPosition = z++
        spriteContainer.addChild(childBed)
        
        let childPaint = AnimatedStateSprite(imageNamed: "house_chilldroom_paint")
        childPaint.anchorPoint = CGPoint.zero
        childPaint.position = CGPointMake(1000, 312)
        childPaint.zPosition = z++
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
        let paintAction = SKAction.repeatAction(SKAction.animateWithTextures(painting, timePerFrame: 0.06, resize: false, restore: false), count: 1)
        childPaint.addAction(1, action: paintAction)
        childPaint.addClick(1, val: false)
		childPaint.addEvent(0, topic: GameScene.TOPIC_START_COLORING)
        spriteContainer.addChild(childPaint)
		starSprites.append(childPaint)
        
        let childDesk = AnimatedStateSprite(imageNamed: "house_chilldroom_desk")
        childDesk.anchorPoint = CGPoint.zero
        childDesk.position = CGPointMake(1065, 312)
        childDesk.zPosition = z++
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
        let eraseAction = SKAction.repeatAction(SKAction.animateWithTextures(erasing, timePerFrame: 0.06, resize: false, restore: false), count: 1)
        childDesk.addAction(1, action: eraseAction)
        childDesk.addClick(1, val: false)
		childDesk.addEvent(0, topic: GameScene.TOPIC_START_SCRATCH)
        childDesk.addSound(1, soundFile: "erasing")
        spriteContainer.addChild(childDesk)
		starSprites.append(childDesk)
        
        let teddy = AnimatedStateSprite(imageNamed: "house_chilldroom_teddy")
        teddy.anchorPoint = CGPoint.zero
        teddy.position = CGPointMake(928, 310)
        teddy.zPosition = z++
        touchableSprites.append(teddy)
        let teddyfalling:[SKTexture] = [
            SKTexture(imageNamed: "house_chilldroom_teddy2"),
            SKTexture(imageNamed: "house_chilldroom_teddy3"),
            SKTexture(imageNamed: "house_chilldroom_teddy4"),
            SKTexture(imageNamed: "house_chilldroom_teddy5"),
            SKTexture(imageNamed: "house_chilldroom_teddy6")
        ]
        let fallaction = SKAction.repeatAction(SKAction.animateWithTextures(teddyfalling, timePerFrame: 0.06, resize: false, restore: false), count: 1)
        teddy.addAction(1, action: fallaction)
        teddy.addClick(1, val: false)
        teddy.addSound(1, soundFile: "slide_whistle_down01")
        let riseaction = SKAction.reversedAction(fallaction)()
        teddy.addAction(3, action: riseaction)
        teddy.addSound(3, soundFile: "slide_whistle_up04")
        teddy.addClick(2, val: true)
        teddy.addClick(3, val: false)
        spriteContainer.addChild(teddy)
        
        
        let kitchenA = SKSpriteNode(imageNamed: "house_kitchen_a")
        kitchenA.anchorPoint = CGPoint.zero
        kitchenA.position = CGPointMake(840, 140)
        kitchenA.zPosition = z++
        spriteContainer.addChild(kitchenA)
        
        let kitchenB = SKSpriteNode(imageNamed: "house_kitchen_b")
        kitchenB.anchorPoint = CGPoint.zero
        kitchenB.position = CGPointMake(kitchenA.position.x+kitchenA.size.width, 140)
        kitchenB.zPosition = z++
        spriteContainer.addChild(kitchenB)
        
        let kitchenC = SKSpriteNode(imageNamed: "house_kitchen_c")
        kitchenC.anchorPoint = CGPoint.zero
        kitchenC.position = CGPointMake(kitchenB.position.x+kitchenB.size.width, 140)
        kitchenC.zPosition = z++
        spriteContainer.addChild(kitchenC)
        
        let kitchenD = SKSpriteNode(imageNamed: "house_kitchen_d")
        kitchenD.anchorPoint = CGPoint.zero
        kitchenD.position = CGPointMake(kitchenC.position.x+kitchenC.size.width, 265)
        kitchenD.zPosition = z++
        spriteContainer.addChild(kitchenD)
        
        let kitchenE = SKSpriteNode(imageNamed: "house_kitchen_e")
        kitchenE.anchorPoint = CGPoint.zero
        kitchenE.position = CGPointMake(kitchenD.position.x+kitchenD.size.width, 140)
        kitchenE.zPosition = z++
        spriteContainer.addChild(kitchenE)
        
        let toaster = AnimatedStateSprite(imageNamed: "house_toaster1")
        toaster.anchorPoint = CGPoint.zero
        toaster.position = CGPointMake(1085, 195)
        toaster.zPosition = z++
		touchableSprites.append(toaster)
        let toastDown:[SKTexture] = [
            SKTexture(imageNamed: "house_toaster2"),
            SKTexture(imageNamed: "house_toaster3")
        ]
        let toastDownAction = SKAction.repeatAction(SKAction.animateWithTextures(toastDown, timePerFrame: 0.06, resize: false, restore: false), count: 1)
        toaster.addAction(1, action: toastDownAction)
        toaster.addClick(1, val: false)
		let toastIn:[SKTexture] = [
            SKTexture(imageNamed: "house_toaster4"),
            SKTexture(imageNamed: "house_toaster4")
        ]
        let toastInAction = SKAction.repeatAction(SKAction.animateWithTextures(toastIn, timePerFrame: 0.06, resize: false, restore: false), count: 10)
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
        let toastUpAction = SKAction.repeatAction(SKAction.animateWithTextures(toastUp, timePerFrame: 0.06, resize: false, restore: false), count: 1)
        toaster.addAction(3, action: toastUpAction)
        toaster.addClick(3, val: false)
		toaster.addSound(1, soundFile: "toaster1")
		toaster.addSound(3, soundFile: "toaster2")
        spriteContainer.addChild(toaster)
        
        let kettle = AnimatedStateSprite(imageNamed: "house_kitchen_kettle")
        kettle.anchorPoint = CGPoint.zero
        kettle.position = CGPointMake(1120, 203)
        kettle.zPosition = z++
		touchableSprites.append(kettle)
        let warming:[SKTexture] = [
            SKTexture(imageNamed: "house_kitchen_kettle2"),
			SKTexture(imageNamed: "house_kitchen_kettle3"),
			SKTexture(imageNamed: "house_kitchen_kettle4"),
			SKTexture(imageNamed: "house_kitchen_kettle5"),
            SKTexture(imageNamed: "house_kitchen_kettle6")
        ]
        let warmingAction = SKAction.repeatAction(SKAction.animateWithTextures(warming, timePerFrame: 0.06, resize: false, restore: false), count: 3)
        kettle.addAction(1, action: warmingAction)
        kettle.addClick(1, val: false)
        let steaming:[SKTexture] = [
            SKTexture(imageNamed: "house_kitchen_kettle7"),
			SKTexture(imageNamed: "house_kitchen_kettle8"),
			SKTexture(imageNamed: "house_kitchen_kettle9"),
			SKTexture(imageNamed: "house_kitchen_kettle10"),
            SKTexture(imageNamed: "house_kitchen_kettle11")
        ]
        let steamingAction = SKAction.repeatAction(SKAction.animateWithTextures(steaming, timePerFrame: 0.06, resize: false, restore: false), count: 3)
        kettle.addAction(2, action: steamingAction)
        kettle.addClick(2, val: false)
		kettle.addSound(1, soundFile: "kettle")
        spriteContainer.addChild(kettle)
        
        let freezer = AnimatedStateSprite(imageNamed: "house_kitchen_freezer")
        freezer.anchorPoint = CGPoint.zero
        freezer.position = CGPointMake(1043, 212)
        freezer.zPosition = z++
		touchableSprites.append(freezer)
        let freezerOpening:[SKTexture] = [
            SKTexture(imageNamed: "house_kitchen_freezer1"),
            SKTexture(imageNamed: "house_kitchen_freezer2"),
            SKTexture(imageNamed: "house_kitchen_freezer3"),
            SKTexture(imageNamed: "house_kitchen_freezer4"),
			SKTexture(imageNamed: "house_kitchen_freezer5"),
            SKTexture(imageNamed: "house_kitchen_freezer6")
        ]
        let openingAction = SKAction.repeatAction(SKAction.animateWithTextures(freezerOpening, timePerFrame: 0.06, resize: false, restore: false), count: 1)
        freezer.addAction(1, action: openingAction)
        freezer.addClick(1, val: false)
        let closeAction = SKAction.reversedAction(openingAction)()
        freezer.addAction(3, action: closeAction)
        freezer.addClick(2, val: true)
        freezer.addClick(3, val: false)
        spriteContainer.addChild(freezer)
        
        let fridge = AnimatedStateSprite(imageNamed: "house_kitchen_fridge")
        fridge.anchorPoint = CGPoint.zero
        fridge.position = CGPointMake(1043, 140)
        fridge.zPosition = z++
		touchableSprites.append(fridge)
        let fridgeOpening:[SKTexture] = [
            SKTexture(imageNamed: "house_kitchen_fridge1"),
            SKTexture(imageNamed: "house_kitchen_fridge2"),
            SKTexture(imageNamed: "house_kitchen_fridge3"),
            SKTexture(imageNamed: "house_kitchen_fridge4"),
			SKTexture(imageNamed: "house_kitchen_fridge5"),
            SKTexture(imageNamed: "house_kitchen_fridge6")
        ]
        let openingAction2 = SKAction.repeatAction(SKAction.animateWithTextures(fridgeOpening, timePerFrame: 0.06, resize: false, restore: false), count: 1)
        fridge.addAction(1, action: openingAction2)
        fridge.addClick(1, val: false)
        let closeAction2 = SKAction.reversedAction(openingAction2)()
        fridge.addAction(3, action: closeAction2)
        fridge.addClick(2, val: true)
        fridge.addClick(3, val: false)
        spriteContainer.addChild(fridge)
		
		let bubbles = AnimatedStateSprite(imageNamed: "bubbles1")
		bubbles.anchorPoint = CGPoint.zero
		bubbles.position = CGPointMake(916, 205)
		bubbles.zPosition = z++
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
		let bubbleAction = SKAction.repeatActionForever(SKAction.animateWithTextures(bubbleTextures, timePerFrame: 0.08, resize: false, restore: false))
		bubbles.addAction(0, action: bubbleAction)
		bubbles.addAction(1, action: bubbleAction)
		bubbles.addEvent(1, topic: GameScene.TOPIC_START_BUBBLES)
        bubbles.runAction(bubbleAction)
		spriteContainer.addChild(bubbles)
		starSprites.append(bubbles)
        
        let adultBed = SKSpriteNode(imageNamed: "house_adult_bed")
        adultBed.anchorPoint = CGPoint.zero
        adultBed.position = CGPointMake(487, 312)
        adultBed.zPosition = z++
        spriteContainer.addChild(adultBed)
        
        let adultVanity = SKSpriteNode(imageNamed: "house_adult_vanity")
        adultVanity.anchorPoint = CGPoint.zero
        adultVanity.position = CGPointMake(675, 312)
        adultVanity.zPosition = z++
        spriteContainer.addChild(adultVanity)
        
        let wardrobe = AnimatedStateSprite(imageNamed: "house_adult_wardrobe")
        wardrobe.anchorPoint = CGPoint.zero
        wardrobe.position = CGPointMake(747, 312)
        wardrobe.zPosition = z++
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
        let openingAction3 = SKAction.repeatAction(SKAction.animateWithTextures(wardrobeOpening, timePerFrame: 0.06, resize: false, restore: false), count: 1)
        wardrobe.addAction(1, action: openingAction3)
        wardrobe.addClick(1, val: false)
        wardrobe.addEvent(0, topic: GameScene.TOPIC_START_DRESSUP)
        spriteContainer.addChild(wardrobe)
		starSprites.append(wardrobe)
        
        let lightA = AnimatedStateSprite(imageNamed: "house_light_a1")
        lightA.anchorPoint = CGPoint.zero
        lightA.position = CGPointMake(670, 401)
        lightA.zPosition = z++
		touchableSprites.append(lightA)
        lightA.addTexture(1, texture: SKTexture(imageNamed: "house_light_a2"))
        lightA.addSound(0, soundFile: "pullchainslowon")
        lightA.addSound(1, soundFile: "pullchainslowon")
        spriteContainer.addChild(lightA)
        
        let lightB = AnimatedStateSprite(imageNamed: "house_light_b1")
        lightB.anchorPoint = CGPoint.zero
        lightB.position = CGPointMake(522, 418)
        lightB.zPosition = z++
		touchableSprites.append(lightB)
        lightB.addTexture(1, texture: SKTexture(imageNamed: "house_light_b2"))
        lightB.addSound(0, soundFile: "pullchainslowon")
        lightB.addSound(1, soundFile: "pullchainslowon")
        spriteContainer.addChild(lightB)
        
        let blocks = AnimatedStateSprite(imageNamed: "house_toys_blocks")
        blocks.anchorPoint = CGPoint.zero
        blocks.position = CGPointMake(1020, 490)
        blocks.zPosition = z++
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
        let blocksAction = SKAction.repeatAction(SKAction.animateWithTextures(blocksAnim, timePerFrame: 0.06, resize: false, restore: false), count: 1)
        blocks.addAction(1, action: blocksAction)
        blocks.addClick(1, val: false)
        blocks.addEvent(0, topic: GameScene.TOPIC_START_PUZZLE)
        spriteContainer.addChild(blocks)
		starSprites.append(blocks)
        
        let horse = AnimatedStateSprite(imageNamed: "house_toys_horse")
        horse.anchorPoint = CGPoint.zero
        horse.position = CGPointMake(925, 490)
        horse.zPosition = z++
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
        let horseAction = SKAction.repeatAction(SKAction.animateWithTextures(horseAnim, timePerFrame: 0.06, resize: false, restore: false), count: 3)
        horse.addAction(1, action: horseAction)
        horse.addClick(1, val: false)
        spriteContainer.addChild(horse)
        
        let bat = AnimatedStateSprite(imageNamed: "house_toys_bat")
        bat.anchorPoint = CGPoint.zero
        bat.position = CGPointMake(802, 490)
        bat.zPosition = z++
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
        let batAction = SKAction.repeatAction(SKAction.animateWithTextures(batAnim, timePerFrame: 0.06, resize: false, restore: false), count: 1)
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
        let batAction2 = SKAction.repeatAction(SKAction.animateWithTextures(batAnim2, timePerFrame: 0.06, resize: false, restore: false), count: 1)
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
        let batAction3 = SKAction.repeatAction(SKAction.animateWithTextures(batAnim3, timePerFrame: 0.06, resize: false, restore: false), count: 1)
        bat.addAction(3, action: batAction3)
        bat.addClick(3, val: false)
		bat.addSound(3, soundFile: "glass_break")
        spriteContainer.addChild(bat)
        
        let piano = AnimatedStateSprite(imageNamed: "house_music_piano")
        piano.anchorPoint = CGPoint.zero
        piano.position = CGPointMake(625, 490)
        piano.zPosition = z++
        spriteContainer.addChild(piano)
        
        let trumpet = AnimatedStateSprite(imageNamed: "house_music_trumpet")
        trumpet.anchorPoint = CGPoint.zero
        trumpet.position = CGPointMake(660, 574)
        trumpet.zPosition = z++
		touchableSprites.append(trumpet)
        let trumpetAnim:[SKTexture] = [
            SKTexture(imageNamed: "house_music_trumpet1"),
            SKTexture(imageNamed: "house_music_trumpet2"),
            SKTexture(imageNamed: "house_music_trumpet3"),
            SKTexture(imageNamed: "house_music_trumpet2")
        ]
        let trumpetAction = SKAction.repeatAction(SKAction.animateWithTextures(trumpetAnim, timePerFrame: 0.06, resize: false, restore: false), count: 5)
        trumpet.addAction(1, action: trumpetAction)
        trumpet.addClick(1, val: false)
		trumpet.addSound(1, soundFile: "trumpet")
        spriteContainer.addChild(trumpet)
        
        let drums = AnimatedStateSprite(imageNamed: "house_music_drums")
        drums.anchorPoint = CGPoint.zero
        drums.position = CGPointMake(585, 490)
        drums.zPosition = z++
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
        let drumsAction = SKAction.repeatAction(SKAction.animateWithTextures(drumsAnim, timePerFrame: 0.06, resize: false, restore: false), count: 3)
        drums.addAction(1, action: drumsAction)
        drums.addClick(1, val: false)
		drums.addSound(1, soundFile: "drums")
        spriteContainer.addChild(drums)
        
        let guitar = AnimatedStateSprite(imageNamed: "house_music_guitar")
        guitar.anchorPoint = CGPoint.zero
        guitar.position = CGPointMake(700, 490)
        guitar.zPosition = z++
		touchableSprites.append(guitar)
        let guitarAnim:[SKTexture] = [
            SKTexture(imageNamed: "house_music_guitar1"),
            SKTexture(imageNamed: "house_music_guitar2"),
            SKTexture(imageNamed: "house_music_guitar3"),
			SKTexture(imageNamed: "house_music_guitar2")
        ]
        let guitarAction = SKAction.repeatAction(SKAction.animateWithTextures(guitarAnim, timePerFrame: 0.06, resize: false, restore: false), count: 5)
        guitar.addAction(1, action: guitarAction)
        guitar.addClick(1, val: false)
		guitar.addSound(1, soundFile: "guitar")
        spriteContainer.addChild(guitar)
        
        let personSprite = PersonNameSprite()
        touchableSprites.append(personSprite)
        personSprite.position = CGPointMake(self.size.width - (100 * lfScale), 10)
        personSprite.zPosition = z++
        personSprite.size.width = 50 * lfScale
        personSprite.size.height = 50 * lfScale
        personSprite.person = selectedPerson
        personSprite.showLabel = false
        personSprite.topic = LittleFamilyScene.TOPIC_START_CHOOSE
        self.addChild(personSprite)
		
		let settingsSprite = AnimatedStateSprite(imageNamed: "settings")
		settingsSprite.size.height = 30 * lfScale
		settingsSprite.size.width = 30 * lfScale
		settingsSprite.position = CGPointMake(self.size.width - settingsSprite.size.width, settingsSprite.size.height + 8)
		settingsSprite.zPosition = z++
		settingsSprite.addEvent(0, topic: LittleFamilyScene.TOPIC_START_SETTINGS)
		self.addChild(settingsSprite)
		
		starWait = Int(arc4random_uniform(200))
        
        EventHandler.getInstance().subscribe(GameScene.TOPIC_START_MATCH, listener: self)
        EventHandler.getInstance().subscribe(GameScene.TOPIC_START_DRESSUP, listener: self)
        EventHandler.getInstance().subscribe(GameScene.TOPIC_START_PUZZLE, listener: self)
        EventHandler.getInstance().subscribe(GameScene.TOPIC_START_SCRATCH, listener: self)
        EventHandler.getInstance().subscribe(GameScene.TOPIC_START_COLORING, listener: self)
        EventHandler.getInstance().subscribe(GameScene.TOPIC_START_TREE, listener: self)
		EventHandler.getInstance().subscribe(GameScene.TOPIC_START_BUBBLES, listener: self)
        SpeechHelper.getInstance().speak("Hi \(selectedPerson!.givenName!)")
    }
    
    override func willMoveFromView(view: SKView) {
        super.willMoveFromView(view)
        EventHandler.getInstance().unSubscribe(GameScene.TOPIC_START_MATCH, listener: self)
        EventHandler.getInstance().unSubscribe(GameScene.TOPIC_START_DRESSUP, listener: self)
        EventHandler.getInstance().unSubscribe(GameScene.TOPIC_START_PUZZLE, listener: self)
        EventHandler.getInstance().unSubscribe(GameScene.TOPIC_START_SCRATCH, listener: self)
        EventHandler.getInstance().unSubscribe(GameScene.TOPIC_START_COLORING, listener: self)
        EventHandler.getInstance().unSubscribe(GameScene.TOPIC_START_TREE, listener: self)
		EventHandler.getInstance().unSubscribe(GameScene.TOPIC_START_BUBBLES, listener: self)
    }
    
    func pinched(sender:UIPinchGestureRecognizer){
        print("pinched \(lfScale)")
        if previousScale != nil {
            if sender.scale != previousScale! {
                let diff = (sender.scale - previousScale!) / 4
                lfScale += diff
                if lfScale < minScale {
                    lfScale = minScale
                }
                if lfScale > maxScale {
                    lfScale = maxScale
                }
                let zoomIn = SKAction.scaleTo(lfScale, duration:0)
                spriteContainer.runAction(zoomIn)
                
                let zoomIn2 = SKAction.scaleTo(lfScale, duration:0)
                background.runAction(zoomIn2)
            }
        }
        previousScale = sender.scale
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        for touch in touches {
            lastPoint = touch.locationInNode(self)
            
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var nextPoint = CGPointMake(0,0)
        for touch in touches {
            nextPoint = touch.locationInNode(self)
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
        if background.position.y < 0 - diffY {
            background.position.y = 0 - diffY
        }
        
        spriteContainer.position.y += clipY
        if spriteContainer.position.y > minY*lfScale {
            spriteContainer.position.y = minY*lfScale
        }
        if spriteContainer.position.y < 0 - diffY {
            spriteContainer.position.y = 0 - diffY
        }
        
        spriteContainer.position.x += clipX
        if spriteContainer.position.x < 0-(oWidth*lfScale - minX*lfScale) {
            spriteContainer.position.x = 0-(oWidth*lfScale - minX*lfScale)
        }
        if spriteContainer.position.x > minX*2 {
            spriteContainer.position.x = minX*2
        }
        
        lastPoint = nextPoint
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        previousScale = nil
        if !moved {
            for touch in touches {
                lastPoint = touch.locationInNode(self)
                let touchedNode = nodeAtPoint(lastPoint)
                if self.touchableSprites.contains(touchedNode) {
                    touchedNode.touchesEnded(touches, withEvent: event)
                }
                else if personLeaves!.children.contains(touchedNode) == true {
                    personLeaves!.touchesEnded(touches, withEvent: event)
                }
            }
        }
        moved = false
    }
   
    override func update(currentTime: CFTimeInterval) {
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
			starWait--
		} else {
			starWait = Int(arc4random_uniform(200))
			let s = Int(arc4random_uniform(UInt32(starSprites.count)))
			let sprite = starSprites[s]
			showStars(sprite.frame, starsInRect: true, count: Int(sprite.size.width) / 5)
		}
    }
    
    override func onEvent(topic: String, data: NSObject?) {
        super.onEvent(topic, data: data)
        if topic == GameScene.TOPIC_START_MATCH {
            let transition = SKTransition.revealWithDirection(.Down, duration: 0.7)
            
            let nextScene = MatchGameScene(size: scene!.size)
            nextScene.scaleMode = .AspectFill
            nextScene.selectedPerson = selectedPerson
            scene?.view?.presentScene(nextScene, transition: transition)
        }
        else if topic == GameScene.TOPIC_START_DRESSUP {
            let transition = SKTransition.revealWithDirection(.Down, duration: 0.7)
            
            let nextScene = ChooseCultureScene(size: scene!.size)
            nextScene.scaleMode = .AspectFill
            nextScene.selectedPerson = selectedPerson
            scene?.view?.presentScene(nextScene, transition: transition)
        }
        else if topic == GameScene.TOPIC_START_PUZZLE {
            let transition = SKTransition.revealWithDirection(.Down, duration: 0.7)
            
            let nextScene = PuzzleScene(size: scene!.size)
            nextScene.scaleMode = .AspectFill
            nextScene.selectedPerson = selectedPerson
            scene?.view?.presentScene(nextScene, transition: transition)
        }
		else if topic == GameScene.TOPIC_START_SCRATCH {
            let transition = SKTransition.revealWithDirection(.Down, duration: 0.7)
            
            let nextScene = ScratchScene(size: scene!.size)
            nextScene.scaleMode = .AspectFill
            nextScene.selectedPerson = selectedPerson
            scene?.view?.presentScene(nextScene, transition: transition)
        }
		else if topic == GameScene.TOPIC_START_COLORING {
            let transition = SKTransition.revealWithDirection(.Down, duration: 0.7)
            
            let nextScene = ColoringScene(size: scene!.size)
            nextScene.scaleMode = .AspectFill
            nextScene.selectedPerson = selectedPerson
            scene?.view?.presentScene(nextScene, transition: transition)
        }
		else if topic == GameScene.TOPIC_START_TREE {
            let transition = SKTransition.revealWithDirection(.Down, duration: 0.7)
            
            let nextScene = TreeScene(size: scene!.size)
            nextScene.scaleMode = .AspectFill
            nextScene.selectedPerson = selectedPerson
            scene?.view?.presentScene(nextScene, transition: transition)
        }
		else if topic == GameScene.TOPIC_START_BUBBLES {
            let transition = SKTransition.revealWithDirection(.Down, duration: 0.7)
            
            let nextScene = BubbleScene(size: scene!.size)
            nextScene.scaleMode = .AspectFill
            nextScene.selectedPerson = selectedPerson
            scene?.view?.presentScene(nextScene, transition: transition)
        }
    }

}
