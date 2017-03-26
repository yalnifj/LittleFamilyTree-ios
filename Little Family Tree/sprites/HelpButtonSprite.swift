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
            
            let soundAction = SKAction.playSoundFileNamed("powerup_success", waitForCompletion: false)
            self.run(soundAction)
            
            on = false
            
            let fadeInAct = SKAction.wait(forDuration: 10)
            self.run(fadeInAct, completion: {
                self.texture = SKTexture(imageNamed: "lightbulb_on")
                self.on = true
            })
        } else {
            let soundAction = SKAction.playSoundFileNamed("beepboop", waitForCompletion: false)
            self.run(soundAction)
        }
    }
}
