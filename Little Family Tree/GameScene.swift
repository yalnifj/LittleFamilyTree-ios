//
//  GameScene.swift
//  Little Family Tree
//
//  Created by Melissa on 9/12/15.
//  Copyright (c) 2015 Melissa. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var maxHeight : CGFloat!
    var lfScale : CGFloat = 1;
    var diffY : CGFloat!
    var clipX : CGFloat = 0.0
    var clipY : CGFloat = 0.0
    var minX : CGFloat = 295.0
    var minY : CGFloat = 0
    var oHeight : CGFloat = 800
    var oWidth : CGFloat = 1280
    var lastPoint : CGPoint!
    var background : SKSpriteNode!
    var spriteContainer : SKSpriteNode!
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        background = SKSpriteNode(imageNamed: "house_background2")
        background.anchorPoint = CGPoint.zeroPoint
        background.position = CGPoint.zeroPoint
        maxHeight = self.size.height*1.1
        if maxHeight < oHeight {
            maxHeight = oHeight
        }
        if (maxHeight > oHeight) {
            lfScale = maxHeight / oHeight;
        }
        diffY = maxHeight - self.size.height;
        background.size = CGSizeMake(self.size.width, maxHeight);
        self.addChild(background);
        
        spriteContainer = SKSpriteNode()
        spriteContainer.anchorPoint = CGPoint.zeroPoint
        spriteContainer.position = CGPointMake(minX, minY)
        spriteContainer.setScale(lfScale)
        self.addChild(spriteContainer)
        
        let cloud1 = SKSpriteNode(imageNamed: "house_cloud1")
        cloud1.anchorPoint = CGPoint.zeroPoint
        cloud1.position = CGPointMake(0, oHeight - cloud1.size.height - 25)
        spriteContainer.addChild(cloud1)
        
        let cloud2 = SKSpriteNode(imageNamed: "house_cloud2")
        cloud2.anchorPoint = CGPoint.zeroPoint
        cloud2.position = CGPointMake(minY + oWidth*0.75, oHeight - cloud1.size.height - 15)
        spriteContainer.addChild(cloud2)
        
        let tree = SKSpriteNode(imageNamed: "house_tree1")
        tree.anchorPoint = CGPoint.zeroPoint
        tree.position = CGPointMake(50, oHeight - tree.size.height - 250)
        spriteContainer.addChild(tree)
        
        let flowers1 = SKSpriteNode(imageNamed: "house_flowers_a1")
        flowers1.anchorPoint = CGPoint.zeroPoint
        flowers1.position = CGPointMake(90+flowers1.size.width, 200-flowers1.size.height)
        flowers1.xScale = flowers1.xScale * -1
        spriteContainer.addChild(flowers1)
        
        let flowers2 = SKSpriteNode(imageNamed: "house_flowers_a1")
        flowers2.anchorPoint = CGPoint.zeroPoint
        flowers2.position = CGPointMake(265, 200-flowers2.size.height)
        spriteContainer.addChild(flowers2)
        
        let tileY:CGFloat = 600
        let tile01 = SKSpriteNode(imageNamed: "house_rooms_0_1")
        tile01.anchorPoint = CGPoint.zeroPoint
        tile01.position = CGPointMake(450, tileY - tile01.size.height)
        spriteContainer.addChild(tile01)
        
        let tile02 = SKSpriteNode(imageNamed: "house_rooms_0_2")
        tile02.anchorPoint = CGPoint.zeroPoint
        tile02.position = CGPointMake(450, tileY - (tile01.size.height*2))
        spriteContainer.addChild(tile02)
        
        let tile03 = SKSpriteNode(imageNamed: "house_rooms_0_3")
        tile03.anchorPoint = CGPoint.zeroPoint
        tile03.position = CGPointMake(450, tileY - (tile01.size.height*3))
        spriteContainer.addChild(tile03)
        
        let tile04 = SKSpriteNode(imageNamed: "house_rooms_0_4")
        tile04.anchorPoint = CGPoint.zeroPoint
        tile04.position = CGPointMake(450, tileY - (tile01.size.height*4))
        spriteContainer.addChild(tile04)
        
        
        let tile10 = SKSpriteNode(imageNamed: "house_rooms_1_0")
        tile10.anchorPoint = CGPoint.zeroPoint
        tile10.position = CGPointMake(450 + tile10.size.width, tileY)
        spriteContainer.addChild(tile10)
        
        let tile11 = SKSpriteNode(imageNamed: "house_rooms_1_1")
        tile11.anchorPoint = CGPoint.zeroPoint
        tile11.position = CGPointMake(450 + tile10.size.width, tileY - tile11.size.height)
        spriteContainer.addChild(tile11)
        
        let tile12 = SKSpriteNode(imageNamed: "house_rooms_1_2")
        tile12.anchorPoint = CGPoint.zeroPoint
        tile12.position = CGPointMake(450 + tile10.size.width, tileY - (tile12.size.height*2))
        spriteContainer.addChild(tile12)
        
        let tile13 = SKSpriteNode(imageNamed: "house_rooms_1_3")
        tile13.anchorPoint = CGPoint.zeroPoint
        tile13.position = CGPointMake(450 + tile10.size.width, tileY - (tile13.size.height*3))
        spriteContainer.addChild(tile13)
        
        let tile14 = SKSpriteNode(imageNamed: "house_rooms_1_4")
        tile14.anchorPoint = CGPoint.zeroPoint
        tile14.position = CGPointMake(450 + tile10.size.width, tileY - (tile14.size.height*4))
        spriteContainer.addChild(tile14)
        
        
        let tile20 = SKSpriteNode(imageNamed: "house_rooms_2_0")
        tile20.anchorPoint = CGPoint.zeroPoint
        tile20.position = CGPointMake(450 + (tile20.size.width*2), tileY)
        spriteContainer.addChild(tile20)
        
        let tile21 = SKSpriteNode(imageNamed: "house_rooms_2_1")
        tile21.anchorPoint = CGPoint.zeroPoint
        tile21.position = CGPointMake(450 + (tile20.size.width*2), tileY - tile21.size.height)
        spriteContainer.addChild(tile21)
        
        let tile22 = SKSpriteNode(imageNamed: "house_rooms_2_2")
        tile22.anchorPoint = CGPoint.zeroPoint
        tile22.position = CGPointMake(450 + (tile20.size.width*2), tileY - (tile22.size.height*2))
        spriteContainer.addChild(tile22)
        
        let tile23 = SKSpriteNode(imageNamed: "house_rooms_2_3")
        tile23.anchorPoint = CGPoint.zeroPoint
        tile23.position = CGPointMake(450 + (tile20.size.width*2), tileY - (tile23.size.height*3))
        spriteContainer.addChild(tile23)
        
        let tile24 = SKSpriteNode(imageNamed: "house_rooms_2_4")
        tile24.anchorPoint = CGPoint.zeroPoint
        tile24.position = CGPointMake(450 + (tile20.size.width*2), tileY - (tile24.size.height*4))
        spriteContainer.addChild(tile24)
        
        let tile30 = SKSpriteNode(imageNamed: "house_rooms_3_0")
        tile30.anchorPoint = CGPoint.zeroPoint
        tile30.position = CGPointMake(450 + (tile30.size.width*3), tileY)
        spriteContainer.addChild(tile30)
        
        let tile31 = SKSpriteNode(imageNamed: "house_rooms_3_1")
        tile31.anchorPoint = CGPoint.zeroPoint
        tile31.position = CGPointMake(450 + (tile30.size.width*3), tileY - tile31.size.height)
        spriteContainer.addChild(tile31)
        
        let tile32 = SKSpriteNode(imageNamed: "house_rooms_3_2")
        tile32.anchorPoint = CGPoint.zeroPoint
        tile32.position = CGPointMake(450 + (tile30.size.width*3), tileY - (tile32.size.height*2))
        spriteContainer.addChild(tile32)
        
        let tile33 = SKSpriteNode(imageNamed: "house_rooms_3_3")
        tile33.anchorPoint = CGPoint.zeroPoint
        tile33.position = CGPointMake(450 + (tile30.size.width*3), tileY - (tile33.size.height*3))
        spriteContainer.addChild(tile33)
        
        let tile34 = SKSpriteNode(imageNamed: "house_rooms_3_4")
        tile34.anchorPoint = CGPoint.zeroPoint
        tile34.position = CGPointMake(450 + (tile30.size.width*3), tileY - (tile34.size.height*4))
        spriteContainer.addChild(tile34)

        
        let tile41 = SKSpriteNode(imageNamed: "house_rooms_4_1")
        tile41.anchorPoint = CGPoint.zeroPoint
        tile41.position = CGPointMake(450 + (tile41.size.width*4), tileY - tile41.size.height)
        spriteContainer.addChild(tile41)
        
        let tile42 = SKSpriteNode(imageNamed: "house_rooms_4_2")
        tile42.anchorPoint = CGPoint.zeroPoint
        tile42.position = CGPointMake(450 + (tile41.size.width*4), tileY - (tile42.size.height*2))
        spriteContainer.addChild(tile42)
        
        let tile43 = SKSpriteNode(imageNamed: "house_rooms_4_3")
        tile43.anchorPoint = CGPoint.zeroPoint
        tile43.position = CGPointMake(450 + (tile41.size.width*4), tileY - (tile43.size.height*3))
        spriteContainer.addChild(tile43)
        
        let tile44 = SKSpriteNode(imageNamed: "house_rooms_4_4")
        tile44.anchorPoint = CGPoint.zeroPoint
        tile44.position = CGPointMake(450 + (tile41.size.width*4), tileY - (tile44.size.height*4))
        spriteContainer.addChild(tile44)


        let couch = SKSpriteNode(imageNamed: "house_familyroom_couch")
        couch.anchorPoint = CGPoint.zeroPoint
        couch.position = CGPointMake(555, 140)
        spriteContainer.addChild(couch)
        
        let table1 = SKSpriteNode(imageNamed: "house_familyroom_table")
        table1.anchorPoint = CGPoint.zeroPoint
        table1.position = CGPointMake(491, 140)
        spriteContainer.addChild(table1)
        
        let table2 = SKSpriteNode(imageNamed: "house_familyroom_table")
        table2.anchorPoint = CGPoint.zeroPoint
        table2.position = CGPointMake(735, 140)
        spriteContainer.addChild(table2)
        
        let lamp1 = SKSpriteNode(imageNamed: "house_familyroom_lamp1")
        lamp1.anchorPoint = CGPoint.zeroPoint
        lamp1.position = CGPointMake(482, 170)
        spriteContainer.addChild(lamp1)
        
        let lamp2 = SKSpriteNode(imageNamed: "house_familyroom_lamp1")
        lamp2.anchorPoint = CGPoint.zeroPoint
        lamp2.position = CGPointMake(725, 170)
        spriteContainer.addChild(lamp2)
        
        let frame = SKSpriteNode(imageNamed: "house_familyroom_frame")
        frame.anchorPoint = CGPoint.zeroPoint
        frame.position = CGPointMake(612, 225)
        spriteContainer.addChild(frame)
        
        let childBed = SKSpriteNode(imageNamed: "house_chilldroom_bed")
        childBed.anchorPoint = CGPoint.zeroPoint
        childBed.position = CGPointMake(827, 307)
        spriteContainer.addChild(childBed)
        
        let childPaint = SKSpriteNode(imageNamed: "house_chilldroom_paint")
        childPaint.anchorPoint = CGPoint.zeroPoint
        childPaint.position = CGPointMake(1000, 312)
        spriteContainer.addChild(childPaint)
        
        let childDesk = SKSpriteNode(imageNamed: "house_chilldroom_desk")
        childDesk.anchorPoint = CGPoint.zeroPoint
        childDesk.position = CGPointMake(1065, 312)
        spriteContainer.addChild(childDesk)
        
        let teddy = SKSpriteNode(imageNamed: "house_chilldroom_teddy")
        teddy.anchorPoint = CGPoint.zeroPoint
        teddy.position = CGPointMake(925, 315)
        spriteContainer.addChild(teddy)
        
        
        let kitchenA = SKSpriteNode(imageNamed: "house_kitchen_a")
        kitchenA.anchorPoint = CGPoint.zeroPoint
        kitchenA.position = CGPointMake(840, 140)
        spriteContainer.addChild(kitchenA)
        
        let kitchenB = SKSpriteNode(imageNamed: "house_kitchen_b")
        kitchenB.anchorPoint = CGPoint.zeroPoint
        kitchenB.position = CGPointMake(kitchenA.position.x+kitchenA.size.width, 140)
        spriteContainer.addChild(kitchenB)
        
        let kitchenC = SKSpriteNode(imageNamed: "house_kitchen_c")
        kitchenC.anchorPoint = CGPoint.zeroPoint
        kitchenC.position = CGPointMake(kitchenB.position.x+kitchenB.size.width, 140)
        spriteContainer.addChild(kitchenC)
        
        let kitchenD = SKSpriteNode(imageNamed: "house_kitchen_d")
        kitchenD.anchorPoint = CGPoint.zeroPoint
        kitchenD.position = CGPointMake(kitchenC.position.x+kitchenC.size.width, 265)
        spriteContainer.addChild(kitchenD)
        
        let kitchenE = SKSpriteNode(imageNamed: "house_kitchen_e")
        kitchenE.anchorPoint = CGPoint.zeroPoint
        kitchenE.position = CGPointMake(kitchenD.position.x+kitchenD.size.width, 140)
        spriteContainer.addChild(kitchenE)
        
        let toaster = SKSpriteNode(imageNamed: "house_toaster1")
        toaster.anchorPoint = CGPoint.zeroPoint
        toaster.position = CGPointMake(1085, 195)
        spriteContainer.addChild(toaster)
        
        let kettle = SKSpriteNode(imageNamed: "house_kitchen_kettle")
        kettle.anchorPoint = CGPoint.zeroPoint
        kettle.position = CGPointMake(1120, 203)
        spriteContainer.addChild(kettle)
        
        let freezer = SKSpriteNode(imageNamed: "house_kitchen_freezer")
        freezer.anchorPoint = CGPoint.zeroPoint
        freezer.position = CGPointMake(1043, 212)
        spriteContainer.addChild(freezer)
        
        let fridge = SKSpriteNode(imageNamed: "house_kitchen_fridge")
        fridge.anchorPoint = CGPoint.zeroPoint
        fridge.position = CGPointMake(1043, 140)
        spriteContainer.addChild(fridge)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch in (touches as! Set<UITouch>) {
            lastPoint = touch.locationInNode(self)
        }
        
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        var nextPoint = CGPointMake(0,0)
        for touch in (touches as! Set<UITouch>) {
            nextPoint = touch.locationInNode(self)
        }
        
        clipX = nextPoint.x - lastPoint.x;
        clipY = nextPoint.y - lastPoint.y;
        
        background.position.y += clipY;
        if background.position.y > 0 {
            background.position.y = 0
        }
        if background.position.y < 0 - diffY {
            background.position.y = 0 - diffY
        }
        
        spriteContainer.position.y += clipY
        if spriteContainer.position.y > minY {
            spriteContainer.position.y = minY
        }
        if spriteContainer.position.y < 0 - diffY {
            spriteContainer.position.y = 0 - diffY
        }
        
        spriteContainer.position.x += clipX
        if spriteContainer.position.x < 0-(oWidth-minX*2) {
            spriteContainer.position.x = 0-(oWidth-minX*2)
        }
        if spriteContainer.position.x > minX {
            spriteContainer.position.x = minX
        }
        
        lastPoint = nextPoint
        
    }
    
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
