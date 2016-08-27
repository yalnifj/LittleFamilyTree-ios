//
//  LittleFamilyScene.swift
//  Little Family Tree
//
//  Created by Melissa on 11/26/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation
import Firebase
import FirebaseDatabase
import StoreKit

class LittleFamilyScene: SKScene, EventListener, LoginCompleteListener, SimpleDialogCloseListener, IAPHelperListener {
    static var TOPIC_START_HOME = "start_home"
    static var TOPIC_START_CHOOSE = "start_choose"
	static var TOPIC_START_SETTINGS = "start_settings"
    static var TOPIC_TOGGLE_QUIET = "toggle_quiet"
    static var PROP_HAS_PREMIUM = "has_premium"
    static var TOPIC_BUY_PRESSED = "buy_button_pressed"
    static var TOPIC_TRY_PRESSED = "try_button_pressed"
    static var PROP_FIRST_RUN = "firstRunPassed"
    static var FREE_TRIES = 3

    var topBar:TopBar?
    var addingStars = false
    var starRect:CGRect?
    var starCount = 0
    var starsInRect = false
    var starDelayCount = 2
    var starDelay = 2
    var redStarRect:CGRect?
    var redStarCount = 0
    var redStarsInRect = false
    var redStarDelayCount = 2
    var redStarDelay = 2
    var loadingDialog:SKSpriteNode?
    var lockDialog:SKSpriteNode?
    var selectedPerson:LittlePerson?
    var chosenPlayer:LittlePerson?
    var starContainer:SKNode?
    var redStarContainer:SKNode?
    var previousTopic:String?
    var graybox:SKSpriteNode?
    var toasts = [SKSpriteNode]()
    var audioPlayer:AVAudioPlayer!
    var hasPremium:Bool!
    var loginForPurchase = false
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        EventHandler.getInstance().subscribe(LittleFamilyScene.TOPIC_START_HOME, listener: self)
        EventHandler.getInstance().subscribe(LittleFamilyScene.TOPIC_START_CHOOSE, listener: self)
		EventHandler.getInstance().subscribe(LittleFamilyScene.TOPIC_START_SETTINGS, listener: self)
        EventHandler.getInstance().subscribe(LittleFamilyScene.TOPIC_TOGGLE_QUIET, listener: self)
        EventHandler.getInstance().subscribe(LittleFamilyScene.TOPIC_BUY_PRESSED, listener: self)
        EventHandler.getInstance().subscribe(LittleFamilyScene.TOPIC_TRY_PRESSED, listener: self)
        
        self.userHasPremium({ premium in
          self.hasPremium = premium
        })
        
