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
    var lastNodePosition:CGPoint?
    var moved = false
    
    func adapterDidChange() {
        currentNode = 0
        startNode = currentNode - distance
        endNode = currentNode + distance
        visibleNodes.removeAll()
        self.removeAllChildren()
        let xspace = self.size.width / CGFloat(2)
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
            lastNodePosition = visibleNodes[0].position
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
            let xspace = self.size.width / CGFloat(2)
            
            let totalDistance = Int(round((lastNodePosition!.x - visibleNodes[0].position.x) / xspace))
            if (totalDistance > 0 && currentNode < adapter!.size() - 1) || (totalDistance < 0 && currentNode >= 0) {
                if totalDistance < 0 {
                    var sn = startNode
                    while sn >= 1 {
                        sn -= 1
                        if sn >= 0 && sn < adapter!.size() {
                            let x = visibleNodes.first!.position.x - xspace / 2
                            let node = setupNode(sn, x: x, y: visibleNodes.first!.position.y)
                            node.runAction(SKAction.scaleXTo(1 - (abs(x) / (xspace*CGFloat(distance*2))), duration: 0.0))
                            node.runAction(SKAction.scaleYTo(1 - (abs(x) / (xspace*CGFloat(distance*4))), duration: 0.0))
                            node.runAction(SKAction.fadeAlphaTo(1 - (abs(x) / (xspace*CGFloat(Double(distance)*1.5))), duration: 0.0))
                            visibleNodes.insert(node, atIndex: 0)
                            self.addChild(node)
                        }
                    }

                }
                startNode += totalDistance
                currentNode += totalDistance
                if totalDistance > 0 {
                    var en = endNode
                    while en < adapter!.size() - 1 {
                        en += 1
                        let x = visibleNodes.last!.position.x + xspace
                        let node = setupNode(en, x: x, y: visibleNodes.last!.position.y)
                        node.runAction(SKAction.scaleXTo(1 - (abs(x) / (xspace*CGFloat(distance*2))), duration: 0.0))
                        node.runAction(SKAction.scaleYTo(1 - (abs(x) / (xspace*CGFloat(distance*4))), duration: 0.0))
                        node.runAction(SKAction.fadeAlphaTo(1 - (abs(x) / (xspace*CGFloat(Double(distance)*1.5))), duration: 0.0))
                        visibleNodes.append(node)
                        self.addChild(node)
                    }
                }
                endNode += totalDistance
            }
            
            var x = xspace * CGFloat(0 - distance)
            if visibleNodes.count > 0 {
                while visibleNodes.count > 2 && visibleNodes.first!.position.x < x {
                    visibleNodes.removeFirst()
                }
            }
            let x2 = xspace * CGFloat(distance)
            if visibleNodes.count > 0 {
                while visibleNodes.count > 2 && visibleNodes.last!.position.x > x2 {
                    visibleNodes.removeLast()
                }
            }
            
            let s = startNode
            let e = endNode + 1
            var c = 0
            for n in s..<e {
                if c < visibleNodes.count {
                    let node = visibleNodes[c]
                    let scaleX = 1 - (abs(x) / (xspace*CGFloat(distance*2)))
                    var dx = CGFloat(0)
                    if x < 0 {
                        dx = xspace * scaleX
                    }
                    if node.position.x <= x + dx {
                        node.runAction(SKAction.scaleXTo(scaleX, duration: 0.3))
                        node.runAction(SKAction.scaleYTo(1 - (abs(x + dx) / (xspace*CGFloat(distance*4))), duration: 0.3))
                        node.runAction(SKAction.fadeAlphaTo(1 - (abs(x + dx) / (xspace*CGFloat(Double(distance)*1.5))), duration: 0.3))
                        node.runAction(SKAction.moveToX(x + dx, duration: 0.3))
                        
                        if x < 0 {
                            node.zPosition = CGFloat(n)
                        } else if x > 0 {
                            node.zPosition = CGFloat(e - n)
                        } else {
                            node.zPosition = CGFloat(e + 1)
                        }
                        c += 1
                    }
                }
                x += xspace
            }
            break
        }
        moved = false
    }
    
    func slide(oldPoint:CGPoint, newPoint:CGPoint) {
        var xdiff = CGFloat(1) * (newPoint.x - oldPoint.x)
        let xspace = self.size.width / CGFloat(2)
        
        if self.currentNode==0 && visibleNodes.count > 0 && visibleNodes[0].position.x + xdiff > 0 {
            xdiff = 0 - visibleNodes[0].position.x
        }
        if self.currentNode == adapter!.size()-1 && visibleNodes.count > 0 && visibleNodes[visibleNodes.count - 1].position.x + xdiff < 0 {
            xdiff = 0 - visibleNodes[visibleNodes.count - 1].position.x
        }
        
        var c = 0
        for node in visibleNodes {
            node.removeAllActions()
            let oldx = node.position.x
            var newx = node.position.x + xdiff
            
            if newx < 0 {
                node.zPosition = CGFloat(c)
            } else if newx > 0 {
                node.zPosition = CGFloat(adapter!.size() - c)
            } else {
                node.zPosition = CGFloat(adapter!.size() + 1)
            }

            let scaleX = 1 - (abs(newx) / (xspace*CGFloat(distance*2)))
            node.runAction(SKAction.scaleXTo(scaleX, duration: 0.0))
            node.runAction(SKAction.scaleYTo(1 - (abs(newx) / (xspace*CGFloat(distance*4))), duration: 0.0))
            node.runAction(SKAction.fadeAlphaTo(1 - (abs(newx) / (xspace*CGFloat(distance))), duration: 0.0))
            if (newx < 0) {
                newx = oldx + (xdiff * scaleX)
            }
            node.runAction(SKAction.moveToX(newx, duration: 0.0))
            c += 1
        }
    }
}

protocol GalleryPageAdapter : class {
    func setGallery(gallery:Gallery)
    func size() -> Int
    func getNodeAtPosition(position:Int) -> SKSpriteNode
}