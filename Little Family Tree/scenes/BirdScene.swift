//
//  BirdScene.swift
//  Little Family Tree
//
//  Created by Melissa on 5/12/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class BirdScene: LittleFamilyScene {
    var portrait = true
    
    var sprites = [SKNode]()
	
	var animator:SpriteAnimator?
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        self.size.width = view.bounds.width
        self.size.height = view.bounds.height
        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        let background = SKSpriteNode(imageNamed: "tree_background")
        background.position = CGPointMake(self.size.width/2, self.size.height/2)
        background.size.width = self.size.width
        background.size.height = self.size.height
        background.zPosition = 0
        self.addChild(background)
        
        setupTopBar()
        
        showCutScene()
    }

    func showCutScene() {
        let height = self.size.height - topBar!.size.height
        let width = min(self.size.width, height)
        if width != self.size.width {
            portrait = false
        }
        
        let branch2 = SKSpriteNode(imageNamed: "branch2")
        let br2 = branch2.size.width / branch2.size.height
        let ratio = branch2.size.width / (self.size.width / 2)
        branch2.size.width = self.size.width / 2
        branch2.size.height = self.size.width / br2
        branch2.position = CGPointMake(branch2.size.width, branch2.size.height)
        branch2.zPosition = 1
        sprites.append(branch2)
        self.addChild(branch2)
        
        let branch1 = SKSpriteNode(imageNamed: "branch1")
        branch1.size.width = branch1.size.width / ratio
        branch1.size.height = branch1.size.height / ratio
        branch1.position = CGPointMake(branch2.position.x + branch2.size.width / 4, branch1.size.height)
        branch1.zPosition = 2
        sprites.append(branch1)
        self.addChild(branch1)
    }
	
	override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        super.update(currentTime)

		if animator != nil {
			animator!.update(currentTime)
		}
    }
}