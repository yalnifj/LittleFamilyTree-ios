//
//  TreeScene.swift
//  Little Family Tree
//
//  Created by Melissa on 12/10/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class TreeScene: LittleFamilyScene {
	static var TOPIC_NAVIGATE_UP_TREE = "navigateUpTree"
    static var TOPIC_START_FIND_PERSON = "startFindPerson"
    static var TOPIC_NEXT_CLUE = "nextClue"
    static var TOPIC_PERSON_SELECTED = "personSelected"
	
	var lastPoint : CGPoint!
	var treeContainer : SKSpriteNode?
	var root : TreeNode?
    var queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    var treeGroup = dispatch_group_create()
    
    var x = CGFloat(0)
    var y = CGFloat(0)
    var z = CGFloat(1)
    var leaf = SKTexture(imageNamed: "leaf_left")
    var vine = SKTexture(imageNamed: "vine")
    var vine2 = SKTexture(imageNamed: "vine2")
    var vine3 = SKTexture(imageNamed: "vine3")
    var vineh = SKTexture(imageNamed: "vineh")
    var vineh2 = SKTexture(imageNamed: "vineh2")
    var tscale = CGFloat(0.40)
    var moved = false
    var clipX = CGFloat(0)
    var clipY = CGFloat(0)
    var minX = CGFloat(-300)
    var minY = CGFloat(-300)
    var maxX = CGFloat(300)
    var maxY = CGFloat(300)
    
    var previousScale:CGFloat? = nil
    var minScale : CGFloat = 0.2
    var maxScale : CGFloat = 3.0
    
	var treeSearchButton : AnimatedStateSprite?
	
	var treeSearchGame : TreeSearchGame?
    
    var buttonPanel : SKSpriteNode?
    var buttons = [SKSpriteNode]()
    var dressupButton:SKSpriteNode?
    var bubbleButton:SKSpriteNode?
    var matchButton:SKSpriteNode?
    var scratchButton:SKSpriteNode?
    var coloringButton:SKSpriteNode?
    var puzzleButton:SKSpriteNode?
    //var songButton:SKSpriteNode?
	
	var dolls = DressUpDolls()
	var dollConfig:DollConfig?
    var panelPerson:LittlePerson?
    
    var arrows = [TreeUpArrow]()
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        self.size.width = view.bounds.width
        self.size.height = view.bounds.height
        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        self.minY = -2 * self.size.height
        
        let background = SKSpriteNode(imageNamed: "wood_back")
        background.position = CGPointMake(self.size.width/2, self.size.height/2)
        background.size.width = self.size.width
        background.size.height = self.size.height
        background.zPosition = 0
        self.addChild(background)
        
        let pinch:UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: Selector("pinched:"))
        view.addGestureRecognizer(pinch)
        
        let md = min(self.size.width, self.size.height)
        maxScale = (md / 2) / leaf.size().width
        minScale = md / (10 * leaf.size().width)
        tscale = maxScale / 3
        
        setupTopBar()
        
        showLoadingDialog()
		
		self.treeSearchGame = TreeSearchGame(me: selectedPerson!)
        
        matchButton = SKSpriteNode(imageNamed: "house_familyroom_frame1")
        var br = matchButton!.size.width / matchButton!.size.height
        matchButton!.size = CGSizeMake(50 * br, 50)
        matchButton!.anchorPoint = CGPointZero
        buttons.append(matchButton!)
        
        scratchButton = SKSpriteNode(imageNamed: "house_chilldroom_desk19")
        br = scratchButton!.size.width / scratchButton!.size.height
        scratchButton!.size = CGSizeMake(50 * br, 50)
        scratchButton!.anchorPoint = CGPointZero
        buttons.append(scratchButton!)
        
        coloringButton = SKSpriteNode(imageNamed: "house_chilldroom_paint11")
        br = coloringButton!.size.width / coloringButton!.size.height
        coloringButton!.size = CGSizeMake(50 * br, 50)
        coloringButton!.anchorPoint = CGPointZero
        buttons.append(coloringButton!)
        
        bubbleButton = SKSpriteNode(imageNamed: "bubbles1")
        br = bubbleButton!.size.width / bubbleButton!.size.height
        bubbleButton!.size = CGSizeMake(50 * br, 50)
        bubbleButton!.anchorPoint = CGPointZero
        buttons.append(bubbleButton!)
        
        dressupButton = SKSpriteNode(imageNamed: "dolls/usa/boy_thumb.png")
        br = dressupButton!.size.width / dressupButton!.size.height
        dressupButton!.size = CGSizeMake(50 * br, 50)
        dressupButton!.anchorPoint = CGPointZero
        buttons.append(dressupButton!)
        
        puzzleButton = SKSpriteNode(imageNamed: "house_toys_blocks")
        br = puzzleButton!.size.width / puzzleButton!.size.height
        puzzleButton!.size = CGSizeMake(50 * br, 50)
        puzzleButton!.anchorPoint = CGPointZero
        buttons.append(puzzleButton!)
        
        //songButton = SKSpriteNode(imageNamed: "house_music_piano")
        //br = songButton!.size.width / songButton!.size.height
        //songButton!.size = CGSizeMake(50 * br, 50)
        //songButton!.anchorPoint = CGPointZero
        //buttons.append(songButton!)
        
        dispatch_group_enter(treeGroup)
		let dataService = DataService.getInstance()
		dataService.getChildren(selectedPerson!, onCompletion: { children, err in 
			if children == nil || children!.count == 0 {
                dispatch_group_enter(self.treeGroup)
				dataService.getParents(self.selectedPerson!, onCompletion: { parents, err in
					if parents != nil && parents!.count > 0 {
						self.root = TreeNode()
						self.root!.isRoot = true
						self.buildTreeNode(self.root!, couple:parents!, depth:0, maxDepth: 2, isInLaw:false)
						
                        dispatch_group_enter(self.treeGroup)
                        dataService.getChildrenForCouple(parents![0], person2: parents![1], onCompletion: { children2, err in
                            if children2 != nil {
                                self.addChildNodes(self.root!, children: children2!)
                            }
                            dispatch_group_leave(self.treeGroup)
						})
						
					} else {
						self.root = TreeNode()
						self.root!.isRoot = true
						self.buildTreeNode(self.root!, couple:[ self.selectedPerson! ], depth:0, maxDepth: 3, isInLaw:false)
					}
                    dispatch_group_leave(self.treeGroup)
				})
			} else {
                dispatch_group_enter(self.treeGroup)
				dataService.getSpouses(self.selectedPerson!, onCompletion: { spouses, err in
					var couple = [LittlePerson]()
					couple.append(self.selectedPerson!)
					if spouses != nil && spouses!.count > 0 {
						couple.append(spouses![0])
					}
					self.root = TreeNode()
					self.root!.isRoot = true
					self.buildTreeNode(self.root!, couple:couple, depth:0, maxDepth: 2, isInLaw:false)
                    
                    if couple.count > 1 {
                        dataService.getChildrenForCouple(couple[0], person2: couple[1], onCompletion: {children2, err in
                            if children2 != nil && children2!.count > 0 {
                                self.addChildNodes(self.root!, children: children2!)
                            }
                            dispatch_group_leave(self.treeGroup)
                        })
                    } else {
                        self.addChildNodes(self.root!, children: children!)
                        dispatch_group_leave(self.treeGroup)
                    }
				})
			}
            dispatch_group_leave(self.treeGroup)
		})
        
        dispatch_group_notify(treeGroup, queue) {
            //-- build sprites
            
            if self.root?.children != nil {
                for childNode in (self.root?.children!)! {
                    let cs = TreePersonSprite()
                    cs.size = self.leaf.size()
                    cs.position = CGPointMake(self.x, self.y)
                    cs.zPosition = self.z++
                    if childNode.leftPerson != nil {
                        cs.left = true
                        cs.person = childNode.leftPerson
                    } else {
                        cs.left = false
                        cs.person = childNode.rightPerson
                    }
                    self.treeContainer?.addChild(cs)
                    self.x += self.leaf.size().width + 20
                }
            }
            
            var vx = self.leaf.size().width / 2
            var flip = true
            while(vx < self.x - self.leaf.size().width) {
                var bv = self.vineh
                var vy = self.y + 120
                if (flip) {
                    bv = self.vineh2
                    vy = self.y + 92
                }
                let vine = SKSpriteNode(texture: bv)
                vine.position = CGPointMake(vx, vy)
                vine.zPosition = 2
                self.treeContainer!.addChild(vine);
                vx = vx + vine.size.width + 2.5
                flip = !flip
            }
            
            self.x = (self.x / 2) - (self.leaf.size().width + 10)
            
            let vine = SKSpriteNode(texture: self.vine2)
            vine.position = CGPointMake(self.x + self.leaf.size().width + 10, self.y + self.vine2.size().height + 5)
            vine.zPosition = 2
            self.treeContainer?.addChild(vine)
            
            self.y = self.y + self.leaf.size().height + self.vine2.size().height/2
            
            self.addCoupleSprite(self.root!, container: self.treeContainer!, x: self.x, y: self.y)
            
            self.hideLoadingDialog()
        }
        
        self.treeContainer = SKSpriteNode()
        self.treeContainer?.position = CGPointMake(50, 50)
        self.treeContainer?.zPosition = 1
        self.treeContainer?.setScale(self.tscale)
        self.addChild(self.treeContainer!)
		
		treeSearchButton = AnimatedStateSprite(imageNamed: "tree_search")
		treeSearchButton?.zPosition = 15
        let r = (treeSearchButton?.size.height)! / (treeSearchButton?.size.width)!
        treeSearchButton?.size = CGSizeMake(md / 5, (md * r) / 5)
		treeSearchButton?.position = CGPointMake(self.size.width - (treeSearchButton?.size.width)! / 2, (treeSearchButton?.size.height)! / 1.5)
		let searching:[SKTexture] = [
            SKTexture(imageNamed: "tree_search1"),
            SKTexture(imageNamed: "tree_search2"),
            SKTexture(imageNamed: "tree_search3"),
            SKTexture(imageNamed: "tree_search4"),
			SKTexture(imageNamed: "tree_search5"),
			SKTexture(imageNamed: "tree_search6"),
			SKTexture(imageNamed: "tree_search7"),
            SKTexture(imageNamed: "tree_search8")
        ]
        let searchAction = SKAction.animateWithTextures(searching, timePerFrame: 0.07, resize: false, restore: false)
        treeSearchButton?.addAction(1, action: searchAction)
        treeSearchButton?.addTexture(2, texture: SKTexture(imageNamed: "tree_search8"))
		self.addChild(treeSearchButton!)
    }
    
    override func willMoveFromView(view: SKView) {
        super.willMoveFromView(view)
    }
	
	func addChildNodes(node:TreeNode, children:[LittlePerson]) {
		var childNodes = [TreeNode]()
		for child in children {
			let node = TreeNode()
			node.level = node.level - 1
			if child.gender == GenderType.FEMALE {
				node.rightPerson = child
			} else {
				node.leftPerson = child
			}
			childNodes.append(node)
		}
		node.children = childNodes
	}
	
    func buildTreeNode(node:TreeNode, couple:[LittlePerson], depth:Int, maxDepth:Int, isInLaw:Bool) {
        if couple.count > 0 {
            if couple[0].gender == GenderType.FEMALE {
                node.rightPerson = couple[0]
            } else {
                node.leftPerson = couple[0]
            }
        }
		node.level = depth
		node.isInLaw = isInLaw
		
        if couple.count > 1 {
			if node.leftPerson != nil {
				node.rightPerson = couple[1]
			} else {
				node.leftPerson = couple[1]
			}
		}
		
		let dataService = DataService.getInstance()
		if node.leftPerson != nil {
            dispatch_group_enter(self.treeGroup)
			dataService.getParents(node.leftPerson!, onCompletion: { parents, err in
				if parents != nil && parents!.count > 0 {
					node.hasParents = true
					if depth < maxDepth {
						let next = TreeNode()
						var iil = isInLaw
						if node.rightPerson != nil && node.rightPerson! == self.selectedPerson! && node.leftPerson! != self.selectedPerson! {
							iil = true
						}
						self.buildTreeNode(next, couple: parents!, depth: depth+1, maxDepth: maxDepth, isInLaw: iil)
						node.leftNode = next
					}
                } else if depth < maxDepth {
                    let next = TreeNode()
                    self.buildTreeNode(next, couple: [], depth: depth+1, maxDepth: maxDepth, isInLaw: isInLaw)
                    node.leftNode = next
                }
                dispatch_group_leave(self.treeGroup)
			})
        } else if depth < maxDepth {
            let next = TreeNode()
            self.buildTreeNode(next, couple: [], depth: depth+1, maxDepth: maxDepth, isInLaw: isInLaw)
            node.leftNode = next
        }
        
		if node.rightPerson != nil {
            dispatch_group_enter(self.treeGroup)
			dataService.getParents(node.rightPerson!, onCompletion: { parents, err in
				if parents != nil && parents!.count > 0 {
					node.hasParents = true
					if depth < maxDepth {
						let next = TreeNode()
						var iil = isInLaw
						if node.leftPerson != nil && node.leftPerson! == self.selectedPerson! && node.rightPerson! != self.selectedPerson! {
							iil = true
						}
						self.buildTreeNode(next, couple: parents!, depth: depth+1, maxDepth: maxDepth, isInLaw: iil)
						node.rightNode = next
					}
				} else if depth < maxDepth {
                    let next = TreeNode()
                    self.buildTreeNode(next, couple: [], depth: depth+1, maxDepth: maxDepth, isInLaw: isInLaw)
                    node.rightNode = next
                }
                dispatch_group_leave(self.treeGroup)
			})
        } else if depth < maxDepth {
            let next = TreeNode()
            self.buildTreeNode(next, couple: [], depth: depth+1, maxDepth: maxDepth, isInLaw: isInLaw)
            node.rightNode = next
        }
	}
	
    func addCoupleSprite(node: TreeNode, container: SKNode, var x: CGFloat, var y: CGFloat) -> TreeCoupleSprite {
        let sprite = TreeCoupleSprite()
        sprite.size = CGSizeMake(self.leaf.size().width * 2, self.leaf.size().height)
        sprite.position = CGPointMake(x, y)
        sprite.zPosition = self.z++
        sprite.treeNode = node
        container.addChild(sprite)
        
        if x < self.minX {
            self.minX = x
            if self.size.width * 2 + x > maxX {
                self.maxX = self.size.width * 2 + x
            }
        }
        if y < self.minY {
            self.minY = y
            if self.size.height * 2 + y > maxY {
                self.maxY = self.size.height * 2 + y
            }
        }
        
        let offsetY = CGFloat(40)
        y = sprite.position.y + offsetY + sprite.size.height + self.vine2.size().height/2
        if node.leftNode != nil {
            x = sprite.position.x - (sprite.size.width / 2)
            if node.level == 0 {
                x = x - sprite.size.width / 2
            }
            
            let vine = SKSpriteNode(texture: self.vine)
            vine.position = CGPointMake(x + self.leaf.size().width - 5, sprite.position.y + offsetY + self.leaf.size().height + 30)
            vine.zPosition = 2
            container.addChild(vine)
            
            var vx = vine.position.x + self.vineh.size().width / 2
            var flip = true
            while(vx < sprite.position.x + sprite.size.width/2) {
                var bv = self.vineh
                var vy = vine.position.y - 36
                if (flip) {
                    bv = self.vineh2
                    vy = vine.position.y - 58
                }
                let vine2 = SKSpriteNode(texture: bv)
                vine2.position = CGPointMake(vx, vy)
                vine2.zPosition = 2
                container.addChild(vine2);
                vx = vx + vine2.size.width
                flip = !flip
            }
            
            let vine2 = SKSpriteNode(texture: self.vine2)
            vine2.position = CGPointMake(vx - vine.size.width - 30, sprite.position.y + 80)
            vine2.zPosition = 2
            container.addChild(vine2)
            
            addCoupleSprite(node.leftNode!, container: container, x: x, y: y)
        }
        
        y = sprite.position.y + offsetY + sprite.size.height + self.vine2.size().height/2
        if node.rightNode != nil {
            x = sprite.position.x + (sprite.size.width / 2)
            if node.level == 0 {
                x = x + sprite.size.width / 2
            }
            
            let vine = SKSpriteNode(texture: self.vine3)
            vine.position = CGPointMake(x + self.leaf.size().width - 6, sprite.position.y + offsetY + self.leaf.size().height + 30)
            vine.zPosition = 2
            container.addChild(vine)
            
            var vx = vine.position.x - (14 + self.vineh.size().width / 2)
            var flip = true
            if node.level % 2 == 1 {
                flip = false
            }
            while(vx > sprite.position.x + sprite.size.width/2) {
                var bv = self.vineh
                var vy = vine.position.y - 36
                if (flip) {
                    bv = self.vineh2
                    vy = vine.position.y - 58
                }
                let vine2 = SKSpriteNode(texture: bv)
                vine2.position = CGPointMake(vx, vy)
                vine2.zPosition = 2
                container.addChild(vine2);
                vx = vx - vine2.size.width
                flip = !flip
            }

            
            addCoupleSprite(node.rightNode!, container: container, x: x, y: y)
        }
        
        if node.leftNode == nil && node.rightNode == nil && node.hasParents == true {
            let upArrow = TreeUpArrow(imageNamed: "vine_arrow")
            upArrow.position = CGPointMake(sprite.position.x + sprite.size.width/2, sprite.position.y + sprite.size.height + upArrow.size.height)
            upArrow.zPosition = 5
            upArrow.treeNode = node
            container.addChild(upArrow)
            self.arrows.append(upArrow)
        }
        
        return sprite
    }
    
    override func update(currentTime: NSTimeInterval) {
        super.update(currentTime)
    }
    
    func pinched(sender:UIPinchGestureRecognizer){
        print("pinched \(tscale)")
        if sender.state == UIGestureRecognizerState.Ended || sender.state == UIGestureRecognizerState.Cancelled {
            previousScale = nil
        }
        else if sender.state == UIGestureRecognizerState.Began {
            previousScale = sender.scale
        }
        else if previousScale != nil {
            if sender.scale != previousScale! {
                var diff = (sender.scale - previousScale!) / 20
                if diff > 0 {
                    diff = diff / 6
                }
                tscale += diff
                if tscale < minScale {
                    tscale = minScale
                }
                if tscale > maxScale {
                    tscale = maxScale
                }
                let zoomIn = SKAction.scaleTo(tscale, duration:0)
                treeContainer?.runAction(zoomIn)
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        for touch in touches {
            lastPoint = touch.locationInNode(self)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var nextPoint = CGPointMake(0,0)
        for touch in touches {
            nextPoint = touch.locationInNode(self)
        }
        
        clipX = nextPoint.x - lastPoint.x;
        clipY = nextPoint.y - lastPoint.y;
		
		if abs(clipX) > 8 || abs(clipY) > 8 {
			moved = true
		}
        
        treeContainer?.position.y += clipY
        if treeContainer?.position.y < (minY * 2) * tscale {
            treeContainer?.position.y = (minY * 2) * tscale
        }
        if treeContainer?.position.y > (maxY * 2) * tscale {
            treeContainer?.position.y = (maxY * 2) * tscale
        }
        treeContainer?.position.x += clipX
        if treeContainer?.position.x < (minX * 2) * tscale {
            treeContainer?.position.x = (minX * 2) * tscale
        }
        if treeContainer?.position.x > (maxX * 2) * tscale {
            treeContainer?.position.x = (maxX * 2) * tscale
        }
        
        lastPoint = nextPoint
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        for touch in touches {
            lastPoint = touch.locationInNode(self)
            if moved == false {
                let touchedNode = nodeAtPoint(lastPoint)
                if touchedNode == bubbleButton {
                    self.showBubbleGame(panelPerson!, previousTopic: GameScene.TOPIC_START_TREE)
                }
				else if touchedNode == matchButton {
					self.showMatchGame(panelPerson!, previousTopic: GameScene.TOPIC_START_TREE)
				}
				else if touchedNode == scratchButton {
					self.showScratchGame(panelPerson!, previousTopic: GameScene.TOPIC_START_TREE)
				}
				else if touchedNode == puzzleButton {
					self.showPuzzleGame(panelPerson!, previousTopic: GameScene.TOPIC_START_TREE)
				}
				else if touchedNode == coloringButton {
					self.showColoringGame(panelPerson!, previousTopic: GameScene.TOPIC_START_TREE)
				}
				else if touchedNode == dressupButton {
                    self.showDressupGame(dollConfig!, person: panelPerson!, previousTopic: GameScene.TOPIC_START_TREE)
				}
                //else if touchedNode == songButton {
                //    self.showSongGame(panelPerson!, previousTopic: GameScene.TOPIC_START_SONG)
                //}
                else if touchedNode == treeSearchButton {
                    self.hideButtonPanel()
                    treeSearchButton?.state = 0
                    treeSearchButton?.nextState()
                    if self.treeSearchGame?.complete == true {
                        self.treeSearchGame?.findRandomPerson(self.root!)
                    } else {
                        self.treeSearchGame?.nextClue()
                    }
                    let text = self.treeSearchGame?.getClueText()
                    self.speak(text!)
                } else if touchedNode is TreePersonSprite {
                    self.personTouched(touchedNode as! TreePersonSprite)
                } else if touchedNode.parent is TreePersonSprite {
                    self.personTouched(touchedNode.parent as! TreePersonSprite)
                } else {
                    self.hideButtonPanel()
                    if touchedNode is TreeUpArrow {
                        let upArrow = touchedNode as! TreeUpArrow
                        arrowTouched(upArrow)
                    }
                }
            } else {
                print(treeContainer?.position)
                print("minX=\(minX) maxX=\(maxX)")
                print("minY=\(minY) maxY=\(maxY)")
            }
            break
        }
        moved = false
    }
    
    func hideButtonPanel() {
        if buttonPanel != nil {
            buttonPanel?.removeAllChildren()
            let act = SKAction.sequence( [ SKAction.resizeToWidth(5, height: 5, duration: 0.3), SKAction.removeFromParent() ])
            buttonPanel?.runAction(act) {
                self.buttonPanel = nil
            }
        }
    }
    
    func showButtonPanel(node:TreePersonSprite, relationship: String) {
        self.buttonPanel = SKSpriteNode(color: UIColor(hexString: "#00A400FF"), size: CGSizeMake(5, 5))
        self.buttonPanel?.zPosition = 100
        self.buttonPanel?.position = CGPointMake(node.position.x + node.size.width + 100, node.position.y + 50)
        node.parent!.addChild(self.buttonPanel!)
		panelPerson  = node.person!
		let place = PlaceHelper.getPersonCountry(panelPerson!)
		dollConfig = self.dolls.getDollConfig(place, person: panelPerson!)
        let texture = SKTexture(imageNamed: dollConfig!.getThumbnail())
        let ratio = texture.size().width / texture.size().height
        self.dressupButton?.size.width = (self.dressupButton?.size.height)! * ratio
        self.dressupButton?.texture = texture
        self.buttonPanel?.runAction(SKAction.resizeToWidth(220, height: 200, duration: 0.6)) {
			let startX = CGFloat(-90)
            var x = startX
			var y = CGFloat(-73)
            var counter = 0
			for button in self.buttons {
                if counter >= self.buttons.count / 2  {
                    x = startX
                    y = y + button.size.height + 8
                    counter = 0
                }
				button.position = CGPointMake(x, y)
				self.buttonPanel?.addChild(button)
                x = x + 8 + button.size.width
                counter++
			}
            y = y + self.buttons[0].size.height + 7
            let relLabel = SKLabelNode(text: relationship)
            relLabel.fontSize = self.buttonPanel!.size.width / 9
            relLabel.fontColor = UIColor.whiteColor()
            relLabel.position = CGPointMake(0, y)
            relLabel.zPosition = 3
            self.adjustLabelFontSizeToFitRect(relLabel, node: self.buttonPanel!, adjustUp: false)
            self.buttonPanel?.addChild(relLabel)
            
            y = y + relLabel.fontSize + 5
            let nameLabel = SKLabelNode(text: node.person?.name as String?)
            nameLabel.fontSize = self.buttonPanel!.size.width / 9
            nameLabel.fontColor = UIColor.whiteColor()
            nameLabel.position = CGPointMake(0, y)
            nameLabel.zPosition = 3
            self.adjustLabelFontSizeToFitRect(nameLabel, node: self.buttonPanel!, adjustUp: false)
            self.buttonPanel?.addChild(nameLabel)
		}
    }
    
    func personTouched(node:TreePersonSprite) {
        if self.treeSearchGame?.complete == true {
            if node.person != nil {
                let relationship = RelationshipCalculator.getRelationship(selectedPerson!, p: node.person!)
                var msg = "\(node.person!.name!) is your \(relationship). "
                var heshe = "He was "
                if node.person!.gender == GenderType.FEMALE {
                    heshe = "She was "
                }
                if relationship == "You" {
                    msg = "Hi, \(node.person!.givenName!). "
                    heshe = "You were "
                }
                let formatter = NSDateFormatter()
                formatter.dateFormat = "MMMM d, yyyy"
                if node.person?.birthPlace != nil && node.person!.birthDate != nil {
                    let dateString = formatter.stringFromDate(node.person!.birthDate!)
                    msg += "\(heshe) born on \(dateString) in \(node.person!.birthPlace!)"
                }
                else if node.person?.birthDate != nil {
                    let dateString = formatter.stringFromDate(node.person!.birthDate!)
                    msg += "\(heshe) born on \(dateString)"
                } else if node.person?.birthPlace != nil {
                    msg += "\(heshe) born in \(node.person!.birthPlace!)"
                }
                self.speak(msg)
                if buttonPanel != nil && buttonPanel!.size.width > 5 {
                    buttonPanel?.removeAllActions()
                    let act = SKAction.sequence( [ SKAction.resizeToWidth(5, height: 5, duration: 1.0), SKAction.removeFromParent() ])
                    buttonPanel?.runAction(act) {
                        self.showButtonPanel(node, relationship: relationship)
                    }
                } else {
                    self.showButtonPanel(node, relationship: relationship)
                }
            }
        } else {
            if node.person != nil {
                if self.treeSearchGame?.isMatch(node.person!) == true {
                    let rect = CGRect(x: node.frame.origin.x + node.frame.width / 2, y: node.frame.origin.y + node.frame.height / 2, width: node.frame.width, height: node.frame.height)
                    self.showStars(rect, starsInRect: true, count: 5, container: node.parent)
                    self.playSuccessSound(0.5, onCompletion: { () in
                        self.treeSearchButton?.nextState()
                    })
                } else {
                    self.playFailSound(0.0, onCompletion: {() in })
                }
            } else {
                self.playFailSound(0.0, onCompletion: {() in })
            }
        }
    }
    
    func arrowTouched(upArrow:TreeUpArrow) {
        var highArrows = [TreeUpArrow]()
        for arrow in arrows {
            if arrow.treeNode?.level > upArrow.treeNode?.level {
                arrow.removeFromParent()
                highArrows.append(arrow)
            } else if arrow.treeNode?.level == upArrow.treeNode?.level {
                arrow.removeAllChildren()
                arrow.texture = SKTexture(imageNamed: "vine_arrow")
                upArrow.zPosition = 5
            }
        }
        
        for arrow in highArrows {
            arrows.removeObject(arrow)
        }
        
        let node = upArrow.treeNode
        //let dataService = DataService.getInstance()
        let newNode = TreeNode()
        var couple = [LittlePerson]()
        if node!.leftPerson != nil {
            couple.append(node!.leftPerson!)
        }
        if node!.rightPerson != nil {
            couple.append(node!.rightPerson!)
        }
        self.buildTreeNode(newNode, couple: couple, depth: node!.level, maxDepth: node!.level+1, isInLaw: node!.isInLaw)
        upArrow.texture = nil
        upArrow.zPosition = 3
        addCoupleSprite(newNode, container: upArrow, x: -1 * leaf.size().width, y: -1 * (leaf.size().height + upArrow.size.height))
    }
}