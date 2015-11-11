//
//  SplashScene.swift
//  Little Family Tree
//
//  Created by Melissa on 10/7/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import SpriteKit

class SplashScene: SKScene {
    var dataService:DataService?
    var startTime:NSTimeInterval?
    
    override func didMoveToView(view: SKView) {
        dataService = DataService.getInstance()
        
        let logo = SKSpriteNode(imageNamed: "little_family_logo")
        logo.position = CGPointMake(0.5, 0.5)
        self.addChild(logo)
        
        let tree = SKSpriteNode(imageNamed: "growing_plant1")
        tree.position = CGPointMake(0.5, 0)
        let growing:[SKTexture] = [
            SKTexture(imageNamed: "growing_plant2"),
            SKTexture(imageNamed: "growing_plant3"),
            SKTexture(imageNamed: "growing_plant4"),
            SKTexture(imageNamed: "growing_plant5"),
            SKTexture(imageNamed: "growing_plant6"),
            SKTexture(imageNamed: "growing_plant7"),
            SKTexture(imageNamed: "growing_plant1")
        ]
        let action = SKAction.repeatActionForever(SKAction.animateWithTextures(growing, timePerFrame: 0.06, resize: false, restore: false))
        tree.runAction(action)
        
        let introTune = SKAction.playSoundFileNamed("intro", waitForCompletion: true)
        runAction(introTune)
    }
    
    override func update(currentTime: NSTimeInterval) {
        if (startTime == nil) {
            startTime = currentTime
        }
        else {
            if (currentTime - startTime! > 3) {
                if dataService?.authenticating != nil && dataService?.authenticating == false {
                    if dataService?.remoteService?.sessionId != nil {
                        
                    } else {
                        let transition = SKTransition.revealWithDirection(.Down, duration: 0.5)
                        
                        let nextScene = GameScene(size: scene!.size)
                        nextScene.scaleMode = .AspectFill
                        
                        scene?.view?.presentScene(nextScene, transition: transition)
                    }
                }
            }
        }
    }
}
