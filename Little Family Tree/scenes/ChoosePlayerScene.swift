//
//  SplashScene.swift
//  Little Family Tree
//
//  Created by Melissa on 10/7/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import SpriteKit

class ChoosePlayerScene: LittleFamilyScene {
    static var TOPIC_CHOOSE_PERSON = "choose_person"
    var dataService:DataService?
    
    override func didMoveToView(view: SKView) {
        self.size.width = view.bounds.width
        self.size.height = view.bounds.height
        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        let background = SKSpriteNode(imageNamed: "scratch_background")
        background.position = CGPointMake(self.size.width/2, self.size.height/2)
        background.size.width = self.size.width
        background.size.height = self.size.height
        background.zPosition = 0
        self.addChild(background)
        
        let titleSize = CGSizeMake(self.size.width, 30)
        let titleBar = SKSpriteNode(color: UIColor.grayColor(), size: titleSize)
        titleBar.position = CGPointMake(self.size.width/2, (self.size.height - titleBar.size.height/2))
        
        let titleLabel = SKLabelNode(text: "Who is playing today?")
        titleLabel.fontSize = 20
        titleLabel.fontColor = UIColor.blackColor()
        titleLabel.position = CGPointMake(0, -8)
        titleLabel.zPosition = 2
        titleBar.addChild(titleLabel)

        self.addChild(titleBar)
        
        dataService = DataService.getInstance()
        dataService?.getDefaultPerson(false, onCompletion: { person, err in
            self.dataService?.getFamilyMembers(person!, loadSpouse: false, onCompletion: { family, err in
                var width = (view.bounds.width / 3) - 5
                if view.bounds.width > view.bounds.height {
                    width = (view.bounds.height / 3) - 5
                }
                print("w:\(view.bounds.width) h:\(view.bounds.height) width:\(width)")
                var x = CGFloat(5.0)
                var y = CGFloat(self.size.height - (width + titleBar.size.height + 5))
                for p in family! {
                    print("\(p.name!) (\(x),\(y))")
                    let sprite = PersonNameSprite()
                    sprite.userInteractionEnabled = true
                    sprite.position = CGPointMake(x, y)
                    sprite.size.width = width
                    sprite.size.height = width
                    sprite.person = p
                    sprite.topic = ChoosePlayerScene.TOPIC_CHOOSE_PERSON
                    self.addChild(sprite)
                    
                    x += width + 5
                    if x > view.bounds.width - width {
                        x = CGFloat(5)
                        y -= width + 5
                    }
                }
                self.speak("Who is playing today?")
            })
        })
        EventHandler.getInstance().subscribe(ChoosePlayerScene.TOPIC_CHOOSE_PERSON, listener: self)
    }
    
    override func willMoveFromView(view: SKView) {
        super.willMoveFromView(view)
        EventHandler.getInstance().unSubscribe(ChoosePlayerScene.TOPIC_CHOOSE_PERSON, listener: self)
    }
    
    override func update(currentTime: NSTimeInterval) {
        super.update(currentTime)
    }

    override func onEvent(topic: String, data: NSObject?) {
        if topic == ChoosePlayerScene.TOPIC_CHOOSE_PERSON {
            let person = data as! LittlePerson?
            let transition = SKTransition.revealWithDirection(.Down, duration: 0.5)
            
            let nextScene = GameScene(size: scene!.size)
            nextScene.scaleMode = .AspectFill
            nextScene.selectedPerson = person
            scene?.view?.presentScene(nextScene, transition: transition)
        }
    }
}
