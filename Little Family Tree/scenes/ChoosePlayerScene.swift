//
//  SplashScene.swift
//  Little Family Tree
//
//  Created by Melissa on 10/7/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import SpriteKit
import CoreImage

class ChoosePlayerScene: LittleFamilyScene, ParentsGuideCloseListener {
    static var TOPIC_CHOOSE_PERSON = "choose_person"
    var dataService:DataService?
    var graybox:SKSpriteNode?
    
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
                    width = (view.bounds.height / 3) - 20
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
                let showGuide = self.dataService!.dbHelper.getProperty(DataService.PROPERTY_SHOW_PARENTS_GUIDE)
                if showGuide != nil && showGuide! != "true" {
                    self.speak("Who is playing today?")
                }
            })
        })
        EventHandler.getInstance().subscribe(ChoosePlayerScene.TOPIC_CHOOSE_PERSON, listener: self)
        
        let showGuide = dataService!.dbHelper.getProperty(DataService.PROPERTY_SHOW_PARENTS_GUIDE)
        if showGuide == nil || showGuide! == "true" {
            
            //let filter = CIFilter(name: "CIGaussianBlur")
            //filter?.setValue(15, forKey: kCIInputRadiusKey)
            //self.shouldEnableEffects = true
            //self.filter = filter
            
            graybox = SKSpriteNode(color: UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.7), size: self.size)
            graybox!.userInteractionEnabled = true
            graybox!.zPosition = 100
            graybox!.position = CGPointMake(self.size.width/2, self.size.height/2)
            self.addChild(graybox!)
            
            var width = CGFloat(500)
            var height = CGFloat(400)
            var x = (self.size.width - width) / 2
            var y = (self.size.height - height) / 2
            if width > self.size.width {
                width = self.size.width
                x = CGFloat(0)
                height = self.size.height
                y = CGFloat(0)
            } else {
                if height > self.size.height {
                    height = self.size.height
                    y = CGFloat(0)
                }
            }
            
            let rect = CGRect(x: x, y: y, width: width, height: height)
            let subview = ParentsGuide(frame: rect)
            subview.listener = self
            self.view?.addSubview(subview)
            
            
        }
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
            nextScene.chosenPlayer = person
            nextScene.selectedPerson = person
            scene?.view?.presentScene(nextScene, transition: transition)
        }
    }
    
    func onClose() {
        self.filter = nil
        graybox!.removeFromParent()
        self.speak("Who is playing today?")
    }
}
