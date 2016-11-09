//
//  BirdScene.swift
//  Little Family Tree
//
//  Created by Melissa on 5/12/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import Foundation
import SpriteKit
import CoreMotion
import AudioToolbox

class BirdScene: LittleFamilyScene, TreeWalkerListener {
	static var TOPIC_SKIP_CUTSCENE = "topicSkipCutScene"
	static var TOPIC_PLAY_AGAIN = "topicPlayAgain"
	
    var portrait = true
    
	var family = [LittlePerson]()
	
    var sprites = [SKNode]()
	var peopleSprites = [PersonLeafSprite]()
	var nestSprites = [PersonLeafSprite]()
	var missedSprites = [PersonLeafSprite]()
	var backgroundTiles = [SKSpriteNode]()
	
	var tiles = [SKTexture]()
	var leaves = [SKTexture]()
	
	var cloud:AnimatedStateSprite!
	var bird:AnimatedStateSprite!
	var playAgainButton:EventSprite!
	var playAgainPosition:CGPoint!
	var animator:SpriteAnimator!
	var treeWalker:TreeWalker!
	
	var showingCutScene = true
	var missed = 0
	var gameOver = false
	var spritesCreated = false
	
	var boardWidth = CGFloat(0)
	
	var tileOffset = CGFloat(0)
	
	var tileMove = CGFloat(1)
	var timeStep = 0.03
	
	var addPersonDelay = 0.0
	var lastAddPersonTime = 0.0
	
	var addCloudDelay = 0.0
	var lastAddCloudTime = 0.0
	var windPower = CGFloat(0)
	
	var motionManager: CMMotionManager!
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.size.width = view.bounds.width
        self.size.height = view.bounds.height
        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        let background = SKSpriteNode(imageNamed: "tree_background")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.size.width = self.size.width
        background.size.height = self.size.height
        background.zPosition = 0
        self.addChild(background)
        
        setupTopBar()
		
		treeWalker = TreeWalker(person: self.selectedPerson!, listener: self, reusePeople: false)
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
        
        EventHandler.getInstance().subscribe(BirdScene.TOPIC_SKIP_CUTSCENE, listener: self)
		EventHandler.getInstance().subscribe(BirdScene.TOPIC_PLAY_AGAIN, listener: self)
        
		motionManager = CMMotionManager()
		motionManager.startAccelerometerUpdates()
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        EventHandler.getInstance().unSubscribe(BirdScene.TOPIC_SKIP_CUTSCENE, listener: self)
        EventHandler.getInstance().unSubscribe(BirdScene.TOPIC_PLAY_AGAIN, listener: self)
		
