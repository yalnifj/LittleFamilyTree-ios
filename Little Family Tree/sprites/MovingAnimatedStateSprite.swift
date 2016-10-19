import Foundation

import SpriteKit
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


class MovingAnimatedStateSprite: AnimatedStateSprite {
	var maxX:CGFloat?
	var maxY:CGFloat?
	var bounce:Bool = false
	var wrap:Bool = true
	
	override func update() {
        super.update()
		
		if position.x > maxX {
			if bounce == true {
				
			} else if wrap == true {
				position = CGPoint(x: 0 - size.width*0.8, y: position.y)
			}
			else {
				removeMe = true
			}
		}
		if position.x + size.width < 0 {
			if bounce == true {
			}
			else if wrap == true {
				position = CGPoint(x: maxX! - size.width*0.8, y: position.y)
			}
			else {
				removeMe = true
			}
		}
		if position.y > maxY {
			if bounce == true {
				
			} else if wrap == true {
				position = CGPoint(x: position.x, y: 0 - size.height*0.8)
			}
			else {
				removeMe = true
			}
		}
		if position.y + size.height < 0 {
			if bounce == true {
			}
			else if wrap == true {
				position = CGPoint(x: position.x, y: maxY! - size.height*0.8)
			}
			else {
				removeMe = true
			}
		}
    }
}
