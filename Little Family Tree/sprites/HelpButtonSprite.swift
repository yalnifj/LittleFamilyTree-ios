//
//  HelpButtonSprite.swift
//  Little Family Tree
//
//  Created by Bryan  Farnworth on 3/21/17.
//  Copyright © 2017 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class HelpButtonSprite : EventSprite {
    var on = true
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if on {
            super.touchesEnded(touches, with: event)
            self.texture = SKTexture(imageNamed: "lightbulb_off")
            
            on = false
            let fadeInNode = SKSpriteNode(imageNamed: "lightbulb_on")
            fadeInNode.size = self.size
            fadeInNode.position = CGPoint(x: 0, y: 0)
            fadeInNode.alpha = 0
            
            self.addChild(fadeInNode)
            
            let fadeInAct = SKAction.fadeIn(withDuration: 60)
            fadeInNode.run(fadeInAct, completion: {
                fadeInNode.removeFromParent()
                self.texture = SKTexture(imageNamed: "lightbulb_on")
                self.on = true
            })
        }
    }
}
