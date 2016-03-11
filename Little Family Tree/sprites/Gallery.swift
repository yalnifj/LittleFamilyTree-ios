import Foundation
import SpriteKit

class Gallery : SKSpriteNode {
	var visibleNodes = [SKNode]()
	var currentNode = 0
	var distance = 2
	var adapter:GalleryPageAdapter? {
		didSet: {
			visibleNodes.removeAll()
			self.removeAllChildren()
			var x = 0 - self.size.width / 2
			var y = self.size.height / 2
			let s = currentNode - distance
			let e = currentNode + distance
			for n in s..<=e {
				if n >= 0 {
					let node = adapter.getNodeAtPosition(n)
					node.position = CGPointMake(x, y)
					let ratio = node.size.width / node.size.height
					node.size = CGSizeMake(self.size.height * 0.75 * ratio, self.size.height * 0.75)
					visibleNodes.append(n)
					self.addChild(n)
				}
				x += self.size.width / (1 + distance * 2)
			}
		}
	}
	
	

}

protocol GalleryPageAdapter {
	func getNodeAtPosition(position:Int) -> SKNode
}