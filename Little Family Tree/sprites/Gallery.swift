import Foundation
import SpriteKit

class Gallery : SKSpriteNode {
	var visibleNodes = [SKNode]()
	var currentNode = 0
	var distance = 2
	var adapter:GalleryPageAdapter? {
		didSet {
            adapter!.gallery = self
            adapterDidChange()
        }
	}
    
    func adapterDidChange() {
        currentNode = 0
        visibleNodes.removeAll()
        self.removeAllChildren()
        var x = 0 - self.size.width / 2
        let y = self.size.height / 2
        let s = currentNode - distance
        let e = currentNode + distance + 1
        for n in s..<e {
            if n >= 0 && n < adapter!.size() {
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
                node.runAction(SKAction.scaleXTo(x / (0.01 + self.size.width - x), duration: 0.0))
                visibleNodes.append(node)
                self.addChild(node)
            }
            x += self.size.width / CGFloat(1 + distance * 2)
        }

    }
	
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
    }
}

protocol GalleryPageAdapter : class {
    var gallery:Gallery? { get set }
    func size() -> Int
	func getNodeAtPosition(position:Int) -> SKSpriteNode
}