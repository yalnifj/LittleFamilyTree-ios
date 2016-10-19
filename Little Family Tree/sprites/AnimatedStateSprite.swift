//
//  AnimatedStateSprite.swift
//  Little Family Tree
//
//  Created by Melissa on 9/22/15.
//  Copyright (c) 2015 Melissa. All rights reserved.
//

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


class AnimatedStateSprite: SKSpriteNode {
    var stateTextures = [Int : [SKTexture]]()
    var stateActions = [Int : [SKAction]]()
    var stateSounds = [Int : SKAction]()
    var clickStates = [Int : Bool]()
    var stateEvents = [Int : String]()
	var moveAction:SKAction?
    var state:Int = 0
    var moved:Bool = false
	var removeMe:Bool = false
    var lastPoint:CGPoint?
    
    func addTexture(_ st:Int, texture:SKTexture) {
        if (stateTextures[st] == nil) {
            stateTextures[st] = [SKTexture]()
        }
        stateTextures[st]?.append(texture)
    }
    
    func addAction(_ st:Int, action:SKAction) {
		if (stateActions[st] == nil) {
            stateActions[st] = [SKAction]()
        }
        stateActions[st]?.append(action)
    }
    
    func addSound(_ st:Int, action:SKAction) {
        stateSounds[st] = action
    }
    
    func addSound(_ st:Int, soundFile:String) {
        stateSounds[st] = SKAction.playSoundFileNamed(soundFile, waitForCompletion: true);
    }
    
    func addClick(_ st:Int, val:Bool) {
        clickStates[st] = val
    }
    
    func addEvent(_ st:Int, topic:String) {
        stateEvents[st] = topic
    }
    
    func update() {
        
    }
    
    func nextState() {
        var nextState = state + 1;
        if ((stateTextures[nextState] == nil || stateTextures[nextState]?.count==0)
                && (stateActions[nextState] == nil || stateActions[nextState]?.count==0)
                && clickStates[nextState] == nil) {
            nextState = 0;
        }
        if (stateTextures[state] == nil && self.texture != nil ) {
            addTexture(state, texture: self.texture!)
        }
		
		self.changeState(nextState)
	}
	
	func changeState(_ nextState:Int) {
        state = nextState;
        
        if (stateTextures[state] != nil) {
            self.texture = stateTextures[nextState]?[0];
        }
        removeAllActions();
        if (stateSounds[state] != nil) {
            let quietMode = DataService.getInstance().dbHelper.getProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET)
            if quietMode == nil || quietMode == "false" {
                run(stateSounds[state]!)
            }
        }
		if (moveAction != nil) {
			run(moveAction!)
		}
        if (stateActions[state] != nil) {
			for action in stateActions[state]! {
				run(action, completion: {() -> Void in
					self.nextState()
					})
			}
        } else {
            if stateTextures[nextState]?.count > 1 {
                let action = SKAction.repeatForever(SKAction.animate(with: stateTextures[nextState]!, timePerFrame: 0.06, resize: false, restore: true))
                addAction(state, action: action)
                run(action)
            }
        }
        if stateEvents[state] != nil {
            EventHandler.getInstance().publish(stateEvents[state]!, data: self)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        lastPoint = touches.first?.location(in: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        let nextPoint = touches.first?.location(in: self)
        if nextPoint != nil && lastPoint != nil {
            if abs(nextPoint!.x - lastPoint!.x) > 8 || abs(nextPoint!.y - lastPoint!.y) > 8 {
                moved = true
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if (!moved) {
            if (clickStates[state] == nil || clickStates[state]==true) {
                nextState()
            }
        }
        moved = false;
    }
}