        DataService.getInstance().dbHelper.saveProperty(LittleFamilyScene.PROP_FIRST_RUN, value: "true")
    }
    
    override func willMoveFromView(view: SKView) {
        super.willMoveFromView(view)
        EventHandler.getInstance().unSubscribe(LittleFamilyScene.TOPIC_START_HOME, listener: self)
        EventHandler.getInstance().unSubscribe(LittleFamilyScene.TOPIC_START_CHOOSE, listener: self)
		EventHandler.getInstance().unSubscribe(LittleFamilyScene.TOPIC_START_SETTINGS, listener: self)
        EventHandler.getInstance().unSubscribe(LittleFamilyScene.TOPIC_TOGGLE_QUIET, listener: self)
        EventHandler.getInstance().unSubscribe(LittleFamilyScene.TOPIC_BUY_PRESSED, listener: self)
        EventHandler.getInstance().unSubscribe(LittleFamilyScene.TOPIC_TRY_PRESSED, listener: self)
        
        stopAllSounds()
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
                starDelayCount -= 1;
            }
        }

        if (redStarCount > 0) {
            if (redStarDelayCount <= 0) {
                redStarDelayCount = redStarDelay
                redStarCount -= 1;
                for _ in 0..<4 {
                    if (redStarRect != nil) {
                        var redStarFile = "redstar1"
                        if hasPremium != nil && hasPremium! {
                            redStarFile = "star1"
                        }
                        let star = SKSpriteNode(imageNamed: redStarFile)
                        var x = CGFloat(0)
                        var y = CGFloat(0)
                        if (redStarsInRect) {
                            x = (redStarRect?.origin.x)! + CGFloat(arc4random_uniform(UInt32((redStarRect?.width)!)))
                            y = (redStarRect?.origin.y)! + CGFloat(arc4random_uniform(UInt32((redStarRect?.height)!)))
                        } else {
                            let side = arc4random_uniform(4)
                            switch (side) {
                            case 0:
                                x = (redStarRect?.origin.x)! + CGFloat(arc4random_uniform(UInt32((redStarRect?.width)!)))
                                y = (redStarRect?.origin.y)! + CGFloat(arc4random_uniform(UInt32(star.size.height)))
                                break
                            case 1:
                                x = (redStarRect?.origin.x)! + (redStarRect?.width)! - CGFloat(arc4random_uniform(UInt32(star.size.width)))
                                y = (redStarRect?.origin.y)! + CGFloat(arc4random_uniform(UInt32((redStarRect?.height)!)))
                                break
                            case 2:
                                x = (redStarRect?.origin.x)! + CGFloat(arc4random_uniform(UInt32((redStarRect?.width)!)))
                                y = (redStarRect?.origin.y)! + (starRect?.height)! - CGFloat(arc4random_uniform(UInt32(star.size.height)))
                                break
                            default:
                                x = (redStarRect?.origin.x)! + CGFloat(arc4random_uniform(UInt32(star.size.width)))
                                y = (redStarRect?.origin.y)! + CGFloat(arc4random_uniform(UInt32((redStarRect?.height)!)))
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
                        if self.redStarContainer == nil {
                            self.addChild(star)
                        } else {
                            self.redStarContainer?.addChild(star)
                        }
                    }
                }
            } else {
                redStarDelayCount -= 1;
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
    func setListenerIndex(index: Int) {
        self.listenerIndex = index
    }
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
        } else if topic == LittleFamilyScene.TOPIC_TRY_PRESSED {
            hideLockDialog()
        } else if topic == LittleFamilyScene.TOPIC_BUY_PRESSED {
            hideLockDialog()
            loginForPurchase = true
            showParentLoginDialog()
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
        else if topic == GameScene.TOPIC_START_CARD {
            self.showCardGame(nil, previousTopic: nil)
        }
        else if topic == GameScene.TOPIC_START_BIRD {
            self.showBirdGame(nil, previousTopic: nil)
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
    
    func showCardGame(person:LittlePerson?, previousTopic:String?) {
        let transition = SKTransition.revealWithDirection(.Down, duration: 0.7)
        let nextScene = BirthdayPeopleScene(size: scene!.size)
        nextScene.previousTopic = previousTopic
        nextScene.chosenPlayer = self.chosenPlayer
        nextScene.scaleMode = .AspectFill
        if person != nil && person != selectedPerson {
            nextScene.birthdayPerson = person
        }
        nextScene.selectedPerson = selectedPerson
        
        scene?.view?.presentScene(nextScene, transition: transition)
    }
    
    func showBirdGame(person:LittlePerson?, previousTopic:String?) {
        let transition = SKTransition.revealWithDirection(.Down, duration: 0.7)
        let nextScene = BirdScene(size: scene!.size)
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
        loginForPurchase = false
		let remember = DataService.getInstance().dbHelper.getProperty(DataService.PROPERTY_REMEMBER_ME)
		if remember != nil {
			let time = Double(remember!)
			let date = NSDate(timeIntervalSince1970: time!)
			if date.timeIntervalSinceNow > -60 * 20 {
				showSettings()
				return
			}
		}
        showParentLoginDialog()
    }
    
    func showParentLoginDialog() {
        let frame = prepareDialogRect(300, height: 400)
        let subview = ParentLogin(frame: frame)
        subview.loginListener = self
        self.view?.addSubview(subview)
        self.speak("Ask an adult for help.")
    }
    
    func LoginComplete() {
        clearDialogRect()
        if loginForPurchase {
            if iapHelper == nil {
                iapHelper = IAPHelper(listener: self)
            }
            if iapHelper!.canMakePayents() {
                buyPremium()
            } else {
                showSimpleDialog("Unable to Purchase", message: "This device does not have permissions to make purchases.")
            }
        } else {
            showSettings()
        }
    }
    
    func LoginCanceled() {
        clearDialogRect()
        if loginForPurchase {
            showHomeScreen()
        }
    }
    
    func showSettings() -> SettingsView {
        let subview = SettingsView(frame: (self.view?.bounds)!)
        subview.selectedPerson = self.selectedPerson
        subview.openingScene = self
        self.paused = true
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
        personDetailsView.openingScene = self
        personDetailsView.selectedPerson = self.selectedPerson
        personDetailsView.showPerson(person)
        self.view?.addSubview(personDetailsView)
        return personDetailsView
    }
    
    func showRecordAudioDialog(person:LittlePerson, listener:PersonDetailsCloseListener) -> RecordAudioView {
        let recordAudioView = RecordAudioView(frame: (self.view?.bounds)!)
        recordAudioView.openingScene = self
        recordAudioView.listener = listener
        recordAudioView.showPerson(person)
        self.view?.addSubview(recordAudioView)
        return recordAudioView
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
	
	func sayGivenName(person:LittlePerson) {
		if person.givenNameAudioPath != nil {
			let quietMode = DataService.getInstance().dbHelper.getProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET)
			if quietMode == nil || quietMode == "false" {
				let fileManager = NSFileManager.defaultManager()
				let url = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
				let soundFileUrl = url.URLByAppendingPathComponent(person.givenNameAudioPath! as String)
                do {
                    let fileAttributes = try NSFileManager.defaultManager().attributesOfItemAtPath(soundFileUrl.path!)
                    let fileSize = fileAttributes[NSFileSize]
                    print("fileSize=\(fileSize)")
                } catch {
                    print("Error setting audio session category \(error)")
                }
                do {
                    let audioSession = AVAudioSession.sharedInstance()
                    try audioSession.setCategory(AVAudioSessionCategoryPlayback)
                    try audioSession.setActive(true)
                    audioPlayer = try AVAudioPlayer(contentsOfURL: soundFileUrl)
                    audioPlayer.volume = 1.5
                    audioPlayer.prepareToPlay()
                    audioPlayer.play()
                } catch {
					print("audioPlayer error:  \(error)")
					speak(person.givenName as! String)
				}
			} else {
				showFakeToasts([person.givenName as! String])
			}
		} else {
			speak(person.givenName as! String)
		}
	}
    
    func stopAllSounds() {
        if audioPlayer != nil {
            audioPlayer.stop()
        }
        
        SpeechHelper.getInstance().stop()
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
    
    func showRedStars(rect:CGRect, starsInRect: Bool, count: Int, container:SKNode?) {
        self.redStarRect = rect
        self.redStarsInRect = starsInRect
        self.redStarCount = count
        self.redStarContainer = container
        self.redStarDelayCount = 0
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
    
    func getTryCount(tryProperty:String) -> Int {
        let tryCountStr = DataService.getInstance().dbHelper.getProperty(tryProperty)
        var tryCount = 1
        if tryCountStr != nil {
            tryCount = Int(tryCountStr!)! + 1
        }
        return tryCount
    }
    
    func showLockDialog(tryAvailable:Bool, tries:Int) {
        self.prepareDialogRect(CGFloat(300), height: CGFloat(300))
        
        lockDialog = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeMake(350, 420))
        lockDialog?.position = CGPointMake(self.size.width/2, self.size.height/2)
        lockDialog?.zPosition = 1500
        lockDialog?.userInteractionEnabled = true
        
        let lock = SKSpriteNode(imageNamed: "lock")
        let ratio2 = lock.size.height / lock.size.width
        lock.size.width = lockDialog!.size.width * 0.65
        lock.size.height = lock.size.width * ratio2
        lock.position = CGPointMake(0, lockDialog!.size.height - lock.size.height * 1.6)
        lockDialog?.addChild(lock)
        
        let backButton = LabelEventSprite(text: "< Back")
        backButton.topic = LittleFamilyScene.TOPIC_START_HOME
        backButton.userInteractionEnabled = true
        backButton.fontColor = UIColor.blueColor()
        backButton.fontSize = lockDialog!.size.width / 14
        backButton.position = CGPointMake(5 + backButton.frame.width / 2 - lockDialog!.size.width / 2, lockDialog!.size.height / 2 - backButton.frame.height - 5)
        lockDialog?.addChild(backButton)
        
        let label = SKLabelNode(text: "This is a premium game.")
        label.fontColor = UIColor.blackColor()
        label.fontSize = lockDialog!.size.width / 12
        label.position = CGPointMake(0, lock.position.y - (lock.size.height/2 + label.fontSize))
        lockDialog?.addChild(label)
        if (!tryAvailable) {
            let label2 = SKLabelNode(text: "Upgrade to play again.")
            label2.fontSize = lockDialog!.size.width / 12
            label2.fontColor = UIColor.blackColor()
            label2.position = CGPointMake(0, label.position.y - label2.fontSize)
            lockDialog?.addChild(label2)
            
            let buyButton = EventSprite(imageNamed: "buyButton")
            buyButton.topic = LittleFamilyScene.TOPIC_BUY_PRESSED
            buyButton.userInteractionEnabled = true
            buyButton.position = CGPointMake(0, label2.position.y - label2.frame.height / 2 - buyButton.size.height / 2)
            lockDialog?.addChild(buyButton)
        } else {
            let label2 = SKLabelNode(text: "You have \(tries) tries left.")
            if tries == 1 {
                label2.text = "You have 1 try left."
            }
            label2.fontSize = lockDialog!.size.width / 12
            label2.fontColor = UIColor.blackColor()
            label2.position = CGPointMake(0, label.position.y - label2.fontSize)
            lockDialog?.addChild(label2)
            
            let tryButton = EventSprite(imageNamed: "tryButton")
            tryButton.topic = LittleFamilyScene.TOPIC_TRY_PRESSED
            tryButton.userInteractionEnabled = true
            tryButton.position = CGPointMake(-tryButton.size.width / 2, label2.position.y - label2.frame.height / 2 - tryButton.size.height / 2)
            lockDialog?.addChild(tryButton)
            
            let buyButton = EventSprite(imageNamed: "buyButton")
            buyButton.topic = LittleFamilyScene.TOPIC_BUY_PRESSED
            buyButton.userInteractionEnabled = true
            buyButton.position = CGPointMake(buyButton.size.width / 2, label2.position.y - label2.frame.height / 2 - buyButton.size.height / 2)
            lockDialog?.addChild(buyButton)
        }

        self.addChild(lockDialog!)

    }
    
    func hideLockDialog() {
        clearDialogRect()
        if lockDialog != nil {
            lockDialog?.removeFromParent()
            lockDialog = nil
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
    
    func userHasPremium(onCompletion: (Bool) -> Void) {
        let premiumStr = DataService.getInstance().dbHelper.getProperty(LittleFamilyScene.PROP_HAS_PREMIUM)
        if premiumStr == nil || premiumStr != "true" {
            let username = DataService.getInstance().getEncryptedProperty(DataService.SERVICE_USERNAME)
            if username != nil {
                let ref = FIRDatabase.database().reference()
                ref.child("users").child(username!).observeSingleEventOfType(.Value, withBlock: { (snap) in
                    print(snap)
                    // Get user value
                    if snap.exists() && snap.hasChild("iosPremium") {
                        let vals = snap.value as! NSDictionary
                        if vals["iosPremium"] != nil {
                            let pval = vals["iosPremium"] as! Bool
                            if pval {
                                DataService.getInstance().dbHelper.saveProperty(LittleFamilyScene.PROP_HAS_PREMIUM, value: "true")
                                onCompletion(pval)
                                return
                            }
                        }
                    }
                    onCompletion(false)
                }) { (error) in
                    print(error.localizedDescription)
                    onCompletion(false)
                }
            }
        } else {
            if premiumStr == "true" {
                onCompletion(true)
            } else {
                onCompletion(false)
            }
        }
    }
    
    var iapHelper:IAPHelper?
    func onProductsReady(productsArray: [SKProduct]) {
        iapHelper!.buyProduct(0)
    }
    func onTransactionComplete() {
        DataService.getInstance().dbHelper.saveProperty(LittleFamilyScene.PROP_HAS_PREMIUM, value: "true")
        DataService.getInstance().dbHelper.fireCreateOrUpdateUser(true)
        hideLoadingDialog()
    }
    func onError(error:String) {
        print(error)
        hideLoadingDialog()
        showSimpleDialog("Error", message: error)
    }
    
    func buyPremium() {
        showLoadingDialog()
        iapHelper = IAPHelper(listener: self)
        iapHelper?.requestProductInfo()
    }
}