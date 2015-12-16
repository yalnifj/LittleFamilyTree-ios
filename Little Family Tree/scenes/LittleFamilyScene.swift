//
//  LittleFamilyScene.swift
//  Little Family Tree
//
//  Created by Melissa on 11/26/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class LittleFamilyScene: SKScene, EventListener {
    static var TOPIC_START_HOME = "start_home"
    static var TOPIC_START_CHOOSE = "start_choose"
    var selectedPerson:LittlePerson?
    var topBar:TopBar?
    var addingStars = false
    var starRect:CGRect?
    var starCount = 0
    var starsInRect = false
    var starDelayCount = 1
    var starDelay = 1
    var loadingDialog:SKSpriteNode?
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        EventHandler.getInstance().subscribe(LittleFamilyScene.TOPIC_START_HOME, listener: self)
        EventHandler.getInstance().subscribe(LittleFamilyScene.TOPIC_START_CHOOSE, listener: self)
    }
    
    override func willMoveFromView(view: SKView) {
        super.willMoveFromView(view)
        EventHandler.getInstance().unSubscribe(LittleFamilyScene.TOPIC_START_HOME, listener: self)
        EventHandler.getInstance().unSubscribe(LittleFamilyScene.TOPIC_START_CHOOSE, listener: self)
    }
    
    override func update(currentTime: NSTimeInterval) {
        if (starCount > 0) {
            if (starDelayCount <= 0) {
                starDelayCount = starDelay
                starCount--;
                if (starRect != nil) {
                    let star = SKSpriteNode(imageNamed: "star1")
                    var x = CGFloat(0)
                    var y = CGFloat(0)
                    if (starsInRect) {
                        x = (starRect?.origin.x)! + CGFloat(arc4random_uniform(UInt32((starRect?.width)!)))
                        y = (starRect?.origin.y)! + CGFloat(arc4random_uniform(UInt32((starRect?.height)!)))
                    } else {
                        let side = arc4random_uniform(4)
                        switch (side) {
                        case 0:
                            x = (starRect?.origin.x)! + CGFloat(arc4random_uniform(UInt32((starRect?.width)!)))
                            y = (starRect?.origin.y)! + CGFloat(arc4random_uniform(UInt32(star.size.height)))
                            break
                        case 1:
                            x = (starRect?.origin.x)! + (starRect?.width)! - CGFloat(arc4random_uniform(UInt32(star.size.width)))
                            y = (starRect?.origin.y)! + CGFloat(arc4random_uniform(UInt32((starRect?.height)!)))
                            break
                        case 2:
                            x = (starRect?.origin.x)! + CGFloat(arc4random_uniform(UInt32((starRect?.width)!)))
                            y = (starRect?.origin.y)! + (starRect?.height)! - CGFloat(arc4random_uniform(UInt32(star.size.height)))
                            break
                        default:
                            x = (starRect?.origin.x)! + CGFloat(arc4random_uniform(UInt32(star.size.width)))
                            y = (starRect?.origin.y)! + CGFloat(arc4random_uniform(UInt32((starRect?.height)!)))
                            break
                        }
                    }
                    star.position.x = x
                    star.position.y = y
                    star.zPosition = 100
                    star.setScale(0.1)
                    let growAction = SKAction.scaleTo(1.0, duration: 0.5)
                    let shrinkAction = SKAction.scaleTo(0.0, duration: 0.5)
                    let doubleAction = SKAction.sequence([growAction, shrinkAction, SKAction.removeFromParent()])
                    star.runAction(doubleAction)
                    self.addChild(star)
                }
            } else {
                starDelayCount--;
            }
        }

    }
    
    func setupTopBar() {
        let tsie = CGSizeMake(self.size.width, self.size.height*0.05)
        topBar = TopBar(color: UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.7), size: tsie)
        topBar!.position = CGPointMake(self.size.width/2, self.size.height-(topBar!.size.height / 2))
        topBar!.person = selectedPerson
        topBar!.homeTexture = SKTexture(imageNamed: "home")
        topBar!.userInteractionEnabled = true
        topBar!.zPosition = 100
        self.addChild(topBar!)
    }
    
    var index:Int?
    func onEvent(topic: String, data: NSObject?) {
        if topic == LittleFamilyScene.TOPIC_START_HOME {
            showHomeScreen()
        }
        else if topic == LittleFamilyScene.TOPIC_START_CHOOSE {
            showChoosePlayerScreen()
        }
    }
    
    func showHomeScreen() {
        let transition = SKTransition.revealWithDirection(.Down, duration: 0.5)
        
        let nextScene = GameScene(size: scene!.size)
        nextScene.scaleMode = .AspectFill
        nextScene.selectedPerson = selectedPerson
        scene?.view?.presentScene(nextScene, transition: transition)
    }
    
    func showChoosePlayerScreen() {
        let transition = SKTransition.revealWithDirection(.Down, duration: 0.5)
        
        let nextScene = ChoosePlayerScene(size: scene!.size)
        nextScene.scaleMode = .AspectFill
        scene?.view?.presentScene(nextScene, transition: transition)
    }
    
    func playSuccessSound(wait:Double, onCompletion: () -> Void) {
        let levelUpAction = SKAction.waitForDuration(wait)
        runAction(levelUpAction) {
            let soundAction = SKAction.playSoundFileNamed("powerup_success", waitForCompletion: true);
            self.runAction(soundAction)
            onCompletion()
        }
    }
    
    func showStars(rect:CGRect, starsInRect: Bool, count: Int) {
        self.starRect = rect
        self.starsInRect = starsInRect
        self.starCount = count
    }
    
    func showLoadingDialog() {
        if loadingDialog == nil {
            loadingDialog = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeMake(200, 300))
            loadingDialog?.position = CGPointMake(self.size.width/2, self.size.height/2)
            loadingDialog?.zPosition = 1000
            
            let tree = SKSpriteNode(imageNamed: "growing_plant1")
            tree.position = CGPointMake(20, 100)
            let growing:[SKTexture] = [
                SKTexture(imageNamed: "growing_plant2"),
                SKTexture(imageNamed: "growing_plant3"),
                SKTexture(imageNamed: "growing_plant4"),
                SKTexture(imageNamed: "growing_plant5"),
                SKTexture(imageNamed: "growing_plant6"),
                SKTexture(imageNamed: "growing_plant7"),
                SKTexture(imageNamed: "growing_plant1")
            ]
            loadingDialog?.addChild(tree)
            let action = SKAction.repeatActionForever(SKAction.animateWithTextures(growing, timePerFrame: 0.25, resize: false, restore: false))
            tree.runAction(action)
            
            let logo = SKSpriteNode(imageNamed: "loading")
            logo.position = CGPointMake(10, 10)
            loadingDialog?.addChild(logo)
            
            self.addChild(loadingDialog!)
        }
    }
    
    func hideLoadingDialog() {
        if loadingDialog != nil {
            loadingDialog?.removeFromParent()
            loadingDialog = nil
        }
    }
}