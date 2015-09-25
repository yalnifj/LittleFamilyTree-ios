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
    var state:Int = 0;
    var moved:Bool = false;
    
    func addTexture(st:Int, texture:SKTexture) {
        if (stateTextures[st] == nil) {
            stateTextures[st] = [SKTexture]()
        }
        var textures = stateTextures[st]!;
        textures.append(texture);
    }
    
    func addAction(st:Int, action:SKAction) {
        stateActions[st] = action;
    }
    
    func update() {
        
    }
    
    func nextState() {
        var nextState = state + 1;
        if (stateTextures[nextState] == nil || stateTextures[nextState]?.count==0) {
            nextState = 0;
        }
        state = nextState;
        
        self.texture = stateTextures[nextState]?[0];
        removeAllActions();
        if (stateActions[state] != nil) {
            runAction(stateActions[state]);
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event);
        moved = true;
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        if (!moved) {
            
        }
        moved = false;
    }
}