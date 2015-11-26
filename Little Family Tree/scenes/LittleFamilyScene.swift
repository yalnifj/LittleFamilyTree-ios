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
    
    func setupTopBar() {
        let tsie = CGSizeMake(self.size.width, 40)
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
}