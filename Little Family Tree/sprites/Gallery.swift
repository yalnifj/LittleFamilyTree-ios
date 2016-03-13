import Foundation
import SpriteKit

class Gallery : SKSpriteNode {
	var visibleNodes = [SKNode]()
	var currentNode = 0
	var distance = 2
	var adapter:GalleryPageAdapter? {
		didSet {
			visibleNodes.removeAll()
			self.removeAllChildren()
			var x = 0 - self.size.width / 2
			let y = self.size.height / 2
			let s = currentNode - distance
			let e = currentNode + distance + 1
			for n in s..<e {
				if n >= 0 {
					let node = adapter!.getNodeAtPosition(n)
					node.position = CGPointMake(x, y)
					let ratio = node.size.width / node.size.height
					node.size = CGSizeMake(self.size.height * 0.75 * ratio, self.size.height * 0.75)
					visibleNodes.append(node)
					self.addChild(node)
				}
				x += self.size.width / CGFloat(1 + distance * 2)
			}
		}
	}
	
	

}

protocol GalleryPageAdapter {
	func getNodeAtPosition(position:Int) -> SKSpriteNode
}