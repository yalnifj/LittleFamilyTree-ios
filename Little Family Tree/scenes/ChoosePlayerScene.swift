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
    static var TOPIC_SIGN_IN = "sign_in"
    var dataService:DataService?
    var graybox:SKSpriteNode?
    var titleBar:SKSpriteNode?
    var peopleSprites = [PersonNameSprite]()
    
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
        
        let titleSize = CGSizeMake(self.size.width, self.size.height / 10)
        titleBar = SKSpriteNode(color: UIColor.grayColor(), size: titleSize)
        titleBar?.position = CGPointMake(self.size.width/2, (self.size.height - titleBar!.size.height))
        self.addChild(titleBar!)
        
        let titleLabel = SKLabelNode(text: "Who is playing today?")
        titleLabel.fontSize = titleBar!.size.height
        titleLabel.fontColor = UIColor.blackColor()
        titleLabel.position = CGPointMake(0, 0)
        titleLabel.zPosition = 2
        titleBar!.addChild(titleLabel)
        
        let signInLabel = LabelEventSprite(text: "Sign-In")
        signInLabel.fontColor = UIColor.blueColor()
        signInLabel.fontSize = titleBar!.size.height / 2
        signInLabel.position = CGPointMake(titleBar!.size.width - signInLabel.frame.width, 0)
        signInLabel.zPosition = 2
        signInLabel.userInteractionEnabled = true
        signInLabel.topic = ChoosePlayerScene.TOPIC_SIGN_IN
        titleBar!.addChild(signInLabel)
        
        dataService = DataService.getInstance()
        loadPeople()
        EventHandler.getInstance().subscribe(ChoosePlayerScene.TOPIC_CHOOSE_PERSON, listener: self)
        EventHandler.getInstance().subscribe(ChoosePlayerScene.TOPIC_SIGN_IN, listener: self)
        
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
        EventHandler.getInstance().unSubscribe(ChoosePlayerScene.TOPIC_SIGN_IN, listener: self)
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
        else if topic == ChoosePlayerScene.TOPIC_SIGN_IN {
            if dataService?.serviceType == DataService.SERVICE_TYPE_FAMILYSEARCH {
                let subview = FamilySearchLogin(frame: (self.view?.bounds)!)
                subview.loginListener = self
                self.view!.addSubview(subview)
            } else if dataService?.serviceType == DataService.SERVICE_TYPE_PHPGEDVIEW {
                let subview = PGVLogin(frame: (self.view?.bounds)!)
                subview.loginListener = self
                self.view!.addSubview(subview)
            }
        }
    }
    
    func onClose() {
        self.filter = nil
        graybox!.removeFromParent()
        self.speak("Who is playing today?")
    }
    
    func loadPeople() {
        dataService?.getDefaultPerson(false, onCompletion: { person, err in
            self.dataService?.getFamilyMembers(person!, loadSpouse: false, onCompletion: { family, err in
                self.peopleSprites.removeAll()
                var width = (self.view!.bounds.width / 3) - 5
                if self.view!.bounds.width > self.view!.bounds.height {
                    width = (self.view!.bounds.height / 3) - 20
                }
                //print("w:\(view.bounds.width) h:\(view.bounds.height) width:\(width)")
                var x = CGFloat(5.0)
                var y = CGFloat(self.size.height - (width + self.titleBar!.size.height + 5))
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
                    self.peopleSprites.append(sprite)
                    
                    x += width + 5
                    if x > self.view!.bounds.width - width {
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
    }
    
    override func LoginComplete() {
       loadPeople()
    }
}
