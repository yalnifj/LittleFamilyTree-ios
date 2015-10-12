//
//  SplashScene.swift
//  Little Family Tree
//
//  Created by Melissa on 10/7/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import SpriteKit

class SplashScene: SKScene {
    override func didMoveToView(view: SKView) {        
        let logo = SKSpriteNode(imageNamed: "little_family_logo")
        logo.position = CGPointMake(0.5, 0.5)
        self.addChild(logo)

    }
    
    override func update(currentTime: CFTimeInterval) {
    }
}
