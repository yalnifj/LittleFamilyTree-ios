//
//  TreeScene.swift
//  Little Family Tree
//
//  Created by Melissa on 12/10/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit
import Firebase

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class TreeScene: LittleFamilyScene {
	static var TOPIC_NAVIGATE_UP_TREE = "navigateUpTree"
    static var TOPIC_START_FIND_PERSON = "startFindPerson"
    static var TOPIC_NEXT_CLUE = "nextClue"
    static var TOPIC_PERSON_SELECTED = "personSelected"
	
	var lastPoint : CGPoint!
	var treeContainer : SKSpriteNode?
	var root : TreeNode?
    var queue = DispatchQueue.global()
    var treeGroup = DispatchGroup()
    
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
    var minX = CGFloat(-400)
    var minY = CGFloat(-400)
    var maxX = CGFloat(400)
    var maxY = CGFloat(400)
    
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
    var songButton:SKSpriteNode?
	var cardButton:SKSpriteNode?
	
	var dolls = DressUpDolls()
	var dollConfig:DollConfig?
    var panelPerson:LittlePerson?
    
    var arrows = [TreeUpArrow]()
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.size.width = view.bounds.width
        self.size.height = view.bounds.height
        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        self.minY = -2 * self.size.height
        
        let background = SKSpriteNode(imageNamed: "wood_back")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.size.width = self.size.width
        background.size.height = self.size.height
        background.zPosition = 0
        self.addChild(background)
        
        let pinch:UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(TreeScene.pinched(_:)))
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
        matchButton!.size = CGSize(width: 50 * br, height: 50)
        matchButton!.anchorPoint = CGPoint.zero
        buttons.append(matchButton!)
        
        scratchButton = SKSpriteNode(imageNamed: "pencils")
        br = scratchButton!.size.width / scratchButton!.size.height
        scratchButton!.size = CGSize(width: 50 * br, height: 50)
        scratchButton!.anchorPoint = CGPoint.zero
        buttons.append(scratchButton!)
        
        coloringButton = SKSpriteNode(imageNamed: "painting")
        br = coloringButton!.size.width / coloringButton!.size.height
        coloringButton!.size = CGSize(width: 50 * br, height: 50)
        coloringButton!.anchorPoint = CGPoint.zero
        buttons.append(coloringButton!)
        
        bubbleButton = SKSpriteNode(imageNamed: "bubble")
        br = bubbleButton!.size.width / bubbleButton!.size.height
        bubbleButton!.size = CGSize(width: 50 * br, height: 50)
        bubbleButton!.anchorPoint = CGPoint.zero
        buttons.append(bubbleButton!)
        
        dressupButton = SKSpriteNode(imageNamed: "dolls/usa/boy_thumb.png")
        br = dressupButton!.size.width / dressupButton!.size.height
        dressupButton!.size = CGSize(width: 50 * br, height: 50)
        dressupButton!.anchorPoint = CGPoint.zero
        buttons.append(dressupButton!)
        
        puzzleButton = SKSpriteNode(imageNamed: "house_toys_blocks")
        br = puzzleButton!.size.width / puzzleButton!.size.height
        puzzleButton!.size = CGSize(width: 50 * br, height: 50)
        puzzleButton!.anchorPoint = CGPoint.zero
        buttons.append(puzzleButton!)
        
        songButton = SKSpriteNode(imageNamed: "house_music_piano")
        br = songButton!.size.width / songButton!.size.height
        songButton!.size = CGSize(width: 50 * br, height: 50)
        songButton!.anchorPoint = CGPoint.zero
        buttons.append(songButton!)
		
		cardButton = SKSpriteNode(imageNamed: "birthday_card_button")
        br = cardButton!.size.width / cardButton!.size.height
        cardButton!.size = CGSize(width: 50 * br, height: 50)
        cardButton!.anchorPoint = CGPoint.zero
        buttons.append(cardButton!)
        
        treeGroup.enter()
		let dataService = DataService.getInstance()
		dataService.getChildren(selectedPerson!, onCompletion: { children, err in 
			if children == nil || children!.count == 0 {
                self.treeGroup.enter()
                dataService.getParentCouple(self.selectedPerson!, inParent: nil, onCompletion: { parents, err in
					if parents != nil && parents!.count > 0 {
						self.root = TreeNode()
						self.root!.isRoot = true
						self.buildTreeNode(self.root!, couple:parents!, depth:0, maxDepth: 2, isInLaw:false)
						
                        if parents!.count > 1 {
                            self.treeGroup.enter()
                            dataService.getChildrenForCouple(parents![0], person2: parents![1], onCompletion: { children2, err in
                                if children2 != nil {
                                    self.addChildNodes(self.root!, children: children2!)
                                }
                                self.treeGroup.leave()
                            })
                        } else {
                            self.treeGroup.enter()
                            dataService.getChildren(parents![0], onCompletion: { children2, err in
                                if children2 != nil {
                                    self.addChildNodes(self.root!, children: children2!)
                                }
                                self.treeGroup.leave()
                            })
                        }
						
					} else {
						self.root = TreeNode()
						self.root!.isRoot = true
						self.buildTreeNode(self.root!, couple:[ self.selectedPerson! ], depth:0, maxDepth: 3, isInLaw:false)
					}
                    self.treeGroup.leave()
				})
			} else {
                self.treeGroup.enter()
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
                            self.treeGroup.leave()
                        })
                    } else {
                        self.addChildNodes(self.root!, children: children!)
                        self.treeGroup.leave()
                    }
				})
			}
            self.treeGroup.leave()
		})
        
        treeGroup.notify(queue: queue) {
            //-- build sprites
            
            if self.root?.children != nil {
                for childNode in (self.root?.children!)! {
                    let cs = TreePersonSprite()
                    cs.size = self.leaf.size()
                    cs.position = CGPoint(x: self.x, y: self.y)
                    cs.zPosition = self.z.advanced(by: 1)
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
                vine.position = CGPoint(x: vx, y: vy)
                vine.zPosition = 2
                self.treeContainer!.addChild(vine);
                vx = vx + vine.size.width + 2.5
                flip = !flip
            }
            
            self.x = (self.x / 2) - (self.leaf.size().width + 10)
            
            let vine = SKSpriteNode(texture: self.vine2)
            vine.position = CGPoint(x: self.x + self.leaf.size().width + 10, y: self.y + self.vine2.size().height + 5)
            vine.zPosition = 2
            self.treeContainer?.addChild(vine)
            
            self.y = self.y + self.leaf.size().height + self.vine2.size().height/2
            
            self.addCoupleSprite(self.root!, container: self.treeContainer!, px: self.x, py: self.y)
            
            self.hideLoadingDialog()
        }
        
        self.treeContainer = SKSpriteNode()
        self.treeContainer?.position = CGPoint(x: 50, y: 50)
        self.treeContainer?.zPosition = 1
        self.treeContainer?.setScale(self.tscale)
        self.addChild(self.treeContainer!)
		
		treeSearchButton = AnimatedStateSprite(imageNamed: "tree_search")
		treeSearchButton?.zPosition = 15
        let r = (treeSearchButton?.size.height)! / (treeSearchButton?.size.width)!
        treeSearchButton?.size = CGSize(width: md / 5, height: (md * r) / 5)
		treeSearchButton?.position = CGPoint(x: self.size.width - (treeSearchButton?.size.width)! / 2, y: (treeSearchButton?.size.height)! / 1.5)
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
        let searchAction = SKAction.animate(with: searching, timePerFrame: 0.07, resize: false, restore: false)
        treeSearchButton?.addAction(1, action: searchAction)
        treeSearchButton?.addTexture(2, texture: SKTexture(imageNamed: "tree_search8"))
		self.addChild(treeSearchButton!)
        
        Analytics.logEvent(AnalyticsEventViewItem, parameters: [
            AnalyticsParameterItemName: String(describing: TreeScene.self) as NSObject
        ])
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
    }
	
	func addChildNodes(_ node:TreeNode, children:[LittlePerson]) {
		var childNodes = [TreeNode]()
		//-- sort the children by age
		let sortedChildren = children.sorted(by: { $0.age < $1.age })
		for child in sortedChildren {
			let node = TreeNode()
			node.level = node.level - 1
			if child.gender == GenderType.female {
				node.rightPerson = child
			} else {
				node.leftPerson = child
			}
			childNodes.append(node)
		}
		node.children = childNodes
	}
	
    func buildTreeNode(_ node:TreeNode, couple:[LittlePerson], depth:Int, maxDepth:Int, isInLaw:Bool) {
        if couple.count > 0 {
            if couple[0].gender == GenderType.female {
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
            self.treeGroup.enter()
            dataService.getParentCouple(node.leftPerson!, inParent: nil, onCompletion: { parents, err in
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
                self.treeGroup.leave()
			})
        } else if depth < maxDepth {
            let next = TreeNode()
            self.buildTreeNode(next, couple: [], depth: depth+1, maxDepth: maxDepth, isInLaw: isInLaw)
            node.leftNode = next
        }
        
		if node.rightPerson != nil {
            self.treeGroup.enter()
            dataService.getParentCouple(node.rightPerson!, inParent: nil, onCompletion: { parents, err in
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
                self.treeGroup.leave()
			})
        } else if depth < maxDepth {
            let next = TreeNode()
            self.buildTreeNode(next, couple: [], depth: depth+1, maxDepth: maxDepth, isInLaw: isInLaw)
            node.rightNode = next
        }
	}
	
    func addCoupleSprite(_ node: TreeNode, container: SKNode, px: CGFloat, py: CGFloat) -> TreeCoupleSprite {
        let sprite = TreeCoupleSprite()
        sprite.size = CGSize(width: self.leaf.size().width * 2, height: self.leaf.size().height)
        sprite.position = CGPoint(x: px, y: py)
        sprite.zPosition = self.z.advanced(by: 1)
        sprite.treeNode = node
        container.addChild(sprite)
        
        if px < self.minX {
            self.minX = px
        }
        if self.size.width * 2 + px > maxX {
            self.maxX = self.size.width * 2 + px
        }
        if py < self.minY {
            self.minY = py
        }
        if self.size.height * 2 + py > maxY {
            self.maxY = self.size.height * 2 + py
        }
        
        let offsetY = CGFloat(40)
        var y = sprite.position.y + offsetY + sprite.size.height + self.vine2.size().height/2
        if node.leftNode != nil {
            var x = sprite.position.x - (sprite.size.width / 2)
            if node.level == 0 {
                x = x - sprite.size.width / 2
            }
            
            let vine = SKSpriteNode(texture: self.vine)
            vine.position = CGPoint(x: x + self.leaf.size().width - 5, y: sprite.position.y + offsetY + self.leaf.size().height + 30)
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
                vine2.position = CGPoint(x: vx, y: vy)
                vine2.zPosition = 2
                container.addChild(vine2);
                vx = vx + vine2.size.width
                flip = !flip
            }
            
            let vine2 = SKSpriteNode(texture: self.vine2)
            vine2.position = CGPoint(x: vx - vine.size.width - 30, y: sprite.position.y + 80)
            vine2.zPosition = 2
            container.addChild(vine2)
            
            addCoupleSprite(node.leftNode!, container: container, px: x, py: y)
        }
        
        y = sprite.position.y + offsetY + sprite.size.height + self.vine2.size().height/2
        if node.rightNode != nil {
            var x = sprite.position.x + (sprite.size.width / 2)
            if node.level == 0 {
                x = x + sprite.size.width / 2
            }
            
            let vine = SKSpriteNode(texture: self.vine3)
            vine.position = CGPoint(x: x + self.leaf.size().width - 6, y: sprite.position.y + offsetY + self.leaf.size().height + 30)
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
                vine2.position = CGPoint(x: vx, y: vy)
                vine2.zPosition = 2
                container.addChild(vine2);
                vx = vx - vine2.size.width
                flip = !flip
            }

            
            addCoupleSprite(node.rightNode!, container: container, px: x, py: y)
        }
        
        if node.leftNode == nil && node.rightNode == nil && node.hasParents == true {
            let upArrow = TreeUpArrow(imageNamed: "vine_arrow")
            upArrow.position = CGPoint(x: sprite.position.x + sprite.size.width/2, y: sprite.position.y + sprite.size.height + upArrow.size.height)
            upArrow.zPosition = 5
            upArrow.treeNode = node
            container.addChild(upArrow)
            self.arrows.append(upArrow)
        }
        
        return sprite
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
    }
    
    func pinched(_ sender:UIPinchGestureRecognizer){
        print("pinched \(tscale)")
        if sender.state == UIGestureRecognizerState.ended || sender.state == UIGestureRecognizerState.cancelled {
            previousScale = nil
        }
        else if sender.state == UIGestureRecognizerState.began {
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
                let zoomIn = SKAction.scale(to: tscale, duration:0)
                treeContainer?.run(zoomIn)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        for touch in touches {
            lastPoint = touch.location(in: self)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        var nextPoint = CGPoint(x: 0,y: 0)
        for touch in touches {
            nextPoint = touch.location(in: self)
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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch in touches {
            lastPoint = touch.location(in: self)
            if moved == false {
                let touchedNode = atPoint(lastPoint)
                if touchedNode == bubbleButton {
                    if panelPerson != nil {
                        self.showBubbleGame(panelPerson!, previousTopic: GameScene.TOPIC_START_TREE)
                    }
                }
				else if touchedNode == matchButton {
                    if panelPerson != nil {
                        self.showMatchGame(panelPerson!, previousTopic: GameScene.TOPIC_START_TREE)
                    }
				}
				else if touchedNode == scratchButton {
                    if panelPerson != nil {
                        self.showScratchGame(panelPerson!, previousTopic: GameScene.TOPIC_START_TREE)
                    }
				}
				else if touchedNode == puzzleButton {
                    if panelPerson != nil {
                        self.showPuzzleGame(panelPerson!, previousTopic: GameScene.TOPIC_START_TREE)
                    }
				}
				else if touchedNode == coloringButton {
                    if panelPerson != nil {
                        self.showColoringGame(panelPerson!, previousTopic: GameScene.TOPIC_START_TREE)
                    }
				}
				else if touchedNode == dressupButton {
                    if panelPerson != nil {
                        self.showDressupGame(dollConfig!, person: panelPerson!, previousTopic: GameScene.TOPIC_START_TREE)
                    }
				}
                else if touchedNode == songButton {
                    if panelPerson != nil {
                        self.showSongGame(panelPerson!, previousTopic: GameScene.TOPIC_START_TREE)
                    }
                }
				else if touchedNode == cardButton {
                    if panelPerson != nil {
                        self.showCardGame(panelPerson!, previousTopic: GameScene.TOPIC_START_TREE)
                    }
                }
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
        if buttonPanel != nil && buttonPanel?.isHidden == false {
            buttonPanel?.removeAllChildren()
            let act = SKAction.sequence( [ SKAction.resize(toWidth: 5, height: 5, duration: 0.3), SKAction.removeFromParent() ])
            buttonPanel?.run(act, completion: {
                self.buttonPanel?.isHidden = true
            }) 
        }
    }
    
    func showButtonPanel(_ node:TreePersonSprite, relationship: String) {
        if self.buttonPanel != nil && self.buttonPanel?.isHidden == true {
            self.buttonPanel?.removeFromParent()
        }
        self.buttonPanel = SKSpriteNode(color: UIColor(hexString: "#00A400FF"), size: CGSize(width: 5, height: 5))
        self.buttonPanel?.zPosition = 100
        self.buttonPanel?.position = CGPoint(x: node.position.x + node.size.width + 100, y: node.position.y + 50)
        node.parent!.addChild(self.buttonPanel!)
		panelPerson  = node.person!
		let place = PlaceHelper.getPersonCountry(panelPerson!)
		dollConfig = self.dolls.getDollConfig(place, person: panelPerson!)
        let texture = SKTexture(imageNamed: dollConfig!.getThumbnail())
        let ratio = texture.size().width / texture.size().height
        self.dressupButton?.size.width = (self.dressupButton?.size.height)! * ratio
        self.dressupButton?.texture = texture
        self.buttonPanel?.run(SKAction.resize(toWidth: 310, height: 220, duration: 0.6), completion: {
            if self.buttonPanel == nil {
                return
            }
			let startX = CGFloat(-125)
            var x = startX
			var y = CGFloat(-73)
            var counter = 0
			for button in self.buttons {
                if counter >= 4 {
                    x = startX
                    y = y + button.size.height + 8
                    counter = 0
                }
				button.position = CGPoint(x: x, y: y)
				self.buttonPanel?.addChild(button)
                x = x + 8 + button.size.width
                counter += 1
			}
            y = y + self.buttons[0].size.height + 7
            let relLabel = SKLabelNode(text: relationship)
            relLabel.fontSize = self.buttonPanel!.size.width / 9
            relLabel.fontColor = UIColor.white
            relLabel.position = CGPoint(x: 0, y: y)
            relLabel.zPosition = 3
            self.adjustLabelFontSizeToFitRect(relLabel, node: self.buttonPanel!, adjustUp: false)
            self.buttonPanel?.addChild(relLabel)
            
            y = y + relLabel.fontSize + 5
            let nameLabel = SKLabelNode(text: node.person?.name as String?)
            nameLabel.fontSize = self.buttonPanel!.size.width / 9
            nameLabel.fontColor = UIColor.white
            nameLabel.position = CGPoint(x: 0, y: y)
            nameLabel.zPosition = 3
            self.adjustLabelFontSizeToFitRect(nameLabel, node: self.buttonPanel!, adjustUp: false)
            self.buttonPanel?.addChild(nameLabel)
		}) 
    }
    
    func personTouched(_ node:TreePersonSprite) {
        if self.treeSearchGame?.complete == true {
            if node.person != nil {
                let relationship = RelationshipCalculator.getRelationship(selectedPerson!, p: node.person!)
                var msg = "\(node.person!.name!) is your \(relationship). "
                var heshe = "He was "
                if node.person!.gender == GenderType.female {
                    heshe = "She was "
                }
                if relationship == "" {
                    msg = "\(node.person!.name!) "
                    heshe = "was "
                }
                else if relationship == "You" {
                    msg = "Hi, \(node.person!.givenName!). "
                    heshe = "You were "
                }
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM d, yyyy"
                if node.person?.birthPlace != nil && node.person!.birthDate != nil {
                    let dateString = formatter.string(from: node.person!.birthDate!)
                    msg += "\(heshe) born on \(dateString) in \(node.person!.birthPlace!)"
                }
                else if node.person?.birthDate != nil {
                    let dateString = formatter.string(from: node.person!.birthDate!)
                    msg += "\(heshe) born on \(dateString)"
                } else if node.person?.birthPlace != nil {
                    msg += "\(heshe) born in \(node.person!.birthPlace!)"
                }
                self.speak(msg)
                if buttonPanel != nil && buttonPanel!.size.width > 5 {
                    buttonPanel?.removeAllActions()
                    let act = SKAction.sequence( [ SKAction.resize(toWidth: 5, height: 5, duration: 1.0), SKAction.removeFromParent() ])
                    buttonPanel?.run(act, completion: {
                        self.showButtonPanel(node, relationship: relationship)
                    }) 
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
    
    func arrowTouched(_ upArrow:TreeUpArrow) {
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
        addCoupleSprite(newNode, container: upArrow, px: -1 * leaf.size().width, py: -1 * (leaf.size().height + upArrow.size.height))
    }
}
