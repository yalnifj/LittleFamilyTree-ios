import Foundation

import SpriteKit

class SpriteAnimator {
	var timings = [AnimatorTiming]()
	var startTime:NSTimeInterval = 0
	var currentTime:NSTimeInterval = 0
	var currentPosition:Int = 0
	var started = false
	var finished = false
	
	func start() {
		timings.sortInPlace({
			return $0.time < $1.time
		})
		let now = NSDate()
		startTime = now.timeIntervalSince1970
		currentTime = 0
		currentPosition = 0
		started = true
		finished = false
	}
	
	func addTiming(timing:AnimatorTiming) {
		timings.append(timing)
	}
	
	func update(currentTime: CFTimeInterval) {
		if (started && !finished) {
			if currentPosition >= timings.count {
				finished = true
				started = false
				return
			}
			
			self.currentTime = currentTime - self.startTime
			while (currentPosition < timings.count && timings[currentPosition].time < self.currentTime) {
				timings[currentPosition].apply()
				currentPosition += 1
			}
		}
	}
}

class AnimatorTiming {
	var time:NSTimeInterval
	func apply() {
		print("nothing to do in empty AnimatorTiming")
	}
}

class SpriteStateTiming : AnimatorTiming {
	var sprite:AnimatedStateSprite
	var state:Int = 0
	
	init(time:NSTimeInterval, sprite:AnimatedStateSprite, state:Int) {
		self.time = time
		self.sprite = sprite
		self.state = state
	}
	
	override func apply() {
		if (state < 0) {
			sprite.removeMe = true
		}
		else {
			sprite.setState(state)
		}
	}
}

class SpriteActionTiming : AnimatorTiming {
	var sprite:SKNode
	var action:SKAction
	
	init(time:NSTimeInterval, sprite:SKNode, action:SKAction) {
		self.time = time
		self.sprite = sprite
		self.action = action
	}
	
	override func apply() {
		sprite.runAction(action)
	}
}