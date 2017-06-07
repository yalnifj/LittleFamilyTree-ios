//
//  BubbleScene.swift
//  Little Family Tree
//
//  Created by Melissa on 12/29/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit
import Firebase

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
    
    var nextBubble:PersonBubbleSprite?
    
    var hasSoap = false
    var lastHighlightTime:TimeInterval = 0
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.size.width = view.bounds.width
        self.size.height = view.bounds.height
        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        let background = SKSpriteNode(imageNamed: "bubble_background")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
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
        sink.size = CGSize(width: width * 3, height: width * 3 * r / 2)
        sink.position = CGPoint(x: self.size.width / 2, y: sink.size.height / 2)
        sink.zPosition = 1
        self.addChild(sink)
        
        let faucetTexture = SKTexture(imageNamed: "faucet1")
        faucet = AnimatedStateSprite(texture: faucetTexture)
        faucet?.size = CGSize(width: faucetTexture.size().width * ratio/2, height: faucetTexture.size().height * ratio/2)
        faucet?.position = CGPoint(x: (self.size.width / 2) + (faucet?.size.width)! / 2, y: (faucet?.size.height)! / 2 + sink.size.height/1.5)
        faucet?.zPosition = 5
        let spin:[SKTexture] = [
            SKTexture(imageNamed: "faucet2"),
            SKTexture(imageNamed: "faucet1")
        ]
        let spinAction = SKAction.repeat(SKAction.animate(with: spin, timePerFrame: 0.06, resize: false, restore: false), count: 4)
        faucet?.addAction(1, action: spinAction)
        
        let water:[SKTexture] = [
            SKTexture(imageNamed: "faucet3"),
            SKTexture(imageNamed: "faucet4"),
            SKTexture(imageNamed: "faucet5")
        ]
        let waterAction = SKAction.animate(with: water, timePerFrame: 0.06, resize: false, restore: false)
        faucet?.addAction(2, action: waterAction)
        faucet?.addSound(2, soundFile: "water")
        
        let running:[SKTexture] = [
            SKTexture(imageNamed: "faucet6"),
            SKTexture(imageNamed: "faucet5")
        ]
        let runningAction = SKAction.repeat(SKAction.animate(with: running, timePerFrame: 0.06, resize: false, restore: false), count: 4)
        faucet?.addAction(3, action: runningAction)
        self.addChild(faucet!)
        
        let waterOff = SKAction.reversed(waterAction)()
        faucet?.addAction(4, action: waterOff)
        faucet?.addAction(5, action: spinAction)
        faucet?.addEvent(4, topic: BubbleScene.TOPIC_WATER)
        
        let soapTexture = SKTexture(imageNamed: "soap1")
        soap = AnimatedStateSprite(texture: soapTexture)
        soap?.size = CGSize(width: soapTexture.size().width * ratio/1.5, height: soapTexture.size().height * ratio/1.5)
        let sx = (self.size.width / 2) + (faucet?.size.width)!/2 + (soap?.size.width)!/1.2
        let sy = sink.size.height/2 + (soap?.size.height)!/1.8
        soap?.position = CGPoint(x: sx, y: sy)
        soap?.zPosition = 6
        let squirting:[SKTexture] = [
            SKTexture(imageNamed: "soap2"),
            SKTexture(imageNamed: "soap3"),
            SKTexture(imageNamed: "soap4"),
            SKTexture(imageNamed: "soap5")
        ]
        let squirtAction = SKAction.animate(with: squirting, timePerFrame: 0.10, resize: false, restore: false)
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
        let squirtAction2 = SKAction.animate(with: squirting2, timePerFrame: 0.10, resize: false, restore: false)
        soap?.addAction(2, action: squirtAction2)
        soap?.addSound(2, soundFile: "squirt")
        self.addChild(soap!)
        
        popping.append(SKTexture(imageNamed: "bubble_pop1"))
        popping.append(SKTexture(imageNamed: "bubble_pop2"))
        popping.append(SKTexture(imageNamed: "bubble_pop3"))
        popping.append(SKTexture(imageNamed: "bubble_pop4"))
        popping.append(SKTexture(imageNamed: "bubble_pop5"))
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height - (topBar?.size.height)!)
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: rect)
        self.physicsBody?.categoryBitMask = 1
        
        let spotTexture = SKTexture(imageNamed: "bubble_spot")
        let sr = spotTexture.size().width / spotTexture.size().height
        momSpot = SKSpriteNode(texture: spotTexture)
        momSpot?.position = CGPoint(x: (self.size.width / 2) + width, y: (self.size.height / 2) + width)
        momSpot?.size = CGSize(width: width, height: width / sr)
        momSpot?.zPosition = 3
        self.addChild(momSpot!)
        
        dadSpot = SKSpriteNode(texture: spotTexture)
        dadSpot?.position = CGPoint(x: (self.size.width / 2) - width, y: (self.size.height / 2) + width)
        dadSpot?.size = CGSize(width: width, height: width / sr)
        dadSpot?.zPosition = 3
        self.addChild(dadSpot!)
        
        childSpot = SKSpriteNode(imageNamed: "bubble_spot_down")
        childSpot?.position = CGPoint(x: self.size.width / 2, y: (self.size.height / 2) - width/6)
        childSpot?.size = CGSize(width: width, height: width / sr)
        childSpot?.zPosition = 3
        self.addChild(childSpot!)
        
        let bar = SKSpriteNode(color: UIColor(hexString: "#D12D2DFF"), size: CGSize(width: width*2.3, height: width/10))
        bar.position = CGPoint(x: self.size.width/2, y: self.size.height/2 + (childSpot?.size.height)! / 3)
        bar.zPosition = 2
        self.addChild(bar)
        
        addBubbles()
        loadPeople()
        
        EventHandler.getInstance().subscribe(BubbleScene.TOPIC_WATER, listener: self)
        
        Analytics.logEvent(AnalyticsEventViewItem, parameters: [
            AnalyticsParameterItemName: String(describing: BubbleScene.self) as NSObject
        ])
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
        
		var loadSpouse = true
		let showStepChildren = dataService.dbHelper.getProperty(DataService.PROPERTY_SHOW_STEP_CHILDREN)
        if showStepChildren != nil && showStepChildren == "false" {
			loadSpouse = false
		}
        dataService.getFamilyMembers(person, loadSpouse: loadSpouse, onCompletion: {people, err in
            if people != nil {
                for p in people! {
                    self.queue.append(p)
                }
            }
        })
        
        dataService.getParents(person, onCompletion: { parents, err in
            if parents == nil || parents!.count < 2 {
                self.loadPeople()
            }
            else {
                var bx = (self.size.width / 3) + CGFloat(arc4random_uniform(UInt32(self.width)))
                var by = (self.width / 2) + CGFloat(arc4random_uniform(UInt32(self.width)))
                
                self.child = PersonBubbleSprite()
                self.child?.size = CGSize(width: self.width, height: self.width)
                self.child?.position = CGPoint(x: bx, y: by)
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
                self.child?.physicsBody?.isDynamic = true
                let dx = self.width/2 - CGFloat(arc4random_uniform(UInt32(self.width)))
                let dy = self.width/2 - CGFloat(arc4random_uniform(UInt32(self.width)))
                let v = CGVector(dx: dx, dy: dy)
                self.addChild(self.child!)
                self.child?.physicsBody?.applyImpulse(v)
                
                dataService.getParentCouple(person, inParent: parents![0], onCompletion: {parents2, err in
                    bx = (self.size.width / 3) + CGFloat(arc4random_uniform(UInt32(self.width)))
                    by = (self.width / 2) + CGFloat(arc4random_uniform(UInt32(self.width)))
                    self.dad = PersonBubbleSprite()
                    self.dad?.size = CGSize(width: self.width, height: self.width)
                    self.dad?.position = CGPoint(x: bx, y: by)
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
                    self.dad?.physicsBody?.isDynamic = true
                    let dx2 = self.width/2 - CGFloat(arc4random_uniform(UInt32(self.width)))
                    let dy2 = self.width/2 - CGFloat(arc4random_uniform(UInt32(self.width)))
                    let v2 = CGVector(dx: dx2, dy: dy2)
                    self.addChild(self.dad!)
                    self.dad?.physicsBody?.applyImpulse(v2)
                    
                    bx = (self.size.width / 3) + CGFloat(arc4random_uniform(UInt32(self.width)))
                    by = (self.width / 2) + CGFloat(arc4random_uniform(UInt32(self.width)))
                    self.mom = PersonBubbleSprite()
                    self.mom?.size = CGSize(width: self.width, height: self.width)
                    self.mom?.position = CGPoint(x: bx, y: by)
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
                    self.mom?.physicsBody?.isDynamic = true
                    let dx3 = self.width/2 - CGFloat(arc4random_uniform(UInt32(self.width)))
                    let dy3 = self.width/2 - CGFloat(arc4random_uniform(UInt32(self.width)))
                    let v3 = CGVector(dx: dx3, dy: dy3)
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
            bubble.size = CGSize(width: w, height: w)
            let x = (self.size.width / 3) + CGFloat(arc4random_uniform(UInt32(width)))
            let y = (w / 2) + CGFloat(arc4random_uniform(UInt32(width)))
            bubble.position = CGPoint(x: x, y: y)
            bubble.zPosition = 7
            bubble.physicsBody = SKPhysicsBody(circleOfRadius: w/2)
            bubble.physicsBody?.categoryBitMask = 2
            bubble.physicsBody?.collisionBitMask = 1
            bubble.physicsBody?.restitution = 1.0
            bubble.physicsBody?.friction = 0.0
            bubble.physicsBody?.linearDamping = 0.0
            bubble.physicsBody?.angularDamping = 0.0
            bubble.physicsBody?.affectedByGravity = false
            bubble.physicsBody?.isDynamic = true
            
            let dx = w/2 - CGFloat(arc4random_uniform(UInt32(w)))
            let dy = w/2 - CGFloat(arc4random_uniform(UInt32(w)))
            let v = CGVector(dx: dx, dy: dy)
            
            self.addChild(bubble)
            self.bubbles.append(bubble)
            
            bubble.physicsBody?.applyImpulse(v)
        }
    }
    
    func nextSpot() {
        if nextBubble != nil {
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
        while (nextBubble == nil || nextBubble?.popped == true) {
            if r == 0 {
                nextBubble = child
                if nextBubble?.popped == true {
                    r = 1
                } else {
                    childSpot?.texture = SKTexture(imageNamed: "bubble_spot_down_h")
                    self.speak("Find the child in this family?")
                }
            }
            if r == 1 {
                nextBubble = mom
                if nextBubble?.popped == true {
                    r = 2
                } else {
                    momSpot?.texture = SKTexture(imageNamed: "bubble_spot_h")
                    var mother = "mother"
                    if mom?.person?.gender == GenderType.male {
                        mother = "father"
                    }
                    self.speak("Find the \(mother) in this family?")
                }
            }
            if r == 2 {
                nextBubble = dad
                if nextBubble?.popped == true {
                    r = 0
                }else {
                    dadSpot?.texture = SKTexture(imageNamed: "bubble_spot_h")
                    var father = "father"
                    if dad?.person?.gender == GenderType.female {
                        father = "mother"
                    }
                    self.speak("Find the \(father) in this family?")
                }
            }
        }
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        EventHandler.getInstance().unSubscribe(BubbleScene.TOPIC_WATER, listener: self)
    }
    
    override func onEvent(_ topic: String, data: NSObject?) {
        super.onEvent(topic, data: data)
        if topic == BubbleScene.TOPIC_WATER {
            if hasSoap {
                hasSoap = false
                addBubbles()
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastHighlightTime == 0 {
			lastHighlightTime = currentTime
		}
		else {
            if currentTime - lastHighlightTime > 10 {
                lastHighlightTime = currentTime
                if nextBubble != nil {
                    nextBubble!.highlight()
                }
            }
		}
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch in touches {
            let lastPoint = touch.location(in: self)
			let touchedNode = atPoint(lastPoint)
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
                    let aaction = SKAction.animate(with: popping, timePerFrame: 0.06)
                    let action = SKAction.sequence([aaction, SKAction.removeFromParent()])
                    touchedNode.run(action, completion: {
                        self.bubbles.removeObject(touchedNode as! SKSpriteNode)
                    }) 
                    let quietMode = DataService.getInstance().dbHelper.getProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET)
                    if quietMode == nil || quietMode == "false" {
                        let popSound = SKAction.playSoundFileNamed("pop", waitForCompletion: false)
                        self.run(popSound)
                    }
                } else if touchedNode == child || child?.children.contains(touchedNode) == true {
                    if nextBubble == child || child?.popped == true {
                        if child?.popped == false {
                            child?.popped = true
                            child?.removeAllActions()
                            let aaction = SKAction.animate(with: popping, timePerFrame: 0.06)
                            let action = SKAction.sequence([aaction, SKAction.removeFromParent()])
                            child?.bubble?.run(action)
                            
                            let quietMode = DataService.getInstance().dbHelper.getProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET)
                            if quietMode == nil || quietMode == "false" {
                                let popSound = SKAction.playSoundFileNamed("pop", waitForCompletion: false)
                                self.run(popSound)
                            }
                            
                            child?.physicsBody?.applyImpulse(CGVector(dx: 0,dy: 0))
                            
                            let moveAction = SKAction.move(to: (childSpot?.position)!, duration: 1.5)
                            child?.run(moveAction, completion: {
                                self.child?.physicsBody?.applyImpulse(CGVector(dx: 0,dy: 0))
                                self.child?.physicsBody = nil
                                self.child?.zPosition = 3
                            }) 
                            
                            self.run(SKAction.wait(forDuration: 2.0), completion: {
                                self.nextSpot()
                            }) 
							lastHighlightTime = 0
                        }
                    
                        self.sayGivenName(child!.person!)
                    } else {
                        let quietMode = DataService.getInstance().dbHelper.getProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET)
                        if quietMode == nil || quietMode == "false" {
                            let nopopSound = SKAction.playSoundFileNamed("nopop", waitForCompletion: false)
                            self.run(nopopSound)
                        }
                    }
                } else if touchedNode == mom || mom?.children.contains(touchedNode) == true {
                    if nextBubble == mom || mom?.popped == true {
                        if mom?.popped == false {
                            mom?.popped = true
                            mom?.removeAllActions()
                            let aaction = SKAction.animate(with: popping, timePerFrame: 0.06)
                            let action = SKAction.sequence([aaction, SKAction.removeFromParent()])
                            mom?.bubble?.run(action)
                            
                            let quietMode = DataService.getInstance().dbHelper.getProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET)
                            if quietMode == nil || quietMode == "false" {
                                let popSound = SKAction.playSoundFileNamed("pop", waitForCompletion: false)
                                self.run(popSound)
                            }
                            
                            mom?.physicsBody?.applyImpulse(CGVector(dx: 0,dy: 0))
                            
                            let moveAction = SKAction.move(to: (momSpot?.position)!, duration: 1.5)
                            mom?.run(moveAction, completion: {
                                self.mom?.physicsBody?.applyImpulse(CGVector(dx: 0,dy: 0))
                                self.mom?.physicsBody = nil
                                self.mom?.zPosition = 3
                            }) 
                            
                            self.run(SKAction.wait(forDuration: 2.0), completion: {
                                self.nextSpot()
                            }) 
							lastHighlightTime = 0
                        }
                        
                        self.sayGivenName(mom!.person!)
                    } else {
                        let quietMode = DataService.getInstance().dbHelper.getProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET)
                        if quietMode == nil || quietMode == "false" {
                            let nopopSound = SKAction.playSoundFileNamed("nopop", waitForCompletion: false)
                            self.run(nopopSound)
                        }
                    }
                } else if touchedNode == dad || dad?.children.contains(touchedNode) == true {
                    if nextBubble == dad || dad?.popped == true {
                        if dad?.popped == false {
                            dad?.popped = true
                            dad?.removeAllActions()
                            let aaction = SKAction.animate(with: popping, timePerFrame: 0.06)
                            let action = SKAction.sequence([aaction, SKAction.removeFromParent()])
                            dad?.bubble?.run(action)
                            
                            let quietMode = DataService.getInstance().dbHelper.getProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET)
                            if quietMode == nil || quietMode == "false" {
                                let popSound = SKAction.playSoundFileNamed("pop", waitForCompletion: false)
                                self.run(popSound)
                            }
                            
                            dad?.physicsBody?.applyImpulse(CGVector(dx: 0,dy: 0))
                            
                            let moveAction = SKAction.move(to: (dadSpot?.position)!, duration: 1.5)
                            dad?.run(moveAction, completion: {
                                self.dad?.physicsBody?.applyImpulse(CGVector(dx: 0,dy: 0))
                                self.dad?.physicsBody = nil
                                self.dad?.zPosition = 3
                            }) 
                            
                            self.run(SKAction.wait(forDuration: 2.0), completion: {
                                self.nextSpot()
                            }) 
							lastHighlightTime = 0
                        }
                        
                        self.sayGivenName(dad!.person!)
                    } else {
                        let quietMode = DataService.getInstance().dbHelper.getProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET)
                        if quietMode == nil || quietMode == "false" {
                            let nopopSound = SKAction.playSoundFileNamed("nopop", waitForCompletion: false)
                            self.run(nopopSound)
                        }
                    }
                }
            }
            break
        }
    }
}
