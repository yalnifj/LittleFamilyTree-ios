//
//  BirdHomeSprite.swift
//  Little Family Tree
//
//  Created by Melissa on 5/10/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class BirdHomeSprite: EventSprite {
    var action1:SKAction?
    var action2:SKAction?
    var action3:SKAction?
    var flipped = false
    var oposition:CGFloat!
    
    func createActions() {
        if action1==nil {
            action1 = SKAction.animate(with: [ SKTexture.init(imageNamed: "house_tree_bird"),
                SKTexture.init(imageNamed: "house_tree_bird1"),
                SKTexture.init(imageNamed: "house_tree_bird2"),
                SKTexture.init(imageNamed: "house_tree_bird1"),
                SKTexture.init(imageNamed: "house_tree_bird")], timePerFrame: 0.1)
        }
        
        if action2==nil {
            action2 = SKAction.group([
                SKAction.animate(with: [ SKTexture.init(imageNamed: "house_tree_bird3"),
                    SKTexture.init(imageNamed: "house_tree_bird4"),
                    SKTexture.init(imageNamed: "house_tree_bird5"),
                    SKTexture.init(imageNamed: "house_tree_bird6"),
                    SKTexture.init(imageNamed: "house_tree_bird7"),
                    SKTexture.init(imageNamed: "house_tree_bird")], timePerFrame: 0.1),
                SKAction.playSoundFileNamed("bird", waitForCompletion: false)
            ])
        }
        
        if action3 == nil {
            action3 = SKAction.wait(forDuration: 1.0)
        }
        
        let f = arc4random_uniform(2)
        if f > 0 {
            flipped = false
        } else {
            flipped = true
        }
        
        if flipped {
            self.xScale = -1
            self.position.x = oposition + self.size.width
            
        } else {
            self.xScale = 1
            self.position.x = oposition
        }
        
        var act = action1
        let a = arc4random_uniform(3)
        if a > 0 {
            act = action3
        }
        run(act!, completion: {
            self.createActions()
        }) 
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        run(action2!, completion: {
            EventHandler.getInstance().publish(GameScene.TOPIC_START_BIRD, data: self)
        }) 
    }
}
