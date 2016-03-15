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
        let xspace = self.size.width / CGFloat(0.5 + Double(distance))
        var x = xspace * CGFloat(0 - distance)
        let y = CGFloat(0)
        let s = currentNode - distance
        let e = currentNode + distance + 1
        for n in s..<e {
            print("n=\(n) x=\(x)")
            if n >= 0 && n < adapter!.size() {
                let node = setupNode(n, x: x, y: y)
                node.runAction(SKAction.scaleXTo(1 - (abs(x) / (xspace*CGFloat(distance*2))), duration: 0.0))
                node.runAction(SKAction.scaleYTo(1 - (abs(x) / (xspace*CGFloat(distance*4))), duration: 0.0))
                node.runAction(SKAction.fadeAlphaTo(1 - (abs(x) / (xspace*CGFloat(Double(distance)*1.5))), duration: 0.0))
                visibleNodes.append(node)
                self.addChild(node)
            }
            x += xspace
        }

    }
    
    func setupNode(n:Int, x:CGFloat, y:CGFloat) -> SKSpriteNode {
        let node = adapter!.getNodeAtPosition(n)
        node.position = CGPointMake(x, y)
        if n < currentNode {
            node.zPosition = CGFloat(adapter!.size() - (currentNode - n))
        } else if n > currentNode {
            node.zPosition = CGFloat(adapter!.size() - (n - currentNode))
        } else {
            node.zPosition = CGFloat(adapter!.size() )
        }
        
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
        var xdiff = newPoint.x - oldPoint.x
        let xspace = self.size.width / CGFloat(0.5 + Double(distance))
        
        if visibleNodes.count > 0 && visibleNodes[0].position.x + xdiff > 0 {
            xdiff = 0 - visibleNodes[0].position.x
        }
        if visibleNodes.count > 0 && visibleNodes[visibleNodes.count - 1].position.x + xdiff < 0 {
            xdiff = 0 - visibleNodes[visibleNodes.count - 1].position.x
        }
        
        var c = 0
        for node in visibleNodes {
            node.removeAllActions()
            let newx = node.position.x + xdiff
            
            node.runAction(SKAction.scaleXTo(1 - (abs(newx) / (xspace*CGFloat(distance*2))), duration: 0.1))
            node.runAction(SKAction.scaleYTo(1 - (abs(newx) / (xspace*CGFloat(distance*4))), duration: 0.1))
            node.runAction(SKAction.fadeAlphaTo(1 - (abs(newx) / (xspace*CGFloat(distance))), duration: 0.1))
            node.runAction(SKAction.moveByX(xdiff, y: 0, duration: 0.1)) {
                if node.position.x < xspace * -2 {
                    node.removeFromParent()
                    self.visibleNodes.removeObject(node)
                    if self.currentNode < self.adapter!.size() {
                        self.currentNode++
                        if self.currentNode < self.adapter!.size()-self.distance {
                            let x = xspace * CGFloat(self.distance)
                            let node = self.setupNode(self.currentNode + self.distance - 1, x: x, y: CGFloat(0))
                            node.runAction(SKAction.scaleXTo(1 - (abs(x) / (xspace*CGFloat(self.distance*2))), duration: 0.0))
                            node.runAction(SKAction.scaleYTo(1 - (abs(x) / (xspace*CGFloat(self.distance*4))), duration: 0.0))
                            node.runAction(SKAction.fadeAlphaTo(1 - (abs(x) / (xspace*CGFloat(Double(self.distance)*1.5))), duration: 0.0))
                            self.visibleNodes.append(node)
                            self.addChild(node)
                        }
                    }
                } else if node.position.x > xspace * 2 {
                    node.removeFromParent()
                    self.visibleNodes.removeObject(node)
                    if self.currentNode > 0 {
                        self.currentNode--
                        if self.currentNode > self.distance - 1 {
                            let x = xspace * CGFloat(self.distance * -1)
                            let node = self.setupNode(self.currentNode - self.distance - 1, x: x, y: CGFloat(0))
                            node.runAction(SKAction.scaleXTo(1 - (abs(x) / (xspace*CGFloat(self.distance*2))), duration: 0.0))
                            node.runAction(SKAction.scaleYTo(1 - (abs(x) / (xspace*CGFloat(self.distance*4))), duration: 0.0))
                            node.runAction(SKAction.fadeAlphaTo(1 - (abs(x) / (xspace*CGFloat(Double(self.distance)*1.5))), duration: 0.0))
                            self.visibleNodes.append(node)
                            self.addChild(node)
                        }
                    }
                }
            }
            c++
        }
    }
}

protocol GalleryPageAdapter : class {
    func setGallery(gallery:Gallery)
    func size() -> Int
    func getNodeAtPosition(position:Int) -> SKSpriteNode
}