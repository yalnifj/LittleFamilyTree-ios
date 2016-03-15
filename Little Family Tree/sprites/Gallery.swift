import Foundation
import SpriteKit

class Gallery : SKSpriteNode {
	var visibleNodes = [SKNode]()
	var currentNode = 0
	var distance = 2
	var adapter:GalleryPageAdapter? {
		didSet {
            adapter!.setGallery(self)
            adapterDidChange()
        }
	}
    var lastPoint:CGPoint?
    var moved = false
    
    func adapterDidChange() {
        currentNode = 0
        visibleNodes.removeAll()
        self.removeAllChildren()
        var x = 0 - self.size.width / 2
        let y = CGFloat(0)
        let s = currentNode - distance
        let e = currentNode + distance + 1
        for n in s..<e {
            if n >= 0 && n < adapter!.size() {
                let node = setupNode(n, x: x, y: y)
                node.runAction(SKAction.scaleXTo(x / (0.001 + self.size.width - x) / 4, duration: 0.0))
                visibleNodes.append(node)
                self.addChild(node)
            }
            x += self.size.width / CGFloat(1 + distance * 2) - 10
        }

    }
    
    func setupNode(n:Int, x:CGFloat, y:CGFloat) -> SKSpriteNode {
        let node = adapter!.getNodeAtPosition(n)
        node.position = CGPointMake(x, y)
        if n < currentNode {
            node.zPosition = CGFloat(currentNode - n)
        } else if n > currentNode {
            node.zPosition = CGFloat(n - currentNode)
        } else {
            node.zPosition = CGFloat(n)
        }
        let ratio = node.size.width / node.size.height
        node.size = CGSizeMake(self.size.height * 0.75 * ratio, self.size.height * 0.75)
        
        return node
        
    }
	
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        for touch in touches {
            lastPoint = touch.locationInNode(self)
            break
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        for touch in touches {
            let nextPoint = touch.locationInNode(self)
            if abs(nextPoint.x - lastPoint!.x) > 8 {
                moved = true
                slide(lastPoint!, newPoint: nextPoint)
                lastPoint = nextPoint
            }
            break
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        for touch in touches {
            lastPoint = touch.locationInNode(self)
            break
        }
        moved = false
    }
    
    func slide(oldPoint:CGPoint, newPoint:CGPoint) {
        let xdiff = newPoint.x - oldPoint.x
        for node in visibleNodes {
            node.removeAllActions()
            let newx = node.position.x + xdiff
            node.runAction(SKAction.scaleXTo(newx / (0.001 + self.size.width - newx) / 4, duration: 0.1))
            node.runAction(SKAction.moveByX(xdiff, y: 0, duration: 0.1)) {
                if node.position.x < 0 {
                    node.removeFromParent()
                    self.visibleNodes.removeObject(node)
                    if self.currentNode < self.adapter!.size() {
                        self.currentNode++
                        if self.currentNode < self.adapter!.size()-self.distance {
                            let x = self.size.width / CGFloat(1 + self.distance * 2)
                            let node = self.setupNode(self.currentNode + self.distance - 1, x: x, y: CGFloat(0))
                            node.runAction(SKAction.scaleXTo(x / (0.001 + self.size.width - x) / 2, duration: 0.0))
                            self.visibleNodes.append(node)
                            self.addChild(node)
                        }
                    }
                }
            }
        }
    }
}

protocol GalleryPageAdapter : class {
    func setGallery(gallery:Gallery)
    func size() -> Int
	func getNodeAtPosition(position:Int) -> SKSpriteNode
}