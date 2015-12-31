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
    var minX = CGFloat(-100)
    var minY = CGFloat(-100)
    var maxX = CGFloat(200)
    var maxY = CGFloat(200)
    
    var previousScale:CGFloat? = nil
    var minScale : CGFloat = 0.2
    var maxScale : CGFloat = 3.0
    
	var treeSearchButton : AnimatedStateSprite?
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        self.size.width = view.bounds.width
        self.size.height = view.bounds.height
        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
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
						dataService.getChildren(parents![0], onCompletion: { children2, err in
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
					
					self.addChildNodes(self.root!, children: children!)
                    dispatch_group_leave(self.treeGroup)
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
            
            self.addCoupleSprite(self.root!)
            
            self.hideLoadingDialog()
        }
        
        self.treeContainer = SKSpriteNode()
        self.treeContainer?.position = CGPointMake(0, 0)
        self.treeContainer?.zPosition = 1
        self.treeContainer?.setScale(self.tscale)
        self.addChild(self.treeContainer!)
		
		treeSearchButton = AnimatedStateSprite(imageNamed: "tree_search")
		treeSearchButton?.zPosition = 5
		treeSearchButton?.position = CGPointMake(self.size.width - (treeSearchButton?.size.width)!, (treeSearchButton?.size.height)!)
		let searching:[SKTexture] = [
            SKTexture(imageNamed: "tree_search1"),
            SKTexture(imageNamed: "tree_search2"),
            SKTexture(imageNamed: "tree_search3"),
            SKTexture(imageNamed: "tree_search4"),
			SKTexture(imageNamed: "tree_search5"),
			SKTexture(imageNamed: "tree_search6"),
			SKTexture(imageNamed: "tree_search7")
        ]
        let searchAction = SKAction.animateWithTextures(searching, timePerFrame: 0.07, resize: false, restore: false)
        treeSearchButton?.addAction(1, action: searchAction)
		treeSearchButton?.addTexture(2, SKTexture(imageNamed: "tree_search8"))
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
	
    func addCoupleSprite(node: TreeNode) -> TreeCoupleSprite {
        let sprite = TreeCoupleSprite()
        sprite.size = CGSizeMake(self.leaf.size().width * 2, self.leaf.size().height)
        sprite.position = CGPointMake(self.x, self.y)
        sprite.zPosition = self.z++
        sprite.treeNode = node
        self.treeContainer?.addChild(sprite)
        
        if self.x < self.minX {
            self.minX = self.x
        }
        if self.x > self.maxX {
            self.maxX = self.x
        }
        if self.y < self.minY {
            self.minY = self.y
        }
        if self.y > self.maxY {
            self.maxY = self.y
        }
        
        let offsetY = CGFloat(40)
        self.y = sprite.position.y + offsetY + sprite.size.height + self.vine2.size().height/2
        if node.leftNode != nil {
            self.x = sprite.position.x - (sprite.size.width / 2)
            if node.level == 0 {
                self.x = self.x - sprite.size.width / 2
            }
            
            let vine = SKSpriteNode(texture: self.vine)
            vine.position = CGPointMake(self.x + self.leaf.size().width - 5, sprite.position.y + offsetY + self.leaf.size().height + 30)
            vine.zPosition = 2
            self.treeContainer?.addChild(vine)
            
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
                self.treeContainer!.addChild(vine2);
                vx = vx + vine2.size.width
                flip = !flip
            }
            
            let vine2 = SKSpriteNode(texture: self.vine2)
            vine2.position = CGPointMake(vx - vine.size.width - 30, sprite.position.y + 80)
            vine2.zPosition = 2
            self.treeContainer?.addChild(vine2)
            
            addCoupleSprite(node.leftNode!)
        }
        
        self.y = sprite.position.y + offsetY + sprite.size.height + self.vine2.size().height/2
        if node.rightNode != nil {
            self.x = sprite.position.x + (sprite.size.width / 2)
            if node.level == 0 {
                self.x = self.x + sprite.size.width / 2
            }
            
            let vine = SKSpriteNode(texture: self.vine3)
            vine.position = CGPointMake(self.x + self.leaf.size().width - 6, sprite.position.y + offsetY + self.leaf.size().height + 30)
            vine.zPosition = 2
            self.treeContainer?.addChild(vine)
            
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
                self.treeContainer!.addChild(vine2);
                vx = vx - vine2.size.width
                flip = !flip
            }

            
            addCoupleSprite(node.rightNode!)
        }
        
        if node.leftNode == nil && node.rightNode == nil && node.hasParents == true {
            let upArrow = SKSpriteNode(imageNamed: "vine_arrow")
            upArrow.position = CGPointMake(sprite.position.x + sprite.size.width/2, sprite.position.y + sprite.size.height + upArrow.size.height)
            upArrow.zPosition = 3
            self.treeContainer!.addChild(upArrow)
        }
        
        return sprite
    }
    
    override func update(currentTime: NSTimeInterval) {
        super.update(currentTime)
    }
    
    func pinched(sender:UIPinchGestureRecognizer){
        print("pinched \(tscale)")
        if previousScale != nil {
            if sender.scale != previousScale! {
                let diff = (sender.scale - previousScale!) / 4
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
        previousScale = sender.scale
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
        if treeContainer?.position.y < minY {
            treeContainer?.position.y = minY
        }
        if treeContainer?.position.y > maxY {
            treeContainer?.position.y = maxY
        }
        treeContainer?.position.x += clipX
        if treeContainer?.position.x < minX {
            treeContainer?.position.x = minX
        }
        if treeContainer?.position.x > maxX {
            treeContainer?.position.x = maxX
        }
        
        lastPoint = nextPoint
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        for touch in touches {
            lastPoint = touch.locationInNode(self)
            if moved == false {
                let touchedNode = nodeAtPoint(lastPoint)
				if touchedNode == treeSearchButton {
					treeSearchButton?.state = 0
					treeSearchButton?.nextState()
				}
            }
        }
        moved = false
    }
}