		motionManager.stopAccelerometerUpdates()
    }
    
    override func onEvent(_ topic: String, data: NSObject?) {
        super.onEvent(topic, data: data)
        if (topic==BirdScene.TOPIC_SKIP_CUTSCENE) {
            if (animator != nil) {
                animator.finished = true
            }
        } else if (topic==BirdScene.TOPIC_PLAY_AGAIN) {
            createSprites()
        } else if topic == LittleFamilyScene.TOPIC_TRY_PRESSED {
            let tryCount = getTryCount("try_bird_count")
            DataService.getInstance().dbHelper.saveProperty("try_bird_count", value: "\(tryCount)")
            if animator != nil {
                animator.start()
            }
        }
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
        if !portrait {
            branch2.size.width = self.size.width * 0.5
        }
        branch2.size.height = branch2.size.width / br2
        branch2.position = CGPoint(x: self.size.width - branch2.size.width / 2, y: self.size.height / 2)
        branch2.zPosition = 1
        sprites.append(branch2)
        self.addChild(branch2)
        sprites.append(branch2)
        
        let branch1 = SKSpriteNode(imageNamed: "branch1")
        let br1 = branch1.size.width / branch1.size.height
        branch1.size.height = branch2.size.width * 0.8
        branch1.size.width = branch1.size.height * br1
        branch1.position = CGPoint(x: self.size.width - branch1.size.width, y: self.size.height / 2 + branch1.size.height *
         0.2)
        branch1.zPosition = 2
        sprites.append(branch1)
        self.addChild(branch1)
        sprites.append(branch1)
        
        let bird = AnimatedStateSprite(imageNamed: "house_tree_bird")
        let br = bird.size.width / bird.size.height
        bird.size.width = branch1.size.width * 1.8
        bird.size.height = bird.size.width / br
		bird.zPosition = 15
        bird.position = CGPoint(x: branch2.position.x, y: branch2.position.y - bird.size.height * 0.1)
        let action1 = SKAction.animate(with: [ SKTexture.init(imageNamed: "house_tree_bird"),
            SKTexture.init(imageNamed: "house_tree_bird1"),
            SKTexture.init(imageNamed: "house_tree_bird2"),
            SKTexture.init(imageNamed: "house_tree_bird1"),
            SKTexture.init(imageNamed: "house_tree_bird")], timePerFrame: 0.1)
        bird.addAction(1, action: action1)
        let action2 = SKAction.animate(with: [ SKTexture.init(imageNamed: "house_tree_bird3"),
            SKTexture.init(imageNamed: "house_tree_bird4"),
            SKTexture.init(imageNamed: "house_tree_bird5"),
            SKTexture.init(imageNamed: "house_tree_bird6"),
            SKTexture.init(imageNamed: "house_tree_bird7"),
            SKTexture.init(imageNamed: "house_tree_bird")], timePerFrame: 0.1)
        bird.addAction(2, action: action2)
        bird.addSound(2, soundFile: "bird")
        self.addChild(bird)
        sprites.append(bird)
		
		animator.addTiming(SpriteStateTiming(time: 0.1, sprite: bird, state: 1))
		animator.addTiming(SpriteStateTiming(time: 0.6, sprite: bird, state: 0))
		animator.addTiming(SpriteStateTiming(time: 1.5, sprite: bird, state: 1))
		animator.addTiming(SpriteStateTiming(time: 2, sprite: bird, state: 0))
		animator.addTiming(SpriteStateTiming(time: 2.5, sprite: bird, state: 2))
		animator.addTiming(SpriteStateTiming(time: 3.5, sprite: bird, state: 0))
		animator.addTiming(SpriteStateTiming(time: 10.5, sprite: bird, state: 1))
		animator.addTiming(SpriteStateTiming(time: 11, sprite: bird, state: 0))
		
		let shake1 = SKAction.rotate(byAngle: 0.15, duration: 0.3)
		let shake2 = SKAction.rotate(byAngle: -0.15, duration: 0.3)
		let shakeGroup = SKAction.sequence([shake1, shake2])
		let shake3 = SKAction.repeatForever(shakeGroup)
		
		let leaf = SKTexture(imageNamed: "leaf_stem")
		let leafWidth = bird.size.width * 0.7
		let leafHeight = bird.size.width * 0.7
        let lact1 = SKAction.moveTo(x: self.size.width + leafWidth, duration: 1.0)
        
		if family.count > 0 {
			var leaves = [[Float]]()
            if portrait {
                leaves.append([0.86, 1.37, Float(45.0 * 0.0174)])
                leaves.append([1.05, 1.37, Float(-55.0 * 0.01745)])
                leaves.append([0.86, 1.27, Float(40.0 * 0.0174)])
                leaves.append([1.06, 1.26, Float(-35.0 * 0.0174)])
                leaves.append([0.86, 1.12, Float(75.0 * 0.0174)])
                leaves.append([1.085, 1.11, Float(-60.0 * 0.0174)])
                leaves.append([1.085, 0.95, Float(-90.0 * 0.0174)])
            } else {
                leaves.append([0.94, 1.47, Float(45.0 * 0.0174)])
                leaves.append([1.05, 1.47, Float(-55.0 * 0.01745)])
                leaves.append([0.94, 1.37, Float(40.0 * 0.0174)])
                leaves.append([1.05, 1.36, Float(-35.0 * 0.0174)])
                leaves.append([0.93, 1.22, Float(75.0 * 0.0174)])
                leaves.append([1.05, 1.21, Float(-60.0 * 0.0174)])
                leaves.append([1.065, 0.95, Float(-90.0 * 0.0174)])
            }
			
			var p = 0
			for f in 0..<leaves.count {
				var person:LittlePerson? = nil
				let r = arc4random_uniform(UInt32(6))
				if r > 0 && f < family.count {
					person = family[p]
					p += 1
				}
				
				let leaf1 = PersonLeafSprite(texture: leaf)
				leaf1.position = CGPoint( x: branch1.position.x * CGFloat(leaves[f][0]), y: branch1.position.y * CGFloat(leaves[f][1]))
				leaf1.size.width = leafWidth
				leaf1.size.height = leafHeight
				leaf1.zRotation = CGFloat(leaves[f][2])
				leaf1.zPosition = 4 + CGFloat(f)
				if person != nil {
					leaf1.person = person
				}
				self.addChild(leaf1)
				sprites.append(leaf1)
				
				animator.addTiming(SpriteActionTiming(time: 7, sprite: leaf1, action: shake3))
				animator.addTiming(SpriteActionTiming(time: 8.8 + Double(arc4random_uniform(150)) / 100.0, sprite: leaf1, action: lact1))
			}
			
			var smallleaves = [[Float]]()
            if portrait {
				smallleaves.append([0.44, 1.108, Float(45.0 * 0.0174)])
				smallleaves.append([0.55, 1.102, Float(-55.0 * 0.0174)])
				smallleaves.append([0.34, 1.0, Float(15.0 * 0.0174)])
				smallleaves.append([0.45, 0.99, Float(-15.0 * 0.0174)])
            } else {
                smallleaves.append([0.65, 1.108, Float(45.0 * 0.0174)])
                smallleaves.append([0.71, 1.102, Float(-55.0 * 0.0174)])
                smallleaves.append([0.57, 1.0, Float(15.0 * 0.0174)])
                smallleaves.append([0.65, 0.98, Float(-15.0 * 0.0174)])
            }
			
			for f in 0..<smallleaves.count {
				var person:LittlePerson? = nil
				let r = arc4random_uniform(UInt32(3))
				if r > 0 && p < family.count {
					person = family[p]
					p += 1
				}
				
				let leaf1 = PersonLeafSprite(texture: leaf)
				leaf1.size.width = leafWidth * 0.6
				leaf1.size.height = leafHeight * 0.6
				leaf1.position = CGPoint( x: branch1.position.x * CGFloat(smallleaves[f][0]), y: branch1.position.y * CGFloat(smallleaves[f][1]))
				leaf1.zRotation = CGFloat(smallleaves[f][2])
				leaf1.zPosition = 4 + CGFloat(f)
				if person != nil {
					leaf1.person = person
				}
				self.addChild(leaf1)
				sprites.append(leaf1)
				
                animator.addTiming(SpriteActionTiming(time: 7.5, sprite: leaf1, action: shake3))
                animator.addTiming(SpriteActionTiming(time: 8 + Double(arc4random_uniform(150))/100.0, sprite: leaf1, action: lact1))
			}
			
			cloud = AnimatedStateSprite(imageNamed: "cloud1")
			let cr = cloud!.size.width / cloud.size.height
			cloud.size.width = branch2.size.width * 2
			cloud.size.height = cloud!.size.width / cr
			cloud.position = CGPoint(x: -cloud!.size.width / 2, y: branch1.position.y)
			cloud.zPosition = 16
			
			let cact1 = SKAction.moveTo(x: self.size.width / 3, duration: 2.5)
            animator.addTiming(SpriteActionTiming(time: 0.1, sprite: cloud, action: cact1))
			
			cloud.addTexture(1, texture: SKTexture(imageNamed: "cloud2"))
            animator.addTiming(SpriteStateTiming(time: 3.5, sprite: cloud, state: 1))
			if quietMode == nil || quietMode == "false" {
				let cact1sound = SKAction.playSoundFileNamed("grumble.mp3", waitForCompletion: false)
                animator.addTiming(SpriteActionTiming(time: 3.5, sprite: self, action: cact1sound))
			}
			
			let cact2 = SKAction.animate(with: [ SKTexture(imageNamed: "cloud3"),
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
            animator.addTiming(SpriteActionTiming(time: 6.0, sprite: cloud, action: cact2))
			
			if quietMode == nil || quietMode == "false" {
				let cact2sound = SKAction.playSoundFileNamed("blowing", waitForCompletion: false)
				animator.addTiming(SpriteActionTiming(time: 6.2, sprite: cloud, action: cact2sound))
			}
			
            let cactr2 = SKAction.repeatForever(SKAction.animate(with: [SKTexture(imageNamed: "cloud11"),SKTexture(imageNamed: "cloud12")], timePerFrame: 0.2))
            animator.addTiming(SpriteActionTiming(time: 7.5, sprite: cloud, action: cactr2))
			
            let cstop = SKAction.run({ self.cloud.removeAllActions() })
            animator.addTiming(SpriteActionTiming(time: 10.8, sprite: cloud, action: cstop))
            
			let cact3 = SKAction.animate(with: [ SKTexture(imageNamed: "cloud13"),
				SKTexture(imageNamed: "cloud14"),
				SKTexture(imageNamed: "cloud15")
			], timePerFrame: 0.1)
			animator.addTiming(SpriteActionTiming(time: 11, sprite: cloud, action: cact3))
			
			cloud.addTexture(3, texture: SKTexture(imageNamed: "cloud15"))
			animator.addTiming(SpriteStateTiming(time: 11.3, sprite: cloud, state: 3))
			
			cloud.addTexture(4, texture: SKTexture(imageNamed: "cloud16"))
			animator.addTiming(SpriteStateTiming(time: 12.5, sprite: cloud, state: 4))
			if quietMode == nil || quietMode == "false" {
				let cact4sound = SKAction.playSoundFileNamed("humph", waitForCompletion: false)
				animator.addTiming(SpriteActionTiming(time: 12.5, sprite: cloud, action: cact4sound))
			}
			animator.addTiming(SpriteStateTiming(time: 12.8, sprite: cloud, state: 3))
			let cact5 = SKAction.moveTo(x: self.size.width + cloud.size.width / 2, duration: 2)
			animator.addTiming(SpriteActionTiming(time: 12.9, sprite: cloud, action: cact5))
			
			animator.addTiming(SpriteStateTiming(time: 16, sprite: cloud, state: 3))
			
			self.addChild(cloud)
			sprites.append(cloud)
			
			let skipButton = EventSprite(imageNamed: "ff")
			let sr = skipButton.size.width / skipButton.size.height
			skipButton.size.width = min(self.size.width, self.size.height) / 5
			skipButton.size.height = skipButton.size.width / sr
			skipButton.position = CGPoint(x: self.size.width - skipButton.size.width/2, y: skipButton.size.height/2)
			skipButton.zPosition = 6
			skipButton.topic = BirdScene.TOPIC_SKIP_CUTSCENE
			skipButton.isUserInteractionEnabled = true
			self.addChild(skipButton)
			sprites.append(skipButton)
			
            self.userHasPremium({ premium in
                if !premium {
                    let tryCount = self.getTryCount("try_bird_count")
                    
                    var tryAvailable = true
                    if tryCount > 3 {
                        tryAvailable = false
                    }
                    
                    self.showLockDialog(tryAvailable, tries: LittleFamilyScene.FREE_TRIES - (tryCount - 1))
                } else {
                    self.animator.start()
                }
            })
		}
    }
	
	func createSprites() {
        showingCutScene = false
        
		for s in sprites {
            s.removeFromParent()
        }
        sprites.removeAll()
		
		peopleSprites.removeAll()
		nestSprites.removeAll()
		missedSprites.removeAll()
		backgroundTiles.removeAll()
		
		gameOver = false
		lastAddPersonTime = 0.0
        lastAddCloudTime = 0.0
        tileMove = CGFloat(1)
		
        var width = self.size.width
		
		if !portrait {
			let wr = self.size.width / self.size.height
			width = self.size.height / wr
		}
		
		var birdBoundingRect = CGRect(x: CGFloat(0), y: CGFloat(self.size.height * 0.1), width: width, height: self.size.height * 0.25)
        if !portrait {
            birdBoundingRect = CGRect(x: (self.size.width - width)/2, y: CGFloat(self.size.height * 0.1), width: width, height: self.size.height * 0.25)
        }
		let physicsBody = SKPhysicsBody (edgeLoopFrom: birdBoundingRect)
		self.physicsBody = physicsBody
		
		let basex = (self.size.width / 2) - (width / 2)
		var tx = tiles[0].size().width / 2
		var ty = CGFloat(0)
		var num = CGFloat(0.05)
		while (ty < self.size.height + tiles[0].size().height) {
			let rt = Int(arc4random_uniform(UInt32(tiles.count)))
			let bgSprite = SKSpriteNode(texture: tiles[rt])
            bgSprite.userData = ["rt": rt]
			bgSprite.zPosition = 1
            if (rt==8) {
                bgSprite.zPosition = 3 - num
            }
			bgSprite.position = CGPoint(x: basex + tx, y: ty + (bgSprite.size.height - tiles[0].size().height)/2)
			backgroundTiles.append(bgSprite)
			sprites.append(bgSprite)
			self.addChild(bgSprite)
			
			tx = tx + bgSprite.size.width - 2
			if tx - (tiles[0].size().width / 2) >= width {
                tx = tiles[0].size().width / 2
				ty = ty + (tiles[0].size().height - 2)
				num = num + 0.05
			}
		}
		
		let titleSprite = SKSpriteNode(imageNamed: "rr_title")
		let tr = titleSprite.size.width / titleSprite.size.height
		titleSprite.size.width = width * 0.8
		titleSprite.size.height = titleSprite.size.width / tr
		titleSprite.zPosition = 4
		titleSprite.position = CGPoint(x: self.size.width / 2, y: (self.size.height / 2) + titleSprite.size.height / 2)
		let titleAct = SKAction.moveTo(y: -titleSprite.size.height, duration: 4.0)
        titleSprite.run(titleAct, completion: {
            titleSprite.removeFromParent()
        }) 
		sprites.append(titleSprite)
		self.addChild(titleSprite)
		
		bird = AnimatedStateSprite(imageNamed: "flying_bird1")
		bird.zPosition = 5
		bird.position = CGPoint(x: self.size.width / 2, y: bird.size.height * 2)
        let flying = SKAction.repeatForever(SKAction.animate(with: [SKTexture(imageNamed: "flying_bird2"),
            SKTexture(imageNamed: "flying_bird3"),
            SKTexture(imageNamed: "flying_bird1")], timePerFrame: 0.15))
        bird.addAction(0, action: flying)
        bird.run(flying)
		bird.physicsBody = SKPhysicsBody(rectangleOf: bird.frame.size)
		bird.physicsBody!.isDynamic = true
		bird.physicsBody!.affectedByGravity = false
		bird.physicsBody!.mass = 0.02
		sprites.append(bird)
		self.addChild(bird)
		
		leaves.append(SKTexture(imageNamed: "leaf1"))
		leaves.append(SKTexture(imageNamed: "leaf2"))
		leaves.append(SKTexture(imageNamed: "leafb1"))
		leaves.append(SKTexture(imageNamed: "leafb2"))
		
		boardWidth = width
		
		//-- hide offscreen clouds behind a background image
		if !portrait {
			let background1 = SKSpriteNode(imageNamed: "tree_background")
			background1.position = CGPoint(x: (self.size.width - width)/4, y: self.size.height/2)
			background1.size.width = (self.size.width - width)/2
			background1.size.height = self.size.height
			background1.zPosition = 6
			self.addChild(background1)
			sprites.append(background1)
			
			let background2 = SKSpriteNode(imageNamed: "tree_background")
			background2.position = CGPoint(x: 3*(self.size.width - width)/4 + width, y: self.size.height/2)
			background2.size.width = (self.size.width - width)/2
			background2.size.height = self.size.height
			background2.zPosition = 6
			self.addChild(background2)
			sprites.append(background2)
		}
        
        let exampleSprite = SKSpriteNode(imageNamed: "device1")
        exampleSprite.position = CGPoint(x: self.size.width / 2, y: 10 + exampleSprite.size.height / 2)
        exampleSprite.zPosition = 10
        exampleSprite.alpha = 0.6
        let eact = SKAction.animate(with: [SKTexture(imageNamed: "device1"),
            SKTexture(imageNamed: "device2"),
            SKTexture(imageNamed: "device1"),
            SKTexture(imageNamed: "device3"),
            SKTexture(imageNamed: "device1")], timePerFrame: 0.4)
        let eact2 = SKAction.sequence([eact, eact, eact, SKAction.removeFromParent()])
        exampleSprite.run(eact2)
        self.addChild(exampleSprite)
		
		speak("Rescue your Relatives!")
		spritesCreated = true
		
		addPersonDelay = 6.0 + Double(arc4random_uniform(UInt32(100))) / 60.0
		addCloudDelay = 15.0 + Double(arc4random_uniform(UInt32(100))) / 60.0
	}
	
	func addTileRow() {
		var tx = tiles[0].size().width / 2
		//let ty = self.size.height - 2 + tiles[0].size().height / 2
		let ty = (backgroundTiles.last!.position.y - 2) + tiles[0].size().height - (backgroundTiles.last!.size.height - tiles[0].size().height)
		let basex = (self.size.width / 2) - (boardWidth / 2)
        var has8 = false
        var ct = 0
		while tx - (tiles[0].size().width / 2) < boardWidth {
			let rt = Int(arc4random_uniform(UInt32(tiles.count)))
			let bgSprite = SKSpriteNode(texture: tiles[rt])
            bgSprite.userData = ["rt": rt]
			bgSprite.zPosition = 1
            if (rt==8) {
                bgSprite.zPosition = 2
                has8 = true
            }
			bgSprite.position = CGPoint(x: basex + tx, y: ty + (bgSprite.size.height - tiles[0].size().height)/2)
			backgroundTiles.append(bgSprite)
			sprites.append(bgSprite)
			self.addChild(bgSprite)
			
			tx = tx + bgSprite.size.width - 2
            ct += 1
		}
        
        while (backgroundTiles.first!.position.y + backgroundTiles.first!.size.height / 2) < 0 {
            let tile = backgroundTiles.removeFirst()
            tile.removeFromParent()
            sprites.removeObject(tile)
        }
        
        if has8 {
            for i in 0..<backgroundTiles.count - ct {
                let rt = backgroundTiles[i].userData!["rt"] as! Int
                if  rt == 8 {
                    backgroundTiles[i].zPosition += CGFloat(0.05)
                }
            }
        }
	}
    
    func addRandomPerson() {
        if family.count > 0 {
            let l = Int(arc4random_uniform(2))
            let basex = (self.size.width / 2) - (boardWidth / 2)
            let personSprite = PersonLeafSprite(texture: leaves[l])
            let br = personSprite.size.width / personSprite.size.height
            personSprite.size.width = bird.size.width
            personSprite.size.height = personSprite.size.width / br
            let x = personSprite.size.width/2 + CGFloat(arc4random_uniform(UInt32(boardWidth - personSprite.size.width)))
            personSprite.position = CGPoint(x: basex + x, y: self.size.height - personSprite.size.height/2)
            personSprite.zPosition = 10
            let p = Int(arc4random_uniform(UInt32(family.count)))
            personSprite.person = family[p]
            treeWalker.usePerson(family[p])
            family.remove(at: p)
            
            self.addChild(personSprite)
            peopleSprites.append(personSprite)
            sprites.append(personSprite)
            
            let slowdown = (Double(arc4random_uniform(UInt32(100))) / 60.0)  - (Double(nestSprites.count) / 20.0)
            let action = SKAction.moveTo(y: 0, duration: 8 + slowdown)
            personSprite.run(action)
        }
        if family.count < 2 {
            treeWalker.loadMorePeople()
        }
		addPersonDelay = 3.0 - (Double(nestSprites.count) / 20.0) + Double(arc4random_uniform(UInt32(100))) / 50.0
    }
	
	func addRandomCloud() {
		let basex = (self.size.width / 2) - (boardWidth / 2)
		cloud.position.y = bird.position.y
		cloud.changeState(0)
		let cr = cloud.size.width / cloud.size.height
		cloud.size.width = bird.size.width * 3.5
		cloud.size.height = cloud.size.width / cr
		cloud.zPosition = 4
		
		windPower = 7.0 + CGFloat(Double(nestSprites.count) / 15.0) + CGFloat(arc4random_uniform(UInt32(300))) / 100.0
		
		var cact1 = SKAction.moveTo(x: basex + cloud.size.width / 3, duration: 1)
		if drand48() > 0.5 {
			cloud.xScale = -1.0
			cloud.position.x = basex + boardWidth + cloud.size.width / 2
            windPower = windPower * -1
			cact1 = SKAction.moveTo(x: basex + boardWidth - cloud.size.width / 3, duration: 1)
		} else {
			cloud.xScale = 1.0
			cloud.position.x = basex - cloud.size.width / 2	
		}
		
		animator = SpriteAnimator()
		
        animator.addTiming(SpriteStateTiming(time: 0.01, sprite: cloud, state: 1))
        animator.addTiming(SpriteActionTiming(time: 0.5, sprite: cloud, action: cact1))
		let cact2 = SKAction.animate(with: [ SKTexture(imageNamed: "cloud3"),
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
		animator.addTiming(SpriteActionTiming(time: 3, sprite: cloud, action: cact2))
		
        let quietMode = DataService.getInstance().dbHelper.getProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET)
		if quietMode == nil || quietMode == "false" {
			let cact2sound = SKAction.playSoundFileNamed("blowing", waitForCompletion: false)
			animator.addTiming(SpriteActionTiming(time: 3.5, sprite: cloud, action: cact2sound))
		}
		
		let cactr2 = SKAction.repeatForever(SKAction.animate(with: [SKTexture(imageNamed: "cloud11"),SKTexture(imageNamed: "cloud12")], timePerFrame: 0.2))
		animator.addTiming(SpriteActionTiming(time: 3.9, sprite: cloud, action: cactr2))
		
		let blowtime = 1.0 + Double(arc4random_uniform(UInt32(200))) / 100.0
		let cact3 = SKAction.animate(with: [ SKTexture(imageNamed: "cloud13"),
			SKTexture(imageNamed: "cloud14"),
			SKTexture(imageNamed: "cloud15")
		], timePerFrame: 0.1)
		animator.addTiming(SpriteActionTiming(time: 4.5 + blowtime, sprite: cloud, action: cact3))
		//animator.addTiming(SpriteStateTiming(time: 5.3 + blowtime, sprite: cloud, state: 3))
        let cstop = SKAction.run({ self.cloud.removeAllActions() })
        animator.addTiming(SpriteActionTiming(time: 5.5, sprite: cloud, action: cstop))
		let cact5 = SKAction.removeFromParent()
		animator.addTiming(SpriteActionTiming(time: 6.0 + blowtime, sprite: cloud, action: cact5))
			
        cloud.removeFromParent()
        sprites.removeObject(cloud)
        
		sprites.append(cloud)
		self.addChild(cloud)
		
        print("adding cloud at \(cloud.position)")
        
		animator.start()
	
		addCloudDelay = 10.0 - (Double(nestSprites.count) / 10.0) + Double(arc4random_uniform(UInt32(100))) / 30.0
	}
	
	func reorderNest() {
		let basex = (self.size.width / 2) - (boardWidth / 2)
		let nestWidth = self.size.height * 0.05
		if nestSprites.count > 0 {
            tileMove = 1 + round(CGFloat(nestSprites.count) / 10)
            let dx = min(nestWidth, boardWidth / CGFloat(nestSprites.count))
            var x = CGFloat(nestWidth / 2)
            for s in nestSprites {
                s.position.x = basex + x
				s.position.y = nestWidth / 2
				s.size.width = nestWidth
				s.size.height = nestWidth
                s.resizePhoto()
                x += dx
            }
        }
		if missedSprites.count > 0 {
			var x = CGFloat(nestWidth / 2)
            for s in missedSprites {
				if (s.texture == leaves[0]) {
					s.texture = leaves[2]
				} else if (s.texture == leaves[1]) {
					s.texture = leaves[3]
				}
                s.position.x = basex + x
				s.position.y = nestWidth * CGFloat(1.5)
				s.size.width = nestWidth
				s.size.height = nestWidth
                s.resizePhoto()
                x += nestWidth
            }
		}
	}
	
	func showGameOver() {
		gameOver = true
		
		for s in peopleSprites {
            s.removeFromParent()
			sprites.removeObject(s)
        }
		peopleSprites.removeAll()
		
		let gameOverCloud = SKSpriteNode(imageNamed: "rr_gameover")
		let tr = gameOverCloud.size.width / gameOverCloud.size.height
		gameOverCloud.size.width = boardWidth * 0.9
		gameOverCloud.size.height = gameOverCloud.size.width / tr
		gameOverCloud.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
		gameOverCloud.zPosition = 5
		sprites.append(gameOverCloud)
		self.addChild(gameOverCloud)
		
		let text = "You rescued \(nestSprites.count) relatives!"
		let message = SKLabelNode(text: text);
        message.fontSize = gameOverCloud.size.height / 10
        if message.frame.size.width > gameOverCloud.size.width * 0.80 {
            message.fontSize = message.fontSize * 0.75
        }
        message.fontColor = UIColor.black
        message.position = CGPoint(x: self.size.width / 2, y: (self.size.height / 2) - message.fontSize * 2)
        message.zPosition = 6
		sprites.append(message)
		self.addChild(message)
		self.speak(text)
		
		playAgainButton = EventSprite(imageNamed: "rr_play")
		let pr = playAgainButton.size.width / playAgainButton.size.height
		playAgainButton.size.width = gameOverCloud.size.width * 0.3
		playAgainButton.size.height = playAgainButton.size.width / pr
		playAgainButton.position = CGPoint(x: self.size.width / 2 + playAgainButton.size.width, y: gameOverCloud.position.y - gameOverCloud.size.height/2.5)
		playAgainButton.zPosition = 7
		playAgainButton.isUserInteractionEnabled = true
		playAgainButton.topic = BirdScene.TOPIC_PLAY_AGAIN
		playAgainPosition = CGPoint(x: self.size.width / 2 + playAgainButton.size.width, y: gameOverCloud.position.y - gameOverCloud.size.height/2.5)
		sprites.append(playAgainButton)
		self.addChild(playAgainButton)
	}
	
	var lastUpdate:CFTimeInterval = 0
	override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        super.update(currentTime)

		if animator != nil {
			animator!.update(currentTime)
			
			if showingCutScene && animator.finished {
				showingCutScene = false
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
				
				if  tileOffset >= tiles[0].size().height - 2 {
					tileOffset = CGFloat(0)
                    addTileRow()
                    while backgroundTiles.last!.position.y < self.size.height {
                        addTileRow()
                    }
				}
			}
			
            if !animator.finished && animator.currentPosition > 3 {
                bird.physicsBody!.applyForce(CGVector(dx: windPower, dy: 0.0))
            }
			if let accData = motionManager.accelerometerData {
				if fabs(accData.acceleration.x) > 0.2 || fabs(accData.acceleration.y) > 0.2 {
                    if portrait {
                        var ax = 40.0 * CGFloat(accData.acceleration.x)
                        if ax > 60 {
                            ax = 60
                        }
                        if ax < -60 {
                            ax = -60
                        }
                        bird.physicsBody!.applyForce(CGVector(dx: ax, dy: 20 + 50.0 * CGFloat(accData.acceleration.y)))
                    } else {
                        var ax = -40.0 * CGFloat(accData.acceleration.y)
                        if ax > 60 {
                            ax = 60
                        }
                        if ax < -60 {
                            ax = -60
                        }
                        bird.physicsBody!.applyForce(CGVector(dx: ax, dy: 20 + 50.0 * CGFloat(accData.acceleration.x)))
                    }
				}
                
                if gameOver {
                    //-- adjust play again button based on movement
                    playAgainButton.position.x = playAgainPosition.x + (20 * CGFloat(accData.acceleration.x))
                    playAgainButton.position.y = playAgainPosition.y + (20 * CGFloat(accData.acceleration.y))
                }
			}
			
			if !gameOver {
				if lastAddPersonTime == 0 {
					lastAddPersonTime = currentTime
				}
				if currentTime - lastAddPersonTime > addPersonDelay {
					addRandomPerson()
					lastAddPersonTime = currentTime
				}
				
				if lastAddCloudTime == 0 {
					lastAddCloudTime = currentTime
				}
				if  currentTime - lastAddCloudTime > addCloudDelay {
					addRandomCloud()
					lastAddCloudTime = currentTime
				}
				
				var hit:PersonLeafSprite? = nil
				var missed:PersonLeafSprite? = nil
				for ps in peopleSprites {
					if ps.frame.contains(bird.position) {
						hit = ps
					} else if ps.position.y < self.size.height * 0.1 {
						missed = ps
					}
				}
				if hit != nil {
                    hit?.removeAllActions()
					nestSprites.append(hit!)
					peopleSprites.removeObject(hit!)
                    self.sayGivenName(hit!.person!)
					if missed == nil {
						reorderNest()
					}
				}
				if missed != nil {
                    missed?.removeAllActions()
					missedSprites.append(missed!)
					peopleSprites.removeObject(missed!)
                    let soundAction = SKAction.playSoundFileNamed("beepboop", waitForCompletion: false)
                    self.run(soundAction)
					AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
					reorderNest()
				}
				if missedSprites.count > 2 {
					showGameOver()
				}
			}
		}
    }
	
	func onComplete(_ family:[LittlePerson]) {
        for person in family {
            if !self.family.contains(person) {
                self.family.append(person)
            }
        }
        
        if self.family.count < 3 {
            treeWalker.loadMorePeople()
        }
		
		if showingCutScene {
			showCutScene()
		}
	}
    
    override func onTransactionComplete() {
        super.onTransactionComplete()
        animator.start()
    }
    
}
