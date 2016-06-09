//
//  BirdScene.swift
//  Little Family Tree
//
//  Created by Melissa on 5/12/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class BirdScene: LittleFamilyScene, TreeWalkerListener {
    var portrait = true
    
	var family:[LittlePerson]?
	
    var sprites = [SKNode]()
	
	var animator:SpriteAnimator?
	var treeWalker:TreeWalker?
	
	var showingCutScene = true
    
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
		
		treeWalker = TreeWalker(self.selectedPerson!, listener: self, reusePeople: false)
        treeWalker!.loadFamilyMembers();
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
		
		animator = SpriteAnimator()
        
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
		bird.zPosition = 5
        bird.position = CGPointMake(branch2.position.x, branch2.position.y + bird.size.height)
        let action1 = SKAction.animateWithTextures([ SKTexture.init(imageNamed: "house_tree_bird"),
            SKTexture.init(imageNamed: "house_tree_bird1"),
            SKTexture.init(imageNamed: "house_tree_bird2"),
            SKTexture.init(imageNamed: "house_tree_bird1"),
            SKTexture.init(imageNamed: "house_tree_bird")], timePerFrame: 0.1)
        bird.addAction(1, action: action1)
        let action2 = SKAction.animateWithTextures([ SKTexture.init(imageNamed: "house_tree_bird3"),
            SKTexture.init(imageNamed: "house_tree_bird4"),
            SKTexture.init(imageNamed: "house_tree_bird5"),
            SKTexture.init(imageNamed: "house_tree_bird6"),
            SKTexture.init(imageNamed: "house_tree_bird7"),
            SKTexture.init(imageNamed: "house_tree_bird")], timePerFrame: 0.1)
        bird.addAction(2, action: action2)
        bird.addSound(2, soundFile: "bird")
        self.addChild(bird)
        sprites.append(bird)
		
		animator.addTiming(SpriteStateTiming(2, sprite: bird, state: 1))
		animator.addTiming(SpriteStateTiming(2.5, sprite: bird, state: 0))
		animator.addTiming(SpriteStateTiming(5, sprite: bird, state: 1))
		animator.addTiming(SpriteStateTiming(5.5, sprite: bird, state: 0))
		animator.addTiming(SpriteStateTiming(6, sprite: bird, state: 2))
		animator.addTiming(SpriteStateTiming(7, sprite: bird, state: 0))
		animator.addTiming(SpriteStateTiming(15, sprite: bird, state: 1))
		animator.addTiming(SpriteStateTiming(15.5, sprite: bird, state: 0))
		
		let shake1 = SKAction.rotateByAngle(0.1, duration: 0.25)
		let shake2 = SKAction.rotateByAngle(-0.1, duration: 0.25)
		let shakeGroup = SKAction.sequence([shake1, shake2])
		let shake3 = SKAction.repeatActionForever(shakeGroup)
		let lact1 = SKAction.moveToX(self.size.width, duration: 2)
		let leaf = SKTexture(imageNamed: "leaf_stem")
		let leafWidth = bird.size.width * 0.8
		let leafHeight = bird.size.width * 0.8
		if family != nil && family.count > 0 {
			let leaves = [
				[0.1, -0.4, 45],
				[-0.75, -0.4, -55],
				[-0.75, -1.0, -30],
				[-0.3, -1.0, 15],
				[-0.8, 0.3, -75],
				[0.2, 0.1, 60],
				[0.25, 0.7, 90]
			]
			
			let p = 0
			for f in 0..<leaves.count {
				let person:LittlePerson? = nil
				let r = arc4random_uniform(UInt32(6))
				if r > 0 && f < family.count {
					person = family![p]
					p += 1
				}
				
				let leaf1 = PersonNameSprite(texture: leaf)
				leaf1.showLabel = false
				leaf1.position = CGPointMake( branch1.position.x * leaves[f][0], branch1.position.y * leaves[f][1])
				leaf1.size.width = leafWidth
				leaf1.size.height = leafHeight
				leaf1.zRotation = leaves[f][2]
				leaf1.zPosition = 4
				if person != nil {
					leaf1.person = person
				}
				self.addChild(leaf1)
				sprites.append(leaf1)
				
				animator.addTiming(SpriteActionTiming(10, sprite: leaf1, action: shake3))
				animator.addTiming(SpriteActionTiming(12.0 + CGFloat(arc4random_uniform(150)/100.0), sprite: leaf1, action: lact1)
			}
			
			let smallleaves = [
				[0.75, -0.6, 45],
				[-0.05, -0.6, -55],
				[-0.5, 0, -15],
				[-0.95, 0.7, -115]
			]
			
			for f in 0..<smallleaves.count {
				let person:LittlePerson? = nil
				let r = arc4random_uniform(UInt32(3))
				if r > 0 && f < family.count {
					person = family![p]
					p += 1
				}
				
				let leaf1 = PersonNameSprite(texture: leaf)
				leaf1.showLabel = false
				leaf1.size.width = leafWidth * 0.6
				leaf1.size.height = leafHeight * 0.6
				leaf1.position = CGPointMake( branch1.position.x * smallleaves[f][0], branch1.position.y * smallleaves[f][1])
				leaf1.zRotation = smallleaves[f][2]
				leaf1.zPosition = 4
				if person != nil {
					leaf1.person = person
				}
				self.addChild(leaf1)
				sprites.append(leaf1)
				
				animator.addTiming(SpriteActionTiming(10, sprite: leaf1, action: shake3))
				animator.addTiming(SpriteActionTiming(11.5 + CGFloat(arc4random_uniform(100)/100.0), sprite: leaf1, action: lact1)
			}
			
			animator.start()
		}
    }
	
	override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        super.update(currentTime)

		if animator != nil {
			animator!.update(currentTime)
		}
    }
	
	override func onComplete(family:[LittlePerson]) {
		self.family = family
		
		if showingCutScene {
			showCutScene()
		}
	}
}