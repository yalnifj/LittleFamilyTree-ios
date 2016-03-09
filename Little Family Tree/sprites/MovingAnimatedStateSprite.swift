import Foundation

import SpriteKit

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
				position = CGPointMake(0 - size.width*0.8, position.y)
			}
			else {
				removeMe = true
			}
		}
		if position.x + size.width < 0 {
			if bounce == true {
			}
			else if wrap == true {
				position = CGPointMake(maxX! - size.width*0.8, position.y)
			}
			else {
				removeMe = true
			}
		}
		if position.y > maxY {
			if bounce == true {
				
			} else if wrap == true {
				position = CGPointMake(position.x, 0 - size.height*0.8)
			}
			else {
				removeMe = true
			}
		}
		if position.y + size.height < 0 {
			if bounce == true {
			}
			else if wrap == true {
				position = CGPointMake(position.x, maxY! - size.height*0.8)
			}
			else {
				removeMe = true
			}
		}
    }
}