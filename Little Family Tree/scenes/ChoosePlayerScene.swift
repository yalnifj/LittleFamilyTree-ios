//
//  SplashScene.swift
//  Little Family Tree
//
//  Created by Melissa on 10/7/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import SpriteKit
import CoreImage
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class ChoosePlayerScene: LittleFamilyScene, ParentsGuideCloseListener {
    static var TOPIC_CHOOSE_PERSON = "choose_person"
    static var TOPIC_SIGN_IN = "sign_in"
	static var TOPIC_PARENTS_GUIDE = "parents_guide"
    var dataService:DataService?
    var titleBar:SKSpriteNode?
    var peopleSprites = [PersonNameSprite]()
    var people = [LittlePerson]()
    
    override func didMove(to view: SKView) {
        self.size.width = view.bounds.width
        self.size.height = view.bounds.height
        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        let background = SKSpriteNode(imageNamed: "scratch_background")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.size.width = self.size.width
        background.size.height = self.size.height
        background.zPosition = 0
        self.addChild(background)
        
        let titleSize = CGSize(width: self.size.width, height: self.size.height / 15)
        titleBar = SKSpriteNode(color: UIColor.gray, size: titleSize)
        titleBar?.position = CGPoint(x: self.size.width/2, y: (self.size.height - titleBar!.size.height))
        self.addChild(titleBar!)
        
        let titleBackground = SKSpriteNode(color: UIColor.white, size: titleSize)
        titleBackground.zPosition = 1
        titleBackground.position = CGPoint(x: 0,y: titleSize.height / 2)
        titleBar!.addChild(titleBackground)
        
        let titleLabel = SKLabelNode(text: "Who is playing today?")
        titleLabel.fontSize = titleBar!.size.height * 0.6
        if titleLabel.frame.size.width > titleBar!.size.width * 0.60 {
            titleLabel.fontSize = titleLabel.fontSize * 0.75
        }
        titleLabel.fontColor = UIColor.black
        titleLabel.position = CGPoint(x: 0, y: titleLabel.fontSize / 2)
        titleLabel.zPosition = 2
        titleBar!.addChild(titleLabel)
        
        let signInLabel = LabelEventSprite(text: "Sign In")
        signInLabel.fontColor = UIColor.blue
        signInLabel.fontSize = titleLabel.fontSize / 1.6
        signInLabel.position = CGPoint(x: (titleSize.width / 2) - (5 + signInLabel.frame.size.width / 2), y: signInLabel.fontSize)
        signInLabel.zPosition = 3
        signInLabel.isUserInteractionEnabled = true
        signInLabel.topic = ChoosePlayerScene.TOPIC_SIGN_IN
        titleBar!.addChild(signInLabel)
		
		let parentsGuideLabel = LabelEventSprite(text: "Parent's Guide")
        parentsGuideLabel.fontColor = UIColor.blue
        parentsGuideLabel.fontSize = titleLabel.fontSize / 1.6
        parentsGuideLabel.position = CGPoint(x: (5 + parentsGuideLabel.frame.size.width / 2) - (titleSize.width / 2), y: parentsGuideLabel.fontSize)
        parentsGuideLabel.zPosition = 3
        parentsGuideLabel.isUserInteractionEnabled = true
        parentsGuideLabel.topic = ChoosePlayerScene.TOPIC_PARENTS_GUIDE
        titleBar!.addChild(parentsGuideLabel)
        
        dataService = DataService.getInstance()
        loadPeople()
        EventHandler.getInstance().subscribe(ChoosePlayerScene.TOPIC_CHOOSE_PERSON, listener: self)
        EventHandler.getInstance().subscribe(ChoosePlayerScene.TOPIC_SIGN_IN, listener: self)
		EventHandler.getInstance().subscribe(ChoosePlayerScene.TOPIC_PARENTS_GUIDE, listener: self)
        
        let showGuide = dataService!.dbHelper.getProperty(DataService.PROPERTY_SHOW_PARENTS_GUIDE)
        if showGuide == nil || showGuide! == "true" {
            self.showParentsGuide(self, skipGate: true)
        }
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        EventHandler.getInstance().unSubscribe(ChoosePlayerScene.TOPIC_CHOOSE_PERSON, listener: self)
        EventHandler.getInstance().unSubscribe(ChoosePlayerScene.TOPIC_SIGN_IN, listener: self)
		EventHandler.getInstance().unSubscribe(ChoosePlayerScene.TOPIC_PARENTS_GUIDE, listener: self)
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
    }

    override func onEvent(_ topic: String, data: NSObject?) {
        if topic == ChoosePlayerScene.TOPIC_CHOOSE_PERSON {
            let person = data as! LittlePerson?
            let transition = SKTransition.reveal(with: .down, duration: 0.5)
            
            let nextScene = GameScene(size: scene!.size)
            nextScene.scaleMode = .aspectFill
            nextScene.chosenPlayer = person
            nextScene.selectedPerson = person
            scene?.view?.presentScene(nextScene, transition: transition)
        }
        else if topic == ChoosePlayerScene.TOPIC_SIGN_IN {
            if dataService?.serviceType as String? == DataService.SERVICE_TYPE_FAMILYSEARCH {
                let subview = FamilySearchLogin(frame: (self.view?.bounds)!)
                subview.loginListener = self
                self.view!.addSubview(subview)
            } else if dataService?.serviceType as String? == DataService.SERVICE_TYPE_PHPGEDVIEW {
                let subview = PGVLogin(frame: (self.view?.bounds)!)
                subview.loginListener = self
                self.view!.addSubview(subview)
            }
        } else if topic == ChoosePlayerScene.TOPIC_PARENTS_GUIDE {
			self.showParentsGuide(self, skipGate: false)
		}
    }
    
    func onClose() {
        self.hideParentsGuide()
		self.checkMedia()
        self.speak("Who is playing today?")
    }
    
    func loadPeople() {
        self.people = [LittlePerson]()
        let queue = DispatchQueue.global()
        let group = DispatchGroup()
        group.enter()
        var haschildren = false
        dataService?.getDefaultPerson(false, onCompletion: { person, err in
            if person != nil {
                self.people.append(person!)
				let showStepChildren = self.dataService!.dbHelper.getProperty(DataService.PROPERTY_SHOW_STEP_CHILDREN)
                group.enter()
                self.dataService?.getSpouses(person!, onCompletion: { spouses, err in
                    if spouses != nil {
                        for s in spouses! {
                            if !self.people.contains(s) {
                                self.people.append(s)
								
								if showStepChildren == nil || showStepChildren == "true" {
                                    group.enter()
									self.dataService?.getChildren(s, onCompletion: {children, err in
										if children != nil {
											for c in children! {
												if !self.people.contains(c) {
													self.people.append(c)
                                                    haschildren = true
												}
											}
										}
                                        group.leave()
									})
								}
                            }
                        }
                    }
                    
                    group.enter()
                    self.dataService?.getChildren(person!, onCompletion: {children, err in
                        if children != nil {
                            for c in children! {
                                if !self.people.contains(c) {
                                    self.people.append(c)
                                    haschildren = true
                                }
                            }
                        }
                        
                        group.enter()
                        self.dataService?.getParents(person!, onCompletion: {parents, err in
                            if parents != nil {
                                for p in parents! {
                                    if !self.people.contains(p) {
                                        self.people.append(p)
                                    }
                                }
                                
                                if !haschildren {
                                    if parents!.count > 1 {
                                        group.enter()
                                        self.dataService?.getChildrenForCouple(parents![0], person2: parents![1], onCompletion: {grandchildren, err in
                                            if grandchildren != nil {
                                                for gc in grandchildren! {
                                                    if !self.people.contains(gc) {
                                                        self.people.append(gc)
                                                    }
                                                }
                                            }
                                            self.addSprites()
                                            group.leave()
                                        })
                                    } else if parents!.count > 0 {
                                        group.enter()
                                        self.dataService?.getChildren(parents![0], onCompletion: {grandchildren, err in
                                            if grandchildren != nil {
                                                for gc in grandchildren! {
                                                    if !self.people.contains(gc) {
                                                        self.people.append(gc)
                                                    }
                                                }
                                            }
                                            self.addSprites()
                                            group.leave()
                                        })
                                    } else {
                                        self.addSprites()
                                    }
                                } else {
                                    // add grandchildren
                                    for c in children! {
                                        group.enter()
                                        self.dataService?.getChildren(c, onCompletion: {grandchildren, err in
                                            if grandchildren != nil {
                                                for gc in grandchildren! {
                                                    if !self.people.contains(gc) {
                                                        self.people.append(gc)
                                                    }
                                                }
                                            }
                                            group.leave()
                                        })
                                    }
                                }
                            } else {
                                self.addSprites()
                            }
                            group.leave()
                        })
                        group.leave()
                    })
                    group.leave()
                })
            }
            group.leave()
        })
        group.notify(queue: queue) {
            self.addSprites()
        }
    }
    
    func addSprites() {
        SyncQ.getInstance().start()
        for s in self.peopleSprites {
            s.removeFromParent()
        }
        self.peopleSprites.removeAll()
        var width = min(self.view!.bounds.width, self.view!.bounds.height)
        var cols = CGFloat(3)
        width = (self.view!.bounds.width / cols)
        if self.people.count > 12 || (CGFloat(self.people.count) / cols) * width > self.view!.bounds.height {
            cols = CGFloat(4)
        }
        width = (self.view!.bounds.width / cols)
        if self.people.count > 16 || (CGFloat(self.people.count) / cols) * width > self.view!.bounds.height  {
            cols = CGFloat(5)
        }
        width = (self.view!.bounds.width / cols)
        
        //-- sort the people
        self.people.sort(by: { $0.age < $1.age })
        
        //print("w:\(view.bounds.width) h:\(view.bounds.height) width:\(width)")
        var x = CGFloat(0.0)
        var y = CGFloat(self.size.height - (width + self.titleBar!.size.height - 10))
        for p in self.people {
            print("\(p.name!) (\(x),\(y))")
            let sprite = PersonNameSprite()
            sprite.isUserInteractionEnabled = true
            sprite.position = CGPoint(x: x, y: y)
            sprite.size.width = width
            sprite.size.height = width
            sprite.person = p
            sprite.topic = ChoosePlayerScene.TOPIC_CHOOSE_PERSON
            self.addChild(sprite)
            self.peopleSprites.append(sprite)
            
            x += width - 10
            if x > self.view!.bounds.width - width {
                x = CGFloat(5)
                y -= width - 20
            }
        }
        SyncQ.getInstance().start()
        let showGuide = self.dataService!.dbHelper.getProperty(DataService.PROPERTY_SHOW_PARENTS_GUIDE)
        if showGuide != nil && showGuide! != "true" {
            self.checkMedia()
            self.speak("Who is playing today?")
        }
    }
	
	func checkMedia() {
		if DataService.getInstance().dbHelper.getMediaCount() < 5 {
			showSimpleDialog("Add more pictures", message:"There are not many pictures on your online family tree.  The game is more fun with more pictures.  Please go to your online family tree and upload more photos.");
		}
	}
    
    override func LoginComplete() {
        if loginForParentsGuide {
            self.showParentsGuide(pgListener!, skipGate: true)
            loginForParentsGuide = false
        } else {
            loadPeople()
        }
    }
}
