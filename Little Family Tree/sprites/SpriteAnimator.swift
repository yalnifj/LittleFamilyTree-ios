import Foundation

import SpriteKit

class SpriteAnimator {
	var timings = [AnimatorTiming]()
	var startTime:TimeInterval = 0
	var currentTime:TimeInterval = 0
	var currentPosition:Int = 0
	var started = false
	var finished = false
	
	func start() {
		timings.sort(by: {
			return $0.time < $1.time
		})
		currentTime = 0
		currentPosition = 0
		started = true
		finished = false
	}
	
	func addTiming(_ timing:AnimatorTiming) {
		timings.append(timing)
	}
	
	func update(_ currentTime: CFTimeInterval) {
		if (started && !finished) {
            if startTime == 0 {
                startTime = currentTime
            }
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
	var time:TimeInterval = 0.0
	func apply() {
		print("nothing to do in empty AnimatorTiming")
	}
}

class SpriteStateTiming : AnimatorTiming {
	var sprite:AnimatedStateSprite
	var state:Int = 0
	
	init(time:TimeInterval, sprite:AnimatedStateSprite, state:Int) {
        self.sprite = sprite
        super.init()
		self.time = time
		self.state = state
	}
	
	override func apply() {
		if (state < 0) {
			sprite.removeMe = true
		}
		else {
			sprite.changeState(state)
		}
	}
}

class SpriteActionTiming : AnimatorTiming {
	var sprite:SKNode
	var action:SKAction
	
	init(time:TimeInterval, sprite:SKNode, action:SKAction) {
        self.sprite = sprite
        self.action = action
        super.init()
		self.time = time
	}
	
	override func apply() {
		sprite.run(action)
	}
}
