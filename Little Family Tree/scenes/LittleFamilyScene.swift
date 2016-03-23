//
//  LittleFamilyScene.swift
//  Little Family Tree
//
//  Created by Melissa on 11/26/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class LittleFamilyScene: SKScene, EventListener, LoginCompleteListener, SimpleDialogCloseListener {
    static var TOPIC_START_HOME = "start_home"
    static var TOPIC_START_CHOOSE = "start_choose"
	static var TOPIC_START_SETTINGS = "start_settings"
    static var TOPIC_TOGGLE_QUIET = "toggle_quiet"
    var topBar:TopBar?
    var addingStars = false
    var starRect:CGRect?
    var starCount = 0
    var starsInRect = false
    var starDelayCount = 2
    var starDelay = 2
    var loadingDialog:SKSpriteNode?
    var selectedPerson:LittlePerson?
    var chosenPlayer:LittlePerson?
    var starContainer:SKNode?
    var previousTopic:String?
    var graybox:SKSpriteNode?
    var toasts = [SKSpriteNode]()
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        EventHandler.getInstance().subscribe(LittleFamilyScene.TOPIC_START_HOME, listener: self)
        EventHandler.getInstance().subscribe(LittleFamilyScene.TOPIC_START_CHOOSE, listener: self)
		EventHandler.getInstance().subscribe(LittleFamilyScene.TOPIC_START_SETTINGS, listener: self)
        EventHandler.getInstance().subscribe(LittleFamilyScene.TOPIC_TOGGLE_QUIET, listener: self)
    }
    
    override func willMoveFromView(view: SKView) {
        super.willMoveFromView(view)
        EventHandler.getInstance().unSubscribe(LittleFamilyScene.TOPIC_START_HOME, listener: self)
        EventHandler.getInstance().unSubscribe(LittleFamilyScene.TOPIC_START_CHOOSE, listener: self)
		EventHandler.getInstance().unSubscribe(LittleFamilyScene.TOPIC_START_SETTINGS, listener: self)
        EventHandler.getInstance().unSubscribe(LittleFamilyScene.TOPIC_TOGGLE_QUIET, listener: self)
    }
    
    override func update(currentTime: NSTimeInterval) {
        if (starCount > 0) {
            if (starDelayCount <= 0) {
                starDelayCount = starDelay
                starCount -= 1;
                for _ in 0..<4 {
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
                    let growAction = SKAction.scaleTo(1.0, duration: 1.5)
                    let shrinkAction = SKAction.scaleTo(0.0, duration: 1.5)
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
            if previousTopic == nil || previousTopic == LittleFamilyScene.TOPIC_START_HOME {
                showHomeScreen()
            } else {
                onEvent(previousTopic!, data: data)
            }
        }
        else if topic == LittleFamilyScene.TOPIC_START_CHOOSE {
            showChoosePlayerScreen()
        }
        else if topic == LittleFamilyScene.TOPIC_START_SETTINGS {
            showParentLogin()
        }
        else if topic == LittleFamilyScene.TOPIC_TOGGLE_QUIET {
            toggleQuietMode()
        } else if topic == GameScene.TOPIC_START_MATCH {
            self.showMatchGame(nil, previousTopic: nil)
        }
        else if topic == GameScene.TOPIC_START_DRESSUP {
            self.showHeritageCalculatorGame(nil, previousTopic: nil)
        }
        else if topic == GameScene.TOPIC_START_PUZZLE {
            self.showPuzzleGame(nil, previousTopic: nil)
        }
        else if topic == GameScene.TOPIC_START_SCRATCH {
            self.showScratchGame(nil, previousTopic: nil)
        }
        else if topic == GameScene.TOPIC_START_COLORING {
            self.showColoringGame(nil, previousTopic: nil)
        }
        else if topic == GameScene.TOPIC_START_TREE {
            self.showTree(nil, previousTopic: nil)
        }
        else if topic == GameScene.TOPIC_START_BUBBLES {
            self.showBubbleGame(nil, previousTopic: nil)
        }
        else if topic == GameScene.TOPIC_START_SONG {
            self.showSongGame(nil, previousTopic: nil)
        }
    }
    
    func showHomeScreen() {
        let transition = SKTransition.revealWithDirection(.Down, duration: 0.7)
        let nextScene = GameScene(size: scene!.size)
        nextScene.scaleMode = .AspectFill
        if self.chosenPlayer != nil {
            nextScene.selectedPerson = self.chosenPlayer
        } else {
            nextScene.selectedPerson = self.selectedPerson
        }
        scene?.view?.presentScene(nextScene, transition: transition)
    }
    
    func showChoosePlayerScreen() {
        let transition = SKTransition.revealWithDirection(.Down, duration: 0.7)
        let nextScene = ChoosePlayerScene(size: scene!.size)
        nextScene.scaleMode = .AspectFill
        scene?.view?.presentScene(nextScene, transition: transition)
    }
	
    func showMatchGame(person:LittlePerson?, previousTopic:String?) {
		let transition = SKTransition.revealWithDirection(.Down, duration: 0.7)
		let nextScene = MatchGameScene(size: scene!.size)
        nextScene.previousTopic = previousTopic
        nextScene.chosenPlayer = self.chosenPlayer
		nextScene.scaleMode = .AspectFill
        if person != nil {
            nextScene.selectedPerson = person
        } else {
            nextScene.selectedPerson = selectedPerson
        }
		scene?.view?.presentScene(nextScene, transition: transition)
	}
	
	func showHeritageCalculatorGame(person:LittlePerson?, previousTopic:String?) {
		let transition = SKTransition.revealWithDirection(.Down, duration: 0.7)
        let nextScene = ChooseCultureScene(size: scene!.size)
        nextScene.previousTopic = previousTopic
        nextScene.chosenPlayer = self.chosenPlayer
		nextScene.scaleMode = .AspectFill
        if person != nil {
            nextScene.selectedPerson = person
        } else {
            nextScene.selectedPerson = selectedPerson
        }
		scene?.view?.presentScene(nextScene, transition: transition)
	}
	
	func showDressupGame(dollConfig:DollConfig, person:LittlePerson?, previousTopic:String?) {
		let transition = SKTransition.revealWithDirection(.Down, duration: 0.7)
		let nextScene = DressUpScene(size: scene!.size)
        nextScene.previousTopic = previousTopic
        nextScene.chosenPlayer = self.chosenPlayer
		nextScene.scaleMode = .AspectFill
        if person != nil {
            nextScene.selectedPerson = person
        } else {
            nextScene.selectedPerson = selectedPerson
        }
		nextScene.dollConfig = dollConfig
		scene?.view?.presentScene(nextScene, transition: transition)
	}
	
	func showPuzzleGame(person:LittlePerson?, previousTopic:String?) {
		let transition = SKTransition.revealWithDirection(.Down, duration: 0.7)
		let nextScene = PuzzleScene(size: scene!.size)
        nextScene.previousTopic = previousTopic
        nextScene.chosenPlayer = self.chosenPlayer
		nextScene.scaleMode = .AspectFill
        if person != nil {
            nextScene.selectedPerson = person
        } else {
            nextScene.selectedPerson = selectedPerson
        }
		scene?.view?.presentScene(nextScene, transition: transition)
	}
	
	func showScratchGame(person:LittlePerson?, previousTopic:String?) {
		let transition = SKTransition.revealWithDirection(.Down, duration: 0.7)
        
		let nextScene = ScratchScene(size: scene!.size)
        nextScene.previousTopic = previousTopic
        nextScene.chosenPlayer = self.chosenPlayer
		nextScene.scaleMode = .AspectFill
        if person != nil {
            nextScene.selectedPerson = person
        } else {
            nextScene.selectedPerson = selectedPerson
        }
		scene?.view?.presentScene(nextScene, transition: transition)
	}
	
    func showColoringGame(person:LittlePerson?, previousTopic:String?) {
		let transition = SKTransition.revealWithDirection(.Down, duration: 0.7)
		let nextScene = ColoringScene(size: scene!.size)
        nextScene.previousTopic = previousTopic
        nextScene.chosenPlayer = self.chosenPlayer
		nextScene.scaleMode = .AspectFill
        if person != nil {
            nextScene.selectedPerson = person
        } else {
            nextScene.selectedPerson = selectedPerson
        }
		scene?.view?.presentScene(nextScene, transition: transition)
	}
	
	func showTree(person:LittlePerson?, previousTopic:String?) {
		let transition = SKTransition.revealWithDirection(.Down, duration: 0.7)
		let nextScene = TreeScene(size: scene!.size)
        nextScene.previousTopic = previousTopic
        nextScene.chosenPlayer = self.chosenPlayer
		nextScene.scaleMode = .AspectFill
        if person != nil {
            nextScene.selectedPerson = person
        } else {
            if self.chosenPlayer != nil {
                nextScene.selectedPerson = self.chosenPlayer
            } else {
                nextScene.selectedPerson = self.selectedPerson
            }
        }
		scene?.view?.presentScene(nextScene, transition: transition)
	}
	
	func showBubbleGame(person:LittlePerson?, previousTopic:String?) {
		let transition = SKTransition.revealWithDirection(.Down, duration: 0.7)
		let nextScene = BubbleScene(size: scene!.size)
        nextScene.previousTopic = previousTopic
        nextScene.chosenPlayer = self.chosenPlayer
		nextScene.scaleMode = .AspectFill
        if person != nil {
            nextScene.selectedPerson = person
        } else {
            nextScene.selectedPerson = selectedPerson
        }
		scene?.view?.presentScene(nextScene, transition: transition)
	}
    
    func showSongGame(person:LittlePerson?, previousTopic:String?) {
        let transition = SKTransition.revealWithDirection(.Down, duration: 0.7)
        let nextScene = SongScene(size: scene!.size)
        nextScene.previousTopic = previousTopic
        nextScene.chosenPlayer = self.chosenPlayer
        nextScene.scaleMode = .AspectFill
        if person != nil {
            nextScene.selectedPerson = person
        } else {
            nextScene.selectedPerson = selectedPerson
        }
        scene?.view?.presentScene(nextScene, transition: transition)
    }
    
    func showParentLogin() {
        let frame = prepareDialogRect(300, height: 400)
        let subview = ParentLogin(frame: frame)
        subview.loginListener = self
        self.view?.addSubview(subview)
        self.speak("Ask an adult for help.")
    }
    
    func LoginComplete() {
        clearDialogRect()
        showSettings()
    }
    
    func LoginCanceled() {
        clearDialogRect()
    }
    
    func showSettings() -> SettingsView {
        let subview = SettingsView(frame: (self.view?.bounds)!)
        subview.selectedPerson = self.selectedPerson
        subview.openingScene = self
        self.view?.addSubview(subview)
        return subview
    }
    
    func showManagePeople() -> SearchPeople {
        let subview = SearchPeople(frame: (self.view?.bounds)!)
        subview.selectedPerson = self.selectedPerson
        subview.openingScene = self
        self.view?.addSubview(subview)
        return subview
    }
    
    func showPersonDetails(person:LittlePerson, listener:PersonDetailsCloseListener) -> PersonDetailsView {
        let personDetailsView = PersonDetailsView(frame: (self.view?.bounds)!)
        personDetailsView.listener = listener
        personDetailsView.selectedPerson = self.selectedPerson
        personDetailsView.showPerson(person)
        self.view?.addSubview(personDetailsView)
        return personDetailsView
    }
    
    func showParentsGuide(listener:ParentsGuideCloseListener) {
        let rect = self.prepareDialogRect(CGFloat(500), height: CGFloat(400))
        let subview = ParentsGuide(frame: rect)
        subview.listener = listener
        self.view?.addSubview(subview)
    }
    
    func hideParentsGuide() {
        self.clearDialogRect()
    }
    
    func showSimpleDialog(title:String, message:String) {
        let rect = self.prepareDialogRect(CGFloat(300), height: CGFloat(300))
        let subview = SimpleDialogView(frame: rect)
        subview.listener = self
        subview.setMessage(title, message: message)
        self.view?.addSubview(subview)
    }
    
    func onDialogClose() {
        self.clearDialogRect()
    }
    
    func playSuccessSound(wait:Double, onCompletion: () -> Void) {
        let levelUpAction = SKAction.waitForDuration(wait)
        runAction(levelUpAction) {
            let quietMode = DataService.getInstance().dbHelper.getProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET)
            if quietMode == nil || quietMode == "false" {
                let soundAction = SKAction.playSoundFileNamed("powerup_success", waitForCompletion: true);
                self.runAction(soundAction)
            }
            onCompletion()
        }
    }
    
    func playFailSound(wait:Double, onCompletion: () -> Void) {
        let levelUpAction = SKAction.waitForDuration(wait)
        runAction(levelUpAction) {
            let quietMode = DataService.getInstance().dbHelper.getProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET)
            if quietMode == nil || quietMode == "false" {
                let soundAction = SKAction.playSoundFileNamed("beepboop", waitForCompletion: true);
                self.runAction(soundAction)
            }
            onCompletion()
        }
    }
    
    func speak(message:String) {
        let quietMode = DataService.getInstance().dbHelper.getProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET)
        if quietMode == nil || quietMode == "false" {
            SpeechHelper.getInstance().speak(message)
        } else {
            showFakeToasts([message])
        }
    }
    
    func showFakeToasts(messages:[String]) {
        for s in self.toasts {
            s.removeFromParent()
        }
        self.toasts.removeAll()
        
        let w = min(self.size.width, self.size.height) * CGFloat(0.9)
        let h = w / 12
        var y = CGFloat(h / 2)
        var maxWidth = CGFloat(0)
        var splitMessages = [String]()
        // split up really long messages
        for mes in messages {
            let words = mes.split(" ")
            if words.count > 10 {
                var c = 0
                var str = ""
                for w in words {
                    if c > 0 {
                        str = str + " "
                    }
                    str = str + w
                    c += 1
                    if c > 10 {
                        splitMessages.append(str)
                        str = ""
                        c = 0
                    }
                }
            } else {
                splitMessages.append(mes)
            }
        }
        for m in (0..<splitMessages.count).reverse() {
            let message = splitMessages[m]
            let lc = SKSpriteNode(color: UIColor(hexString: "#BBBBBBCC"), size: CGSizeMake(w, h))
            lc.position = CGPointMake(self.size.width / 2, y)
            lc.zPosition = 1000
            let speakLabel = SKLabelNode(text: message)
            speakLabel.fontColor = UIColor.blackColor()
            speakLabel.fontSize = h / 2
            speakLabel.position = CGPointMake(0, -h/4)
            speakLabel.zPosition = 1
            lc.addChild(speakLabel)
            self.addChild(lc)
            adjustLabelFontSizeToFitRect(speakLabel, node: lc, adjustUp: true)
            if maxWidth < lc.size.width {
                maxWidth = lc.size.width
            }
            
            let action = SKAction.sequence([SKAction.moveByX(0, y: h/3, duration: 4.0), SKAction.removeFromParent()])
            lc.runAction(action)
            
            y = y + lc.size.height + 5
            toasts.append(lc)
        }
        
        for lc in toasts {
            lc.size.width = maxWidth
        }
    }
    
    func adjustLabelFontSizeToFitRect(labelNode:SKLabelNode, node:SKSpriteNode, adjustUp:Bool) {
        // Determine the font scaling factor that should let the label text fit in the given rectangle.
        let scalingFactor = min(node.size.width / labelNode.frame.width, (node.size.height / labelNode.frame.height)/2)
        // Change the fontSize.
        if adjustUp || scalingFactor < 1.0 {
            labelNode.fontSize *= scalingFactor
            node.size.width = labelNode.frame.width+40
        }
    }
    
    func showStars(rect:CGRect, starsInRect: Bool, count: Int, container:SKNode?) {
        self.starRect = rect
        self.starsInRect = starsInRect
        self.starCount = count
        self.starContainer = container
        self.starDelayCount = 0
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
    
    func toggleQuietMode() {
        let quietMode = DataService.getInstance().dbHelper.getProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET)
        if quietMode == nil || quietMode == "false" {
            DataService.getInstance().dbHelper.saveProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET, value: "true")
        } else {
            DataService.getInstance().dbHelper.saveProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET, value: "false")
        }
    }
    
    func prepareDialogRect(width:CGFloat, height:CGFloat) -> CGRect {
        graybox = SKSpriteNode(color: UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.7), size: self.size)
        graybox!.userInteractionEnabled = true
        graybox!.zPosition = 100
        graybox!.position = CGPointMake(self.size.width/2, self.size.height/2)
        self.addChild(graybox!)
        
        var w = width
        var h = height
        var x = (self.size.width - width) / 2
        var y = (self.size.height - height) / 4
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
        if y < 0 {
            y = CGFloat(0)
        }
        if x < 0 {
            x = CGFloat(0)
        }
        
        let rect = CGRect(x: x, y: y, width: w, height: h)
        return rect
    }
    
    func clearDialogRect() {
        graybox!.removeFromParent()
    }
}