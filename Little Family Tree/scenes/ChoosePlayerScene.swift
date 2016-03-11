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
	static var TOPIC_PARENTS_GUIDE = "parents_guide"
    var dataService:DataService?
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
        
        let titleSize = CGSizeMake(self.size.width, self.size.height / 15)
        titleBar = SKSpriteNode(color: UIColor.grayColor(), size: titleSize)
        titleBar?.position = CGPointMake(self.size.width/2, (self.size.height - titleBar!.size.height))
        self.addChild(titleBar!)
        
        let titleBackground = SKSpriteNode(color: UIColor.whiteColor(), size: titleSize)
        titleBackground.zPosition = 1
        titleBackground.position = CGPointMake(0,titleSize.height / 2)
        titleBar!.addChild(titleBackground)
        
        let titleLabel = SKLabelNode(text: "Who is playing today?")
        titleLabel.fontSize = titleBar!.size.height * 0.7
        if titleLabel.frame.size.width > titleBar!.size.width * 0.60 {
            titleLabel.fontSize = titleLabel.fontSize * 0.75
        }
        titleLabel.fontColor = UIColor.blackColor()
        titleLabel.position = CGPointMake(0, titleLabel.fontSize / 2)
        titleLabel.zPosition = 2
        titleBar!.addChild(titleLabel)
        
        let signInLabel = LabelEventSprite(text: "Sign In")
        signInLabel.fontColor = UIColor.blueColor()
        signInLabel.fontSize = titleLabel.fontSize / 1.6
        signInLabel.position = CGPointMake((titleSize.width / 2) - (5 + signInLabel.frame.size.width / 2), signInLabel.fontSize)
        signInLabel.zPosition = 3
        signInLabel.userInteractionEnabled = true
        signInLabel.topic = ChoosePlayerScene.TOPIC_SIGN_IN
        titleBar!.addChild(signInLabel)
		
		let parentsGuideLabel = LabelEventSprite(text: "Parent's Guide")
        parentsGuideLabel.fontColor = UIColor.blueColor()
        parentsGuideLabel.fontSize = titleLabel.fontSize / 1.6
        parentsGuideLabel.position = CGPointMake((5 + parentsGuideLabel.frame.size.width / 2) - (titleSize.width / 2), parentsGuideLabel.fontSize)
        parentsGuideLabel.zPosition = 3
        parentsGuideLabel.userInteractionEnabled = true
        parentsGuideLabel.topic = ChoosePlayerScene.TOPIC_PARENTS_GUIDE
        titleBar!.addChild(parentsGuideLabel)
        
        dataService = DataService.getInstance()
        loadPeople()
        EventHandler.getInstance().subscribe(ChoosePlayerScene.TOPIC_CHOOSE_PERSON, listener: self)
        EventHandler.getInstance().subscribe(ChoosePlayerScene.TOPIC_SIGN_IN, listener: self)
		EventHandler.getInstance().subscribe(ChoosePlayerScene.TOPIC_PARENTS_GUIDE, listener: self)
        
        let showGuide = dataService!.dbHelper.getProperty(DataService.PROPERTY_SHOW_PARENTS_GUIDE)
        if showGuide == nil || showGuide! == "true" {
            self.showParentsGuide(self)
        }
    }
    
    override func willMoveFromView(view: SKView) {
        super.willMoveFromView(view)
        EventHandler.getInstance().unSubscribe(ChoosePlayerScene.TOPIC_CHOOSE_PERSON, listener: self)
        EventHandler.getInstance().unSubscribe(ChoosePlayerScene.TOPIC_SIGN_IN, listener: self)
		EventHandler.getInstance().unSubscribe(ChoosePlayerScene.TOPIC_PARENTS_GUIDE, listener: self)
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
        } else if topic == ChoosePlayerScene.TOPIC_PARENTS_GUIDE {
			self.showParentsGuide(self)
		}
    }
    
    func onClose() {
        self.hideParentsGuide()
		self.checkMedia()
        self.speak("Who is playing today?")
    }
    
    func loadPeople() {
        dataService?.getDefaultPerson(false, onCompletion: { person, err in
            self.dataService?.getFamilyMembers(person!, loadSpouse: false, onCompletion: { family, err in
                self.peopleSprites.removeAll()
                var width = min(self.view!.bounds.width, self.view!.bounds.height)
				var cols = CGFloat(3)
				if family?.count > 9 {
					cols = CGFloat(4)
				}
				if family?.count > 16 {
					cols = CGFloat(5)
				}
				width = (self.view!.bounds.width / cols) - 10

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
					self.checkMedia()
                    self.speak("Who is playing today?")
                }
            })
        })
    }
	
	func checkMedia() {
		if dataService.dbHelper.getMediaCount() < 5 {
			showSimpleDialog("Add more pictures", message:"There are not many pictures on your online family tree.  The game is more fun with more pictures.  Please go to your online family tree and upload more photos.");
		}
	}
    
    override func LoginComplete() {
       loadPeople()
    }
}
