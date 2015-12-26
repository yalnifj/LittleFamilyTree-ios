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
        
        setupTopBar()
        
        showLoadingDialog()
        
		let dataService = DataService.getInstance()
		dataService.getChildren(selectedPerson!, onCompletion: { children, err in 
			if children == nil || children.count == 0 {
				dataService.getParents(selectedPerson!, onCompletion: { parents, err in {
					if parents != nil && parents.count > 0 {
						root = TreeNode()
						root.isRoot = true
						buildTreeNode(root!, couple:parents, depth:0, maxDepth: 3, isInLaw:false)
						
						dataService.getChildren(parents[0]!, onCompletion: { children2, err in 
							self.addChildNodes(root, children: children2)
						})
						
					} else {
						root = TreeNode()
						root.isRoot = true
						buildTreeNode(root!, couple:[ selectedPerson! ], depth:0, maxDepth: 3, isInLaw:false)
					}
				})
			} else {
				dataService.getSpouses(selectedPerson!, onCompletion: { spouses, err in {
					let couple = [LittlePerson]()
					couple.append(self.selectedPerson!)
					if spouses != nil && spouses.count > 0 {
						couple.append(spouses[0])
					}
					root = TreeNode()
					root.isRoot = true
					buildTreeNode(root!, couple:couple, depth:0, maxDepth: 3, isInLaw:false)
					
					self.addChildNodes(root, children: children)
				})
			}
		})
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
		if couple[0].gender == GenderType.FEMALE {
			node.rightPerson = couple[0]
		} else {
			node.leftPerson = couple[0]
		}
		node.level = depth
		node.isInLaw = isInLaw
		
		if couple.count > 1
			if node.leftPerson != nil {
				node.rightPerson = couple[1]
			} else {
				node.leftPerson = couple[1]
			}
		}
		
		let dataService = DataService.getInstance()
		if node.leftPerson != nil {
			dataService.getParents(node.leftPerson, onCompletion: { parents, err in 
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
				}
			})
		}
		if node.rightPerson != nil {
			dataService.getParents(node.rightPerson, onCompletion: { parents, err in 
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
				}
			})
		}
	}
	
	func getTreeParents(node:TreeNode) {
	
	}
    
    override func update(currentTime: NSTimeInterval) {
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        for touch in touches {
            lastPoint = touch.locationInNode(self)
            let touchedNode = nodeAtPoint(lastPoint)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var nextPoint = CGPointMake(0,0)
        for touch in touches {
            nextPoint = touch.locationInNode(self)
            
        }
        lastPoint = nextPoint
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        for touch in touches {
            lastPoint = touch.locationInNode(self)

        }
    }
}