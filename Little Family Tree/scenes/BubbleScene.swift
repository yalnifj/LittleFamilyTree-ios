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

    var queue = [LittlePerson]()
    var width = CGFloat(100)
    
    var faucet:SKSpriteNode?
    var soap:SKSpriteNode?
    var bubbles = [SKSpriteNode]()
    var popping = [SKTexture]()
    
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
		
        width = minD / 3
        
        let sinkTexture = SKTexture(imageNamed: "sink")
        let ratio = (width * 2) / sinkTexture.size().width
        let sink = SKSpriteNode(texture: sinkTexture)
        let r = sink.size.height / sink.size.width
        sink.size = CGSizeMake(width * 2, width * 2 * r)
        sink.position = CGPointMake(self.size.width / 2, 0)
        sink.zPosition = 1
        self.addChild(sink)
        
        let faucetTexture = SKTexture(imageNamed: "faucet1")
        faucet = SKSpriteNode(texture: faucetTexture)
        faucet?.size = CGSizeMake(faucetTexture.size().width * ratio, faucetTexture.size().height * ratio)
        faucet?.position = CGPointMake((self.size.width / 2) + (faucet?.size.width)!, sink.size.height)
        faucet?.zPosition = 2
        self.addChild(faucet!)
        
        let soapTexture = SKTexture(imageNamed: "soap1")
        soap = SKSpriteNode(texture: soapTexture)
        soap?.size = CGSizeMake(soapTexture.size().width * ratio, soapTexture.size().height * ratio)
        soap?.position = CGPointMake((self.size.width / 2) + (soap?.size.width)!, sink.size.height)
        soap?.zPosition = 2
        self.addChild(soap!)
        
        popping.append(SKTexture(imageNamed: "bubble_pop1"))
        popping.append(SKTexture(imageNamed: "bubble_pop2"))
        popping.append(SKTexture(imageNamed: "bubble_pop3"))
        popping.append(SKTexture(imageNamed: "bubble_pop4"))
        popping.append(SKTexture(imageNamed: "bubble_pop5"))
        
        addBubbles()
        loadPeople()
    }

    func loadPeople() {
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
            if parents == nil {
                self.loadPeople()
            }
            else {
                if self.bubbles.count < 5 {
                    self.addBubbles()
                }
            }
        })
    }
    
    func addBubbles() {
        let bcount = 5 + arc4random_uniform(10)
        for _ in 0..<bcount {
            let bubble = SKSpriteNode(imageNamed: "bubble")
            let w = (width / 2) + CGFloat(arc4random_uniform(UInt32(width / 2)))
            bubble.size = CGSizeMake(w, w)
            let x = (self.size.width / 3) + CGFloat(arc4random_uniform(UInt32(width)))
            let y = (w / 2) + CGFloat(arc4random_uniform(UInt32(width)))
            bubble.position = CGPointMake(x, y)
            bubble.zPosition = 3
            self.addChild(bubble)
            self.bubbles.append(bubble)
            
            
        }
    }
    
    override func willMoveFromView(view: SKView) {
        super.willMoveFromView(view)
    }
    
    override func update(currentTime: NSTimeInterval) {
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        for touch in touches {
            let lastPoint = touch.locationInNode(self)
			let touchedNode = nodeAtPoint(lastPoint)
            if touchedNode is SKSpriteNode {
                if touchedNode == faucet {
                    
                }
                else if touchedNode == soap {
                    
                } else if self.bubbles.contains(touchedNode as! SKSpriteNode) {
                    let aaction = SKAction.animateWithTextures(popping, timePerFrame: 0.6)
                    let action = SKAction.sequence([aaction, SKAction.removeFromParent()])
                    touchedNode.runAction(action)
                }
            }
        }
    }
}