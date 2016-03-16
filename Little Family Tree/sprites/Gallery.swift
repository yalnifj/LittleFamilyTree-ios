import Foundation
import SpriteKit

class Gallery : SKSpriteNode {
	var visibleNodes = [SKNode]()
	var currentNode = 0
	var distance = 2
    var startNode = -2
    var endNode = 2
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
        startNode = currentNode - distance
        endNode = currentNode + distance
        visibleNodes.removeAll()
        self.removeAllChildren()
        let xspace = self.size.width / CGFloat(1.0 + Double(distance))
        var x = xspace * CGFloat(0 - distance)
        let y = CGFloat(0)
        let s = startNode
        let e = endNode + 1
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
            //-- snap nodes into place
            let xspace = self.size.width / CGFloat(1.0 + Double(distance))
            var x = xspace * CGFloat(0 - distance)
            let s = startNode
            let e = endNode + 1
            var c = 0
            for n in s..<e {
                if n >= 0 && c < visibleNodes.count {
                    let node = visibleNodes[c]
                    
                    node.runAction(SKAction.scaleXTo(1 - (abs(x) / (xspace*CGFloat(distance*2))), duration: 0.3))
                    node.runAction(SKAction.scaleYTo(1 - (abs(x) / (xspace*CGFloat(distance*4))), duration: 0.3))
                    node.runAction(SKAction.fadeAlphaTo(1 - (abs(x) / (xspace*CGFloat(Double(distance)*1.5))), duration: 0.3))
                    node.runAction(SKAction.moveToX(x, duration: 0.3))
                    c++
                }
                x += xspace
            }
            break
        }
        moved = false
    }
    
    func slide(oldPoint:CGPoint, newPoint:CGPoint) {
        var xdiff = CGFloat(1) * (newPoint.x - oldPoint.x)
        let xspace = self.size.width / CGFloat(1.0 + Double(distance))
        
        if self.currentNode==0 && visibleNodes.count > 0 && visibleNodes[0].position.x + xdiff > 0 {
            xdiff = 0 - visibleNodes[0].position.x
        }
        if self.currentNode == adapter!.size()-1 && visibleNodes.count > 0 && visibleNodes[visibleNodes.count - 1].position.x + xdiff < 0 {
            xdiff = 0 - visibleNodes[visibleNodes.count - 1].position.x
        }
        
        var c = 0
        for node in visibleNodes {
            node.removeAllActions()
            let newx = node.position.x + xdiff
            
            node.runAction(SKAction.scaleXTo(1 - (abs(newx) / (xspace*CGFloat(distance*2))), duration: 0.0))
            node.runAction(SKAction.scaleYTo(1 - (abs(newx) / (xspace*CGFloat(distance*4))), duration: 0.0))
            node.runAction(SKAction.fadeAlphaTo(1 - (abs(newx) / (xspace*CGFloat(distance))), duration: 0.0))
            node.runAction(SKAction.moveToX(newx, duration: 0.0)) {
                if node.position.x < xspace * -2 && self.endNode < self.adapter!.size() + self.distance {
                    node.removeFromParent()
                    self.visibleNodes.removeObject(node)
                    self.startNode++
                    self.endNode++
                    self.currentNode++
                    print("start=\(self.startNode) current=\(self.currentNode) end=\(self.endNode)")

                    if self.endNode < self.adapter!.size() {
                        let x = xspace * CGFloat(self.distance-1)
                        let node = self.setupNode(self.endNode, x: x, y: CGFloat(0))
                        node.runAction(SKAction.scaleXTo(1 - (abs(x) / (xspace*CGFloat(self.distance*2))), duration: 0.0))
                        node.runAction(SKAction.scaleYTo(1 - (abs(x) / (xspace*CGFloat(self.distance*4))), duration: 0.0))
                        node.runAction(SKAction.fadeAlphaTo(1 - (abs(x) / (xspace*CGFloat(Double(self.distance)*1.5))), duration: 0.0))
                        self.visibleNodes.append(node)
                        self.addChild(node)
                    }

                } else if node.position.x > xspace * 2 && self.startNode > 0 - self.distance {
                    node.removeFromParent()
                    self.visibleNodes.removeObject(node)
                    self.startNode--
                    self.endNode--
                    self.currentNode--
                    print("start=\(self.startNode) current=\(self.currentNode) end=\(self.endNode)")
                    
                    if self.startNode >= 0 {
                        let x = xspace * CGFloat(self.distance * -1)
                        let node = self.setupNode(self.startNode, x: x, y: CGFloat(0))
                        node.runAction(SKAction.scaleXTo(1 - (abs(x) / (xspace*CGFloat(self.distance*2))), duration: 0.0))
                        node.runAction(SKAction.scaleYTo(1 - (abs(x) / (xspace*CGFloat(self.distance*4))), duration: 0.0))
                        node.runAction(SKAction.fadeAlphaTo(1 - (abs(x) / (xspace*CGFloat(Double(self.distance)*1.5))), duration: 0.0))
                        self.visibleNodes.append(node)
                        self.addChild(node)
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