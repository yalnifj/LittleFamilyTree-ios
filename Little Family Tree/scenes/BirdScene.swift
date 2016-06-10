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
	static var TOPIC_SKIP_CUTSCENE = "topicSkipCutScene"
	
    var portrait = true
    
	var family:[LittlePerson]?
	
    var sprites = [SKNode]()
	var peopleSprites = [PersonNameSprite]()
	var nestSprites = [PersonNameSprite]()
	var missedSprites = [PersonNameSprite]()
	var backgoundTiles = [SKSpriteNode]()
	
	var tiles = [SKTexture]()
	var leaves = [SKTexture]()
	
	var cloud:AnimatedStateSprite!
	var bird:AnimatedStateSprite!
	var animator:SpriteAnimator!
	var treeWalker:TreeWalker!
	
	var showingCutScene = true
	var missed = 0
	var gameOver = false
	var spritesCreated = false
	
	var boardWidth = CGFloat(0)
	
	var tileOffset = CGFloat(0)
	
	var tileMove = CGFloat(1)
	var timeStep = 0.2
    
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
		
		let tile1 = SKTexture(imageNamed: "bird_tile1")
		tiles.append(tile1)
		tiles.append(tile1)
		tiles.append(tile1)
		tiles.append(tile1)
		tiles.append(tile1)
		tiles.append(tile1)
		tiles.append(SKTexture(imageNamed: "bird_tile2"))
		tiles.append(SKTexture(imageNamed: "bird_tile3"))
		tiles.append(SKTexture(imageNamed: "bird_tile4"))
		tiles.append(SKTexture(imageNamed: "bird_tile5"))
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
		
		let quietMode = DataService.getInstance().dbHelper.getProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET)
		
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
			
			cloud = AnimatedStateSprite(imageNamed: "cloud1")
			let cr = cloud!.size.width / cloud.size.height
			cloud.size.width = self.size.width * 1.60
			cloud.size.height = cloud!.size.width / cr
			cloud.position = CGPointMake(-cloud!.size.width / 2, branch1.position.y)
			cloud.zPosition = 5
			
			let cact1 = SKAction.moveToX(self.size.width / 3, duration: 4)
			animator.addTiming(SpriteActionTiming(1, sprite: cloud, action: cact1)
			
			cloud.addTexture(1, texture: SKTexture(imageNamed: "cloud2"))
			animator.addTiming(SpriteStateTiming(7.5, sprite: cloud, state: 1))
			if quietMode == nil || quietMode == "false" {
				let cact1sound = SKAction.playSoundFileNamed("grumble", waitForCompletion: false)
				animator.addTiming(SpriteActionTiming(7.5, sprite: cloud, action: cact1sound))
			}
			
			let cact2 = SKAction.animateWithTextures([ SKTexture(imageNamed: "cloud3"),
				SKTexture(imageNamed: "cloud4"),
				SKTexture(imageNamed: "cloud5"),
				SKTexture(imageNamed: "cloud6"),
				SKTexture(imageNamed: "cloud7"),
				SKTexture(imageNamed: "cloud8"),
				SKTexture(imageNamed: "cloud9"),
				SKTexture(imageNamed: "cloud10"),
				SKTexture(imageNamed: "cloud11"),
				SKTexture(imageNamed: "cloud12")
			], timePerFrame: 0.1)
			animator.addTiming(SpriteActionTiming(10, sprite: cloud, action: cact2))
			
			if quietMode == nil || quietMode == "false" {
				let cact2sound = SKAction.playSoundFileNamed("blowing", waitForCompletion: false)
				animator.addTiming(SpriteActionTiming(10, sprite: cloud, action: cact2sound))
			}
			
			cloud.addTexture(2, texture: SKTexture(imageNamed: "cloud11"))
			cloud.addTexture(2, texture: SKTexture(imageNamed: "cloud12"))
			animator.addTiming(SpriteStateTiming(10.9, sprite: cloud, state: 2))
			
			let cact3 = SKAction.animateWithTextures([ SKTexture(imageNamed: "cloud13"),
				SKTexture(imageNamed: "cloud14"),
				SKTexture(imageNamed: "cloud15")
			], timePerFrame: 0.1)
			animator.addTiming(SpriteActionTiming(14, sprite: cloud, action: cact3))
			
			cloud.addTexture(3, texture: SKTexture(imageNamed: "cloud15"))
			animator.addTiming(SpriteStateTiming(14.3, sprite: cloud, state: 3))
			
			cloud.addTexture(4, texture: SKTexture(imageNamed: "cloud16"))
			animator.addTiming(SpriteStateTiming(15.5, sprite: cloud, state: 4))
			if quietMode == nil || quietMode == "false" {
				let cact4sound = SKAction.playSoundFileNamed("humph", waitForCompletion: false)
				animator.addTiming(SpriteActionTiming(15.5, sprite: cloud, action: cact4sound))
			}
			animator.addTiming(SpriteStateTiming(15.8, sprite: cloud, state: 3))
			let cact5 = SKAction.moveToX(self.size.width + cloud.size.width / 2, duration: 3)
			animator.addTiming(SpriteActionTiming(15.9, sprite: cloud, action: cact5))
			
			animator.addTiming(SpriteStateTiming(22, sprite: cloud, state: 3))
			
			self.addChild(cloud)
			sprites.append(cloud)
			
			let skipButton = EventSprite(imageNamed: "ff")
			let sr = skipButton.size.width / skipButton.size.height
			skipButton.size.width = min(self.size.width, self.size.height) / 5
			skipButton.size.height = skipButton.size.width / sr
			skipButton.position = CGPointMake(self.size.width - skipButton.size.width, skipButton.size.height)
			skipButton.zPosition = 6
			skipButton.topic = BirdScene.TOPIC_SKIP_CUTSCENE
			skipButton.userInteractionEnabled = true
			self.addChild(cloud)
			sprites.append(cloud)
			
			animator.start()
		}
    }
	
	func createSprites() {
		for s in sprites {
            s.removeFromParent()
        }
        sprites.removeAll()
		
		peopleSprites.removeAll()
		nestSprites.removeAll()
		missedSprites.removeAll()
		backgroundTiles.removeAll()
		
		let height = self.size.height
        var width = self.size.width
		
		if !portrait {
			let wr = self.size.width / self.size.height
			width = self.size.height / wr
		}
		
		let basex = (self.size.width / 2) - (width / 2)
		let tx = CGFloat(0)
		let ty = self.size.height
		while (ty > 0) {
			let rt = arc4random_uniform(UInt32(tiles.count))
			let bgSprite = SKSpriteNode(texture: tiles[r])
			bgSprite.zPosition = 1
			bgSprite.position = CGPointMake(basex + tx, ty)
			backgoundTiles.append(bgSprite)
			sprites.append(bgSprite)
			self.addChild(bgSprite)
			
			tx = tx + bgSprite.size.width - 2
			if tx >= width {
				ty = ty - tiles[0].size().height - 2
			}
		}
		
		let titleSprite = SKSpriteNode(imageNamed: "rr_title")
		let tr = titleSprite.size.width / titleSprite.size.height
		titleSprite.size.width = width * 0.8
		titleSprite.size.height = titleSprite.size.width / tr
		titleSprite.zPosition = 2
		titleSprite.position = CGPointMake(self.size.width / 2, (self.size.height / 2) + titleSprite.size.height)
		let titleAct = SKAction.moveToY(0, duration: 2)
		titleSprite.runAction(titleAct)
		sprites.append(titleSprite)
		self.addChild(titleSprite)
		
		bird = AnimatedStateSprite(imageNamed: "flying_bird1")
		bird.zPosition = 3
		bird.position = CGPointMake(self.size.width / 2, bird.size.height * 2)
		bird.addTexture(0, SKTexture(imageNamed: "flying_bird2"))
		bird.addTexture(0, SKTexture(imageNamed: "flying_bird3"))
		sprites.append(bird)
		self.addChild(bird)
		
		leaves.append(SKTexture(imageNamed: "leaf1"))
		leaves.append(SKTexture(imageNamed: "leaf2"))
		leaves.append(SKTexture(imageNamed: "leafb1"))
		leaves.append(SKTexture(imageNamed: "leafb2"))
		
		boardWidth = width
		
		speak("Rescue your Relatives!")
		spritesCreated = true
	}
	
	func addTileRow() {
		let tx = CGFloat(0)
		let ty = self.size.height
		let basex = (self.size.width / 2) - (width / 2)
		while tx < boardWidth {
			let rt = arc4random_uniform(UInt32(tiles.count))
			let bgSprite = SKSpriteNode(texture: tiles[r])
			bgSprite.zPosition = 1
			bgSprite.position = CGPointMake(basex + tx, ty)
			backgoundTiles.removeFirst()
			backgoundTiles.append(bgSprite)
			sprites.append(bgSprite)
			self.addChild(bgSprite)
			
			tx = tx + bgSprite.size.width - 2
		}
	}
	
	var lastUpdate:CFTimeInterval = 0
	override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        super.update(currentTime)

		if animator != nil {
			animator!.update(currentTime)
			
			if showingCutScene && animator.finished {
				showCutScene = false
				createSprites()
			}
		}
		
		if spritesCreated {
			if currentTime - lastUpdate > timeStep {
				lastUpdate = currentTime
				tileOffset += tileMove
				for bgs in backgroundTiles {
					bgs.position.y -= tileMove
				}
				
				if  tileOffset >= tiles[0].size().height -2 {
					tileOffset = CGFloat(0)
					addTileRow()
				}
			}
		}
		
    }
	
	override func onComplete(family:[LittlePerson]) {
		self.family = family
		
		if showingCutScene {
			showCutScene()
		}
	}
}