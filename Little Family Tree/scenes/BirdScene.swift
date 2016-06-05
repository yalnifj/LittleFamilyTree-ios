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
        for s in sprites {
            s.removeFromParent()
        }
        sprites.removeAll()
        
        let height = self.size.height - topBar!.size.height
        let width = min(self.size.width, height)
        if width != self.size.width {
            portrait = false
        }
        
        let branch2 = SKSpriteNode(imageNamed: "branch2")
        let br2 = branch2.size.width / branch2.size.height
        branch2.size.width = self.size.width * 0.7
        branch2.size.height = branch2.size.width / br2
        branch2.position = CGPointMake(self.size.width - branch2.size.width / 2, self.size.height / 2)
        branch2.zPosition = 1
        sprites.append(branch2)
        self.addChild(branch2)
        sprites.append(branch2)
        
        let branch1 = SKSpriteNode(imageNamed: "branch1")
        let br1 = branch1.size.width / branch1.size.height
        branch1.size.height = branch2.size.height * 0.8
        branch1.size.width = branch1.size.height * br1
        branch1.position = CGPointMake(self.size.width - (branch1.size.width * 1.8) / 2, self.size.height / 2 - branch1.size.height / 2)
        branch1.zPosition = 2
        sprites.append(branch1)
        self.addChild(branch1)
        sprites.append(branch1)
        
        let bird = AnimatedStateSprite(imageNamed: "house_tree_bird")
        let br = bird.size.width / bird.size.height
        bird.size.width = branch1.size.width * 2
        bird.size.height = bird.size.width / br
        bird.position = CGPointMake(branch2.position.x, branch2.position.y + bird.size.height)
        self.addChild(bird)
        sprites.append(bird)
    }
	
	override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        super.update(currentTime)

		if animator != nil {
			animator!.update(currentTime)
		}
    }
}