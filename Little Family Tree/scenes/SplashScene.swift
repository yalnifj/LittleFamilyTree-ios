//
//  SplashScene.swift
//  Little Family Tree
//
//  Created by Melissa on 10/7/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import SpriteKit

class SplashScene: SKScene, LoginCompleteListener, EventListener {
    var dataService:DataService?
    var startTime:NSTimeInterval?
    var launched = false
    var introTune:SKAction?
    var graybox:SKSpriteNode?
    var tree:SKSpriteNode?
    
    override func didMoveToView(view: SKView) {
        self.size.width = view.bounds.width
        self.size.height = view.bounds.height
        
        tree = SKSpriteNode(imageNamed: "growing_plant1")
        let tr = tree!.size.width / tree!.size.height
        var scale = CGFloat(1.0)
        if tree!.size.height > self.size.height / 3 {
            tree!.size.height = self.size.height / 3
            scale = tree!.size.height * tr / tree!.size.width
            tree!.size.width = tree!.size.height * tr
        }
        tree!.position = CGPointMake(self.size.width/2, self.size.height - tree!.size.height/2 - 20)
        tree!.zPosition = 2
        let growing:[SKTexture] = [
            SKTexture(imageNamed: "growing_plant2"),
            SKTexture(imageNamed: "growing_plant3"),
            SKTexture(imageNamed: "growing_plant4"),
            SKTexture(imageNamed: "growing_plant5"),
            SKTexture(imageNamed: "growing_plant6"),
            SKTexture(imageNamed: "growing_plant7"),
            SKTexture(imageNamed: "growing_plant1")
        ]
        self.addChild(tree!)
        let action = SKAction.repeatActionForever(SKAction.animateWithTextures(growing, timePerFrame: 0.25, resize: false, restore: false))
        tree!.runAction(action)
        
        let logo = SKSpriteNode(imageNamed: "little_family_logo")
        let lr = logo.size.width / logo.size.height
        logo.size.width = logo.size.width * scale
        logo.size.height = logo.size.width / lr
        
        logo.position = CGPointMake(self.size.width/2, tree!.position.y - (tree!.size.height / 2 + logo.size.height/2 + 20))
        logo.zPosition = 1
        self.addChild(logo)
        
        let quietToggle = AnimatedStateSprite(imageNamed: "quiet_mode_off")
        quietToggle.size.width = quietToggle.size.width * scale
        quietToggle.size.height = quietToggle.size.height * scale
        quietToggle.anchorPoint = CGPointZero
        quietToggle.position = CGPointMake(15, 15)
        quietToggle.zPosition = 4
        quietToggle.addTexture(1, texture: SKTexture(imageNamed: "quiet_mode_on"))
        quietToggle.addEvent(0, topic: LittleFamilyScene.TOPIC_TOGGLE_QUIET)
        quietToggle.addEvent(1, topic: LittleFamilyScene.TOPIC_TOGGLE_QUIET)
        quietToggle.userInteractionEnabled = true
        self.addChild(quietToggle)
        
        dataService = DataService.getInstance()
        
        let quietMode = dataService?.dbHelper.getProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET)
        if quietMode == nil || quietMode == "false" {
            introTune = SKAction.playSoundFileNamed("intro", waitForCompletion: true)
            runAction(introTune!)
        } else {
            quietToggle.nextState()
        }
        
        //dataService!.dbHelper.getRandomPersonWithMedia()
        
        EventHandler.getInstance().subscribe(LittleFamilyScene.TOPIC_TOGGLE_QUIET, listener: self)
    }
    
    override func willMoveFromView(view: SKView) {
        EventHandler.getInstance().unSubscribe(LittleFamilyScene.TOPIC_TOGGLE_QUIET, listener: self)
    }
    
    override func update(currentTime: NSTimeInterval) {
        if (startTime == nil) {
            startTime = currentTime
        }
        else {
            if (!launched && (currentTime - startTime! > 10)) {
                if dataService?.authenticating != nil && dataService?.authenticating == false {
                    if dataService?.dbHelper.getFirstPerson() != nil {
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
                        let rect = self.prepareDialogRect(CGFloat(600), height: CGFloat(600))
                        let subview = ChooseServiceView(frame: rect)
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
    
    var listenerIndex:Int?
    func onEvent(topic: String, data: NSObject?) {
        if topic == LittleFamilyScene.TOPIC_TOGGLE_QUIET {
            let quietMode = DataService.getInstance().dbHelper.getProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET)
            if quietMode == nil || quietMode == "false" {
                self.removeAllActions()
                DataService.getInstance().dbHelper.saveProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET, value: "true")
            } else {
                DataService.getInstance().dbHelper.saveProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET, value: "false")
            }
        }
    }
    
    func prepareDialogRect(width:CGFloat, height:CGFloat) -> CGRect {
        graybox = SKSpriteNode(color: UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.7), size: self.size)
        graybox!.userInteractionEnabled = true
        graybox!.zPosition = 100
        graybox!.position = CGPointMake(self.size.width/2, self.size.height/2)
        self.addChild(graybox!)
        
        tree!.hidden = true
        
        var w = width
        var h = height
        var x = (self.size.width - width) / 2
        var y = (self.size.height - height) / 2
        if w > self.size.width {
            w = self.size.width
            x = CGFloat(0)
            h = self.size.height
            y = CGFloat(0)
        } else {
            if h > self.size.height {
                h = self.size.height
                y = CGFloat(0)
            }
        }
        
        let rect = CGRect(x: x, y: y, width: w, height: h)
        return rect
    }
}