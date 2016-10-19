//
//  LabelEventSprite.swift
//  Little Family Tree
//
//  Created by Melissa on 2/22/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class EventSprite: SKSpriteNode {
    var topic: String?
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if topic != nil {
            EventHandler.getInstance().publish(topic!, data: self)
        }
    }
}
