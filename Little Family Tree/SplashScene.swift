//
//  SplashScene.swift
//  Little Family Tree
//
//  Created by Melissa on 10/7/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import SpriteKit

class SplashScene: SKScene, LoginCompleteListener {
    var dataService:DataService?
    var startTime:NSTimeInterval?
    var launched = false
    
    override func didMoveToView(view: SKView) {
        let logo = SKSpriteNode(imageNamed: "little_family_logo")
        logo.position = CGPointMake(self.size.width/2, self.size.height/2 - 20)
        self.addChild(logo)
        
        let tree = SKSpriteNode(imageNamed: "growing_plant1")
        tree.position = CGPointMake(self.size.width/2, self.size.height - tree.size.height/2 - 20)
        let growing:[SKTexture] = [
            SKTexture(imageNamed: "growing_plant2"),
            SKTexture(imageNamed: "growing_plant3"),
            SKTexture(imageNamed: "growing_plant4"),
            SKTexture(imageNamed: "growing_plant5"),
            SKTexture(imageNamed: "growing_plant6"),
            SKTexture(imageNamed: "growing_plant7"),
            SKTexture(imageNamed: "growing_plant1")
        ]
        self.addChild(tree)
        let action = SKAction.repeatActionForever(SKAction.animateWithTextures(growing, timePerFrame: 0.25, resize: false, restore: false))
        tree.runAction(action)
        
        let introTune = SKAction.playSoundFileNamed("intro", waitForCompletion: true)
        runAction(introTune)
        
        dataService = DataService.getInstance()
    }
    
    override func update(currentTime: NSTimeInterval) {
        if (startTime == nil) {
            startTime = currentTime
        }
        else {
            if (!launched && (currentTime - startTime! > 10)) {
                if dataService?.authenticating != nil && dataService?.authenticating == false {
                    if dataService?.remoteService?.sessionId != nil && dataService?.dbHelper.getFirstPerson() != nil {
                        if self.view?.subviews != nil {
                            for v in (self.view?.subviews)! {
                                v.removeFromSuperview()
                            }
                        }
                        let transition = SKTransition.revealWithDirection(.Down, duration: 0.5)
                        
                        let nextScene = ChoosePlayerScene(size: scene!.size)
                        nextScene.scaleMode = .AspectFill
                        launched = true
                        scene?.view?.presentScene(nextScene, transition: transition)
                    } else {
                        let subview = ChooseServiceView(frame: (self.view?.bounds)!)
                        subview.loginListener = self
                        launched = true
                        self.view?.addSubview(subview)
                    }
                }
            }
        }
    }
    
    func LoginComplete() {
        launched = false
    }
}
