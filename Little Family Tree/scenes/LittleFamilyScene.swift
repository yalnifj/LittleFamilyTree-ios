//
//  LittleFamilyScene.swift
//  Little Family Tree
//
//  Created by Melissa on 11/26/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class LittleFamilyScene: SKScene, EventListener, LoginCompleteListener {
    static var TOPIC_START_HOME = "start_home"
    static var TOPIC_START_CHOOSE = "start_choose"
	static var TOPIC_START_SETTINGS = "start_settings"
    var topBar:TopBar?
    var addingStars = false
    var starRect:CGRect?
    var starCount = 0
    var starsInRect = false
    var starDelayCount = 2
    var starDelay = 2
    var loadingDialog:SKSpriteNode?
    var selectedPerson:LittlePerson?
    var starContainer:SKNode?
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        EventHandler.getInstance().subscribe(LittleFamilyScene.TOPIC_START_HOME, listener: self)
        EventHandler.getInstance().subscribe(LittleFamilyScene.TOPIC_START_CHOOSE, listener: self)
		EventHandler.getInstance().subscribe(LittleFamilyScene.TOPIC_START_SETTINGS, listener: self)
    }
    
    override func willMoveFromView(view: SKView) {
        super.willMoveFromView(view)
        EventHandler.getInstance().unSubscribe(LittleFamilyScene.TOPIC_START_HOME, listener: self)
        EventHandler.getInstance().unSubscribe(LittleFamilyScene.TOPIC_START_CHOOSE, listener: self)
		EventHandler.getInstance().unSubscribe(LittleFamilyScene.TOPIC_START_SETTINGS, listener: self)
    }
    
    override func update(currentTime: NSTimeInterval) {
        if (starCount > 0) {
            if (starDelayCount <= 0) {
                starDelayCount = starDelay
                starCount--;
                for _ in 0..<6 {
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
                    let growAction = SKAction.scaleTo(1.0, duration: 1.0)
                    let shrinkAction = SKAction.scaleTo(0.0, duration: 1.0)
                    let doubleAction = SKAction.sequence([growAction, shrinkAction, SKAction.removeFromParent()])
                    star.runAction(doubleAction)
                    if self.starContainer == nil {
                        self.addChild(star)
                    } else {
                        self.starContainer?.addChild(star)
                    }
                }
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
    
    var listenerIndex:Int?
    func onEvent(topic: String, data: NSObject?) {
        if topic == LittleFamilyScene.TOPIC_START_HOME {
            showHomeScreen()
        }
        else if topic == LittleFamilyScene.TOPIC_START_CHOOSE {
            showChoosePlayerScreen()
        }
        else if topic == LittleFamilyScene.TOPIC_START_SETTINGS {
            showParentLogin()
        }
    }
    
    func showHomeScreen() {
        let transition = SKTransition.revealWithDirection(.Down, duration: 0.5)
        
        let nextScene = GameScene(size: scene!.size)
        nextScene.scaleMode = .AspectFill
        nextScene.selectedPerson = self.selectedPerson
        scene?.view?.presentScene(nextScene, transition: transition)
    }
    
    func showChoosePlayerScreen() {
        let transition = SKTransition.revealWithDirection(.Down, duration: 0.5)
        
        let nextScene = ChoosePlayerScene(size: scene!.size)
        nextScene.scaleMode = .AspectFill
        scene?.view?.presentScene(nextScene, transition: transition)
    }
    
    func showParentLogin() {
        let frame = CGRect(x: self.size.width/2 - 150, y: self.size.height/2 - 200, width: 300, height: 400)
        let subview = ParentLogin(frame: frame)
        subview.loginListener = self
        self.view?.addSubview(subview)
    }
    
    func LoginComplete() {
        let subview = SettingsView(frame: (self.view?.bounds)!)
        subview.selectedPerson = self.selectedPerson
        self.view?.addSubview(subview)
    }
    
    func playSuccessSound(wait:Double, onCompletion: () -> Void) {
        let levelUpAction = SKAction.waitForDuration(wait)
        runAction(levelUpAction) {
            let soundAction = SKAction.playSoundFileNamed("powerup_success", waitForCompletion: true);
            self.runAction(soundAction)
            onCompletion()
        }
    }
    
    func playFailSound(wait:Double, onCompletion: () -> Void) {
        let levelUpAction = SKAction.waitForDuration(wait)
        runAction(levelUpAction) {
            let soundAction = SKAction.playSoundFileNamed("beepboop", waitForCompletion: true);
            self.runAction(soundAction)
            onCompletion()
        }
    }
    
    func showStars(rect:CGRect, starsInRect: Bool, count: Int, container:SKNode?) {
        self.starRect = rect
        self.starsInRect = starsInRect
        self.starCount = count
        self.starContainer = container
    }
    
    func showLoadingDialog() {
        if loadingDialog == nil {
            loadingDialog = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeMake(270, 350))
            loadingDialog?.position = CGPointMake(self.size.width/2, self.size.height/2)
            loadingDialog?.zPosition = 1000
            
            let logo = SKSpriteNode(imageNamed: "loading")
            let ratio2 = logo.size.height / logo.size.width
            logo.size.width = (loadingDialog?.size.width)! - 20
            logo.size.height = ((loadingDialog?.size.width)! - 20) * ratio2
            logo.position = CGPointMake(10, ((loadingDialog?.size.height)! / -2) + logo.size.height)
            loadingDialog?.addChild(logo)
        
            let tree = SKSpriteNode(imageNamed: "growing_plant1")
            let ratio = tree.size.width / tree.size.height
            tree.size.height = (loadingDialog?.size.height)! / 1.8
            tree.size.width = tree.size.height * ratio
            tree.position = CGPointMake(0, logo.position.y + logo.size.height + tree.size.height / 2)
            
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
            
            self.addChild(loadingDialog!)
        } else {
            loadingDialog?.hidden = false
        }
    }
    
    func hideLoadingDialog() {
        if loadingDialog != nil {
            loadingDialog?.hidden = true
        }
    }
}