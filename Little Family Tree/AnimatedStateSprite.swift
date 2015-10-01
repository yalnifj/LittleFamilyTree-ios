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
    var stateTextures = [Int : [SKTexture]]();
    var stateActions = [Int : SKAction]();
    var stateSounds = [Int : SKAction]();
    var clickStates = [Int : Bool]()
    var state:Int = 0;
    var moved:Bool = false;
    
    func addTexture(st:Int, texture:SKTexture) {
        if (stateTextures[st] == nil) {
            stateTextures[st] = [SKTexture]()
        }
        stateTextures[st]?.append(texture)
    }
    
    func addAction(st:Int, action:SKAction) {
        stateActions[st] = action;
    }
    
    func addSound(st:Int, action:SKAction) {
        stateSounds[st] = action;
    }
    
    func addSound(st:Int, soundFile:String) {
        stateSounds[st] = SKAction.playSoundFileNamed(soundFile, waitForCompletion: true);
    }
    
    func addClick(st:Int, val:Bool) {
        clickStates[st] = val;
    }
    
    func update() {
        
    }
    
    func nextState() {
        var nextState = state + 1;
        if ((stateTextures[nextState] == nil || stateTextures[nextState]?.count==0)
            && stateActions[nextState] == nil && clickStates[nextState] == nil) {
            nextState = 0;
        }
        if (stateTextures[state] == nil && self.texture != nil ) {
            addTexture(state, texture: self.texture!)
        }
        state = nextState;
        
        if (stateTextures[state] != nil) {
            self.texture = stateTextures[nextState]?[0];
        }
        removeAllActions();
        if (stateSounds[state] != nil) {
            runAction(stateSounds[state]!)
        }
        if (stateActions[state] != nil) {
            runAction(stateActions[state]!, completion: {() -> Void in
                self.nextState()
                })
        } else {
            if stateTextures[nextState]?.count > 1 {
                let action = SKAction.repeatActionForever(SKAction.animateWithTextures(stateTextures[nextState]!, timePerFrame: 0.06, resize: false, restore: true))
                stateActions[state] = action
                runAction(action)
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event);
        moved = true;
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