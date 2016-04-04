//
//  BubbleScene.swift
//  Little Family Tree
//
//  Created by Melissa on 12/29/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class BubbleScene: LittleFamilyScene {
    static var TOPIC_WATER = "topic_water"
    
    var queue = [LittlePerson]()
    var width = CGFloat(100)
    
    var faucet:AnimatedStateSprite?
    var soap:AnimatedStateSprite?
    var bubbles = [SKSpriteNode]()
    var popping = [SKTexture]()
    
    var dadSpot: SKSpriteNode?
    var momSpot: SKSpriteNode?
    var childSpot: SKSpriteNode?
    
    var child: PersonBubbleSprite?
    var mom: PersonBubbleSprite?
    var dad: PersonBubbleSprite?
    
    var next:PersonBubbleSprite?
    
    var hasSoap = false
    var lastHighlightTime:NSTimeInterval = 0
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        self.size.width = view.bounds.width
        self.size.height = view.bounds.height
        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        let background = SKSpriteNode(imageNamed: "bubble_background")
        background.position = CGPointMake(self.size.width/2, self.size.height/2)
        background.size.width = self.size.width
        background.size.height = self.size.height
        background.zPosition = 0
        self.addChild(background)
        
        setupTopBar()
		
		let minD = min(self.size.width, self.size.height)
		
        width = minD / 4
        
        let sinkTexture = SKTexture(imageNamed: "sink")
        let ratio = (width * 3) / sinkTexture.size().width
        let sink = SKSpriteNode(texture: sinkTexture)
        let r = sink.size.height / sink.size.width
        sink.size = CGSizeMake(width * 3, width * 3 * r / 2)
        sink.position = CGPointMake(self.size.width / 2, sink.size.height / 2)
        sink.zPosition = 1
        self.addChild(sink)
        
        let faucetTexture = SKTexture(imageNamed: "faucet1")
        faucet = AnimatedStateSprite(texture: faucetTexture)
        faucet?.size = CGSizeMake(faucetTexture.size().width * ratio/2, faucetTexture.size().height * ratio/2)
        faucet?.position = CGPointMake((self.size.width / 2) + (faucet?.size.width)! / 2, (faucet?.size.height)! / 2 + sink.size.height/1.5)
        faucet?.zPosition = 5
        let spin:[SKTexture] = [
            SKTexture(imageNamed: "faucet2"),
            SKTexture(imageNamed: "faucet1")
        ]
        let spinAction = SKAction.repeatAction(SKAction.animateWithTextures(spin, timePerFrame: 0.06, resize: false, restore: false), count: 4)
        faucet?.addAction(1, action: spinAction)
        
        let water:[SKTexture] = [
            SKTexture(imageNamed: "faucet3"),
            SKTexture(imageNamed: "faucet4"),
            SKTexture(imageNamed: "faucet5")
        ]
        let waterAction = SKAction.animateWithTextures(water, timePerFrame: 0.06, resize: false, restore: false)
        faucet?.addAction(2, action: waterAction)
        faucet?.addSound(2, soundFile: "water")
        
        let running:[SKTexture] = [
            SKTexture(imageNamed: "faucet6"),
            SKTexture(imageNamed: "faucet5")
        ]
        let runningAction = SKAction.repeatAction(SKAction.animateWithTextures(running, timePerFrame: 0.06, resize: false, restore: false), count: 4)
        faucet?.addAction(3, action: runningAction)
        self.addChild(faucet!)
        
        let waterOff = SKAction.reversedAction(waterAction)()
        faucet?.addAction(4, action: waterOff)
        faucet?.addAction(5, action: spinAction)
        faucet?.addEvent(4, topic: BubbleScene.TOPIC_WATER)
        
        let soapTexture = SKTexture(imageNamed: "soap1")
        soap = AnimatedStateSprite(texture: soapTexture)
        soap?.size = CGSizeMake(soapTexture.size().width * ratio/1.5, soapTexture.size().height * ratio/1.5)
        soap?.position = CGPointMake((self.size.width / 2) + (faucet?.size.width)!/2 + (soap?.size.width)!/1.2, sink.size.height/2 + (soap?.size.height)!/1.8)
        soap?.zPosition = 6
        let squirting:[SKTexture] = [
            SKTexture(imageNamed: "soap2"),
            SKTexture(imageNamed: "soap3"),
            SKTexture(imageNamed: "soap4"),
            SKTexture(imageNamed: "soap5")
        ]
        let squirtAction = SKAction.animateWithTextures(squirting, timePerFrame: 0.10, resize: false, restore: false)
        soap?.addAction(1, action: squirtAction)
        let squirting2:[SKTexture] = [
            SKTexture(imageNamed: "soap6"),
            SKTexture(imageNamed: "soap7"),
            SKTexture(imageNamed: "soap6"),
            SKTexture(imageNamed: "soap5"),
            SKTexture(imageNamed: "soap4"),
            SKTexture(imageNamed: "soap3"),
            SKTexture(imageNamed: "soap2"),
            SKTexture(imageNamed: "soap1")
        ]
        let squirtAction2 = SKAction.animateWithTextures(squirting2, timePerFrame: 0.10, resize: false, restore: false)
        soap?.addAction(2, action: squirtAction2)
        soap?.addSound(2, soundFile: "squirt")
        self.addChild(soap!)
        
        popping.append(SKTexture(imageNamed: "bubble_pop1"))
        popping.append(SKTexture(imageNamed: "bubble_pop2"))
        popping.append(SKTexture(imageNamed: "bubble_pop3"))
        popping.append(SKTexture(imageNamed: "bubble_pop4"))
        popping.append(SKTexture(imageNamed: "bubble_pop5"))
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height - (topBar?.size.height)!)
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: rect)
        self.physicsBody?.categoryBitMask = 1
        
        let spotTexture = SKTexture(imageNamed: "bubble_spot")
        let sr = spotTexture.size().width / spotTexture.size().height
        momSpot = SKSpriteNode(texture: spotTexture)
        momSpot?.position = CGPointMake((self.size.width / 2) + width, (self.size.height / 2) + width)
        momSpot?.size = CGSizeMake(width, width / sr)
        momSpot?.zPosition = 3
        self.addChild(momSpot!)
        
        dadSpot = SKSpriteNode(texture: spotTexture)
        dadSpot?.position = CGPointMake((self.size.width / 2) - width, (self.size.height / 2) + width)
        dadSpot?.size = CGSizeMake(width, width / sr)
        dadSpot?.zPosition = 3
        self.addChild(dadSpot!)
        
        childSpot = SKSpriteNode(imageNamed: "bubble_spot_down")
        childSpot?.position = CGPointMake(self.size.width / 2, (self.size.height / 2) - width/6)
        childSpot?.size = CGSizeMake(width, width / sr)
        childSpot?.zPosition = 3
        self.addChild(childSpot!)
        
        let bar = SKSpriteNode(color: UIColor(hexString: "#D12D2DFF"), size: CGSizeMake(width*2.3, width/10))
        bar.position = CGPointMake(self.size.width/2, self.size.height/2 + (childSpot?.size.height)! / 3)
        bar.zPosition = 2
        self.addChild(bar)
        
        addBubbles()
        loadPeople()
        
        EventHandler.getInstance().subscribe(BubbleScene.TOPIC_WATER, listener: self)
    }

    func loadPeople() {
        if mom != nil {
            mom?.removeFromParent()
        }
        if dad != nil {
            dad?.removeFromParent()
        }
        if child != nil {
            child?.removeFromParent()
        }
        if queue.count == 0 {
            queue.append(self.selectedPerson!)
        }
        let tracker = RecentPersonTracker.getInstance()
        let dataService = DataService.getInstance()
        
        var person = queue.removeFirst()
        while (queue.count > 0 && tracker.personRecentlyUsed(person) == true) {
            person = queue.removeFirst()
        }
        tracker.addPerson(person)
        
        dataService.getFamilyMembers(person, loadSpouse: true, onCompletion: {people, err in
            if people != nil {
                for p in people! {
                    self.queue.append(p)
                }
            }
        })
        
        dataService.getParents(person, onCompletion: { parents, err in
            if parents == nil || parents?.count < 2 {
                self.loadPeople()
            }
            else {
                var bx = (self.size.width / 3) + CGFloat(arc4random_uniform(UInt32(self.width)))
                var by = (self.width / 2) + CGFloat(arc4random_uniform(UInt32(self.width)))
                
                self.child = PersonBubbleSprite()
                self.child?.size = CGSizeMake(self.width, self.width)
                self.child?.position = CGPointMake(bx, by)
                self.child?.zPosition = 7
                self.child?.person = person
                self.child?.physicsBody = SKPhysicsBody(circleOfRadius: self.width/2)
                self.child?.physicsBody?.categoryBitMask = 2
                self.child?.physicsBody?.collisionBitMask = 1
                self.child?.physicsBody?.restitution = 1.0
                self.child?.physicsBody?.friction = 0.0
                self.child?.physicsBody?.linearDamping = 0.0
                self.child?.physicsBody?.angularDamping = 0.0
                self.child?.physicsBody?.affectedByGravity = false
                self.child?.physicsBody?.dynamic = true
                let dx = self.width/2 - CGFloat(arc4random_uniform(UInt32(self.width)))
                let dy = self.width/2 - CGFloat(arc4random_uniform(UInt32(self.width)))
                let v = CGVectorMake(dx, dy)
                self.addChild(self.child!)
                self.child?.physicsBody?.applyImpulse(v)
                
                dataService.getParentCouple(person, inParent: parents![0], onCompletion: {parents2, err in
                    bx = (self.size.width / 3) + CGFloat(arc4random_uniform(UInt32(self.width)))
                    by = (self.width / 2) + CGFloat(arc4random_uniform(UInt32(self.width)))
                    self.dad = PersonBubbleSprite()
                    self.dad?.size = CGSizeMake(self.width, self.width)
                    self.dad?.position = CGPointMake(bx, by)
                    self.dad?.zPosition = 7
                    if parents2!.count > 0 {
                        self.dad?.person = parents2![0]
                    } else {
                        self.dad?.person = parents![0]
                    }
                    self.dad?.physicsBody = SKPhysicsBody(circleOfRadius: self.width/2)
                    self.dad?.physicsBody?.categoryBitMask = 2
                    self.dad?.physicsBody?.collisionBitMask = 1
                    self.dad?.physicsBody?.restitution = 1.0
                    self.dad?.physicsBody?.friction = 0.0
                    self.dad?.physicsBody?.linearDamping = 0.0
                    self.dad?.physicsBody?.angularDamping = 0.0
                    self.dad?.physicsBody?.affectedByGravity = false
                    self.dad?.physicsBody?.dynamic = true
                    let dx2 = self.width/2 - CGFloat(arc4random_uniform(UInt32(self.width)))
                    let dy2 = self.width/2 - CGFloat(arc4random_uniform(UInt32(self.width)))
                    let v2 = CGVectorMake(dx2, dy2)
                    self.addChild(self.dad!)
                    self.dad?.physicsBody?.applyImpulse(v2)
                    
                    bx = (self.size.width / 3) + CGFloat(arc4random_uniform(UInt32(self.width)))
                    by = (self.width / 2) + CGFloat(arc4random_uniform(UInt32(self.width)))
                    self.mom = PersonBubbleSprite()
                    self.mom?.size = CGSizeMake(self.width, self.width)
                    self.mom?.position = CGPointMake(bx, by)
                    self.mom?.zPosition = 7
                    if parents2!.count > 1 {
                        self.mom?.person = parents2![1]
                    } else {
                        self.mom?.person = parents2![0]
                    }
                    self.mom?.physicsBody = SKPhysicsBody(circleOfRadius: self.width/2)
                    self.mom?.physicsBody?.categoryBitMask = 2
                    self.mom?.physicsBody?.collisionBitMask = 1
                    self.mom?.physicsBody?.restitution = 1.0
                    self.mom?.physicsBody?.friction = 0.0
                    self.mom?.physicsBody?.linearDamping = 0.0;
                    self.mom?.physicsBody?.angularDamping = 0.0;
                    self.mom?.physicsBody?.affectedByGravity = false
                    self.mom?.physicsBody?.dynamic = true
                    let dx3 = self.width/2 - CGFloat(arc4random_uniform(UInt32(self.width)))
                    let dy3 = self.width/2 - CGFloat(arc4random_uniform(UInt32(self.width)))
                    let v3 = CGVectorMake(dx3, dy3)
                    self.addChild(self.mom!)
                    self.mom?.physicsBody?.applyImpulse(v3)
                    
                    if self.bubbles.count < 7 {
                        self.addBubbles()
                    }
                    self.nextSpot()
                })
            }
        })
    }
    
    func addBubbles() {
        let bcount = 7 + arc4random_uniform(13)
        for _ in 0..<bcount {
            let bubble = SKSpriteNode(imageNamed: "bubble")
            let w = (width / 2) + CGFloat(arc4random_uniform(UInt32(width / 2)))
            bubble.size = CGSizeMake(w, w)
            let x = (self.size.width / 3) + CGFloat(arc4random_uniform(UInt32(width)))
            let y = (w / 2) + CGFloat(arc4random_uniform(UInt32(width)))
            bubble.position = CGPointMake(x, y)
            bubble.zPosition = 7
            bubble.physicsBody = SKPhysicsBody(circleOfRadius: w/2)
            bubble.physicsBody?.categoryBitMask = 2
            bubble.physicsBody?.collisionBitMask = 1
            bubble.physicsBody?.restitution = 1.0
            bubble.physicsBody?.friction = 0.0
            bubble.physicsBody?.linearDamping = 0.0
            bubble.physicsBody?.angularDamping = 0.0
            bubble.physicsBody?.affectedByGravity = false
            bubble.physicsBody?.dynamic = true
            
            let dx = w/2 - CGFloat(arc4random_uniform(UInt32(w)))
            let dy = w/2 - CGFloat(arc4random_uniform(UInt32(w)))
            let v = CGVectorMake(dx, dy)
            
            self.addChild(bubble)
            self.bubbles.append(bubble)
            
            bubble.physicsBody?.applyImpulse(v)
        }
    }
    
    func nextSpot() {
        if next != nil {
            childSpot?.texture = SKTexture(imageNamed: "bubble_spot_down")
            dadSpot?.texture = SKTexture(imageNamed: "bubble_spot")
            momSpot?.texture = SKTexture(imageNamed: "bubble_spot")
        }
        if child?.popped == true && dad?.popped == true && mom?.popped == true {
            self.playSuccessSound(1.5, onCompletion: { () in
                self.loadPeople()
            })
            return
        }
        var r = arc4random_uniform(3)
        while (next == nil || next?.popped == true) {
            if r == 0 {
                next = child
                if next?.popped == true {
                    r = 1
                } else {
                    childSpot?.texture = SKTexture(imageNamed: "bubble_spot_down_h")
                    self.speak("Find the child in this family?")
                }
            }
            if r == 1 {
                next = mom
                if next?.popped == true {
                    r = 2
                } else {
                    momSpot?.texture = SKTexture(imageNamed: "bubble_spot_h")
                    var mother = "mother"
                    if mom?.person?.gender == GenderType.MALE {
                        mother = "father"
                    }
                    self.speak("Find the \(mother) in this family?")
                }
            }
            if r == 2 {
                next = dad
                if next?.popped == true {
                    r = 0
                }else {
                    dadSpot?.texture = SKTexture(imageNamed: "bubble_spot_h")
                    var father = "father"
                    if dad?.person?.gender == GenderType.FEMALE {
                        father = "mother"
                    }
                    self.speak("Find the \(father) in this family?")
                }
            }
        }
    }
    
    override func willMoveFromView(view: SKView) {
        super.willMoveFromView(view)
        EventHandler.getInstance().unSubscribe(BubbleScene.TOPIC_WATER, listener: self)
    }
    
    override func onEvent(topic: String, data: NSObject?) {
        super.onEvent(topic, data: data)
        if topic == BubbleScene.TOPIC_WATER {
            if hasSoap {
                hasSoap = false
                addBubbles()
            }
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        if lastHighlightTime == 0 {
			lastHighlightTime = currentTime
		}
		else {
            if currentTime - lastHighlightTime > 10 {
                lastHighlightTime = currentTime
                if next != nil {
                    next!.highlight()
                }
            }
		}
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        for touch in touches {
            let lastPoint = touch.locationInNode(self)
			let touchedNode = nodeAtPoint(lastPoint)
            if touchedNode is SKSpriteNode {
                if touchedNode == faucet {
                    if faucet?.state==0 {
                        faucet?.nextState()
                    }
                }
                else if touchedNode == soap {
                    soap?.nextState()
                    hasSoap = true
                } else if self.bubbles.contains(touchedNode as! SKSpriteNode) {
                    let aaction = SKAction.animateWithTextures(popping, timePerFrame: 0.06)
                    let action = SKAction.sequence([aaction, SKAction.removeFromParent()])
                    touchedNode.runAction(action) {
                        self.bubbles.removeObject(touchedNode as! SKSpriteNode)
                    }
                    let quietMode = DataService.getInstance().dbHelper.getProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET)
                    if quietMode == nil || quietMode == "false" {
                        let popSound = SKAction.playSoundFileNamed("pop", waitForCompletion: false)
                        self.runAction(popSound)
                    }
                } else if touchedNode == child || child?.children.contains(touchedNode) == true {
                    if next == child || child?.popped == true {
                        if child?.popped == false {
                            child?.popped = true
                            child?.removeAllActions()
                            let aaction = SKAction.animateWithTextures(popping, timePerFrame: 0.06)
                            let action = SKAction.sequence([aaction, SKAction.removeFromParent()])
                            child?.bubble?.runAction(action)
                            
                            let quietMode = DataService.getInstance().dbHelper.getProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET)
                            if quietMode == nil || quietMode == "false" {
                                let popSound = SKAction.playSoundFileNamed("pop", waitForCompletion: false)
                                self.runAction(popSound)
                            }
                            
                            child?.physicsBody?.applyImpulse(CGVectorMake(0,0))
                            
                            let moveAction = SKAction.moveTo((childSpot?.position)!, duration: 1.5)
                            child?.runAction(moveAction) {
                                self.child?.physicsBody?.applyImpulse(CGVectorMake(0,0))
                                self.child?.physicsBody = nil
                                self.child?.zPosition = 3
                            }
                            
                            self.runAction(SKAction.waitForDuration(2.0)) {
                                self.nextSpot()
                            }
							lastHighlightTime = 0
                        }
                    
                        self.speak((child?.person?.givenName)! as String)
                    } else {
                        let quietMode = DataService.getInstance().dbHelper.getProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET)
                        if quietMode == nil || quietMode == "false" {
                            let nopopSound = SKAction.playSoundFileNamed("nopop", waitForCompletion: false)
                            self.runAction(nopopSound)
                        }
                    }
                } else if touchedNode == mom || mom?.children.contains(touchedNode) == true {
                    if next == mom || mom?.popped == true {
                        if mom?.popped == false {
                            mom?.popped = true
                            mom?.removeAllActions()
                            let aaction = SKAction.animateWithTextures(popping, timePerFrame: 0.06)
                            let action = SKAction.sequence([aaction, SKAction.removeFromParent()])
                            mom?.bubble?.runAction(action)
                            
                            let quietMode = DataService.getInstance().dbHelper.getProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET)
                            if quietMode == nil || quietMode == "false" {
                                let popSound = SKAction.playSoundFileNamed("pop", waitForCompletion: false)
                                self.runAction(popSound)
                            }
                            
                            mom?.physicsBody?.applyImpulse(CGVectorMake(0,0))
                            
                            let moveAction = SKAction.moveTo((momSpot?.position)!, duration: 1.5)
                            mom?.runAction(moveAction) {
                                self.mom?.physicsBody?.applyImpulse(CGVectorMake(0,0))
                                self.mom?.physicsBody = nil
                                self.mom?.zPosition = 3
                            }
                            
                            self.runAction(SKAction.waitForDuration(2.0)) {
                                self.nextSpot()
                            }
							lastHighlightTime = 0
                        }
                        
                        self.speak((mom?.person?.givenName)! as String)
                    } else {
                        let quietMode = DataService.getInstance().dbHelper.getProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET)
                        if quietMode == nil || quietMode == "false" {
                            let nopopSound = SKAction.playSoundFileNamed("nopop", waitForCompletion: false)
                            self.runAction(nopopSound)
                        }
                    }
                } else if touchedNode == dad || dad?.children.contains(touchedNode) == true {
                    if next == dad || dad?.popped == true {
                        if dad?.popped == false {
                            dad?.popped = true
                            dad?.removeAllActions()
                            let aaction = SKAction.animateWithTextures(popping, timePerFrame: 0.06)
                            let action = SKAction.sequence([aaction, SKAction.removeFromParent()])
                            dad?.bubble?.runAction(action)
                            
                            let quietMode = DataService.getInstance().dbHelper.getProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET)
                            if quietMode == nil || quietMode == "false" {
                                let popSound = SKAction.playSoundFileNamed("pop", waitForCompletion: false)
                                self.runAction(popSound)
                            }
                            
                            dad?.physicsBody?.applyImpulse(CGVectorMake(0,0))
                            
                            let moveAction = SKAction.moveTo((dadSpot?.position)!, duration: 1.5)
                            dad?.runAction(moveAction) {
                                self.dad?.physicsBody?.applyImpulse(CGVectorMake(0,0))
                                self.dad?.physicsBody = nil
                                self.dad?.zPosition = 3
                            }
                            
                            self.runAction(SKAction.waitForDuration(2.0)) {
                                self.nextSpot()
                            }
							lastHighlightTime = 0
                        }
                        
                        self.speak((dad?.person?.givenName)! as String)
                    } else {
                        let quietMode = DataService.getInstance().dbHelper.getProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET)
                        if quietMode == nil || quietMode == "false" {
                            let nopopSound = SKAction.playSoundFileNamed("nopop", waitForCompletion: false)
                            self.runAction(nopopSound)
                        }
                    }
                }
            }
            break
        }
    }
}