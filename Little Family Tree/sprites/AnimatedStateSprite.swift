//
//  AnimatedStateSprite.swift
//  Little Family Tree
//
//  Created by Melissa on 9/22/15.
//  Copyright (c) 2015 Melissa. All rights reserved.
//

import Foundation

import SpriteKit

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
    
    func addTexture(st:Int, texture:SKTexture) {
        if (stateTextures[st] == nil) {
            stateTextures[st] = [SKTexture]()
        }
        stateTextures[st]?.append(texture)
    }
    
    func addAction(st:Int, action:SKAction) {
		if (stateActions[st] == nil) {
            stateActions[st] = [SKAction]()
        }
        stateActions[st]?.append(action)
    }
    
    func addSound(st:Int, action:SKAction) {
        stateSounds[st] = action
    }
    
    func addSound(st:Int, soundFile:String) {
        stateSounds[st] = SKAction.playSoundFileNamed(soundFile, waitForCompletion: true);
    }
    
    func addClick(st:Int, val:Bool) {
        clickStates[st] = val
    }
    
    func addEvent(st:Int, topic:String) {
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
	
	func changeState(nextState:Int) {
        state = nextState;
        
        if (stateTextures[state] != nil) {
            self.texture = stateTextures[nextState]?[0];
        }
        removeAllActions();
        if (stateSounds[state] != nil) {
            let quietMode = DataService.getInstance().dbHelper.getProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET)
            if quietMode == nil || quietMode == "false" {
                runAction(stateSounds[state]!)
            }
        }
		if (moveAction != nil) {
			runAction(moveAction!)
		}
        if (stateActions[state] != nil) {
			for action in stateActions[state]! {
				runAction(action, completion: {() -> Void in
					self.nextState()
					})
			}
        } else {
            if stateTextures[nextState]?.count > 1 {
                let action = SKAction.repeatActionForever(SKAction.animateWithTextures(stateTextures[nextState]!, timePerFrame: 0.06, resize: false, restore: true))
                addAction(state, action: action)
                runAction(action)
            }
        }
        if stateEvents[state] != nil {
            EventHandler.getInstance().publish(stateEvents[state]!, data: self)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        lastPoint = touches.first?.locationInNode(self)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        let nextPoint = touches.first?.locationInNode(self)
        if nextPoint != nil && lastPoint != nil {
            if abs(nextPoint!.x - lastPoint!.x) > 8 || abs(nextPoint!.y - lastPoint!.y) > 8 {
                moved = true
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        if (!moved) {
            if (clickStates[state] == nil || clickStates[state]==true) {
                nextState()
            }
        }
        moved = false;
    }
}