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
import SystemConfiguration

class LittleFamilyScene: SKScene, EventListener, LoginCompleteListener, SimpleDialogCloseListener, IAPHelperListener {
    static var TOPIC_START_HOME = "start_home"
    static var TOPIC_START_CHOOSE = "start_choose"
	static var TOPIC_START_SETTINGS = "start_settings"
    static var TOPIC_TOGGLE_QUIET = "toggle_quiet"
    static var PROP_HAS_PREMIUM = "has_premium"
    static var TOPIC_BUY_PRESSED = "buy_button_pressed"
    static var TOPIC_TRY_PRESSED = "try_button_pressed"
    static var PROP_FIRST_RUN = "firstRunPassed"
    static var TOPIC_HELP_BUTTON = "help_button_pressed"
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
    var buyError = false
    var loginForParentsGuide = false
    var pgListener:ParentsGuideCloseListener?
    var dialogOpen = false
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        stopAllSpeaking()
        
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
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        EventHandler.getInstance().unSubscribe(LittleFamilyScene.TOPIC_START_HOME, listener: self)
        EventHandler.getInstance().unSubscribe(LittleFamilyScene.TOPIC_START_CHOOSE, listener: self)
		EventHandler.getInstance().unSubscribe(LittleFamilyScene.TOPIC_START_SETTINGS, listener: self)
        EventHandler.getInstance().unSubscribe(LittleFamilyScene.TOPIC_TOGGLE_QUIET, listener: self)
        EventHandler.getInstance().unSubscribe(LittleFamilyScene.TOPIC_BUY_PRESSED, listener: self)
        EventHandler.getInstance().unSubscribe(LittleFamilyScene.TOPIC_TRY_PRESSED, listener: self)
        
        stopAllSounds()
        
        if iapHelper != nil {
            iapHelper!.cleanup()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
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
                    let growAction = SKAction.scale(to: 1.0, duration: 1.5)
                    let shrinkAction = SKAction.scale(to: 0.0, duration: 1.5)
                    let doubleAction = SKAction.sequence([growAction, shrinkAction, SKAction.removeFromParent()])
                    star.run(doubleAction)
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
                        let growAction = SKAction.scale(to: 1.0, duration: 1.5)
                        let shrinkAction = SKAction.scale(to: 0.0, duration: 1.5)
                        let doubleAction = SKAction.sequence([growAction, shrinkAction, SKAction.removeFromParent()])
                        star.run(doubleAction)
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
        let tsie = CGSize(width: self.size.width, height: self.size.height*0.05)
        topBar = TopBar(color: UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.7), size: tsie)
        topBar!.position = CGPoint(x: self.size.width/2, y: self.size.height-(topBar!.size.height / 2))
        topBar!.person = selectedPerson
        topBar!.homeTexture = SKTexture(imageNamed: "home")
        topBar!.isUserInteractionEnabled = true
        topBar!.zPosition = 100
        self.addChild(topBar!)
    }
    
    var listenerIndex:Int?
    func setListenerIndex(_ index: Int) {
        self.listenerIndex = index
    }
    func onEvent(_ topic: String, data: NSObject?) {
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
        let transition = SKTransition.reveal(with: .down, duration: 0.7)
        let nextScene = GameScene(size: scene!.size)
        nextScene.scaleMode = .aspectFill
        if self.chosenPlayer != nil {
            nextScene.selectedPerson = self.chosenPlayer
        } else {
            nextScene.selectedPerson = self.selectedPerson
        }
        scene?.view?.presentScene(nextScene, transition: transition)
    }
    
    func showChoosePlayerScreen() {
        let transition = SKTransition.reveal(with: .down, duration: 0.7)
        let nextScene = ChoosePlayerScene(size: scene!.size)
        nextScene.scaleMode = .aspectFill
        scene?.view?.presentScene(nextScene, transition: transition)
    }
	
    func showMatchGame(_ person:LittlePerson?, previousTopic:String?) {
		let transition = SKTransition.reveal(with: .down, duration: 0.7)
		let nextScene = MatchGameScene(size: scene!.size)
        nextScene.previousTopic = previousTopic
        nextScene.chosenPlayer = self.chosenPlayer
		nextScene.scaleMode = .aspectFill
        if person != nil {
            nextScene.selectedPerson = person
        } else {
            nextScene.selectedPerson = selectedPerson
        }
		scene?.view?.presentScene(nextScene, transition: transition)
	}
	
	func showHeritageCalculatorGame(_ person:LittlePerson?, previousTopic:String?) {
		let transition = SKTransition.reveal(with: .down, duration: 0.7)
        let nextScene = ChooseCultureScene(size: scene!.size)
        nextScene.previousTopic = previousTopic
        nextScene.chosenPlayer = self.chosenPlayer
		nextScene.scaleMode = .aspectFill
        if person != nil {
            nextScene.selectedPerson = person
        } else {
            nextScene.selectedPerson = selectedPerson
        }
		scene?.view?.presentScene(nextScene, transition: transition)
	}
	
	func showDressupGame(_ dollConfig:DollConfig, person:LittlePerson?, previousTopic:String?) {
		let transition = SKTransition.reveal(with: .down, duration: 0.7)
		let nextScene = DressUpScene(size: scene!.size)
        nextScene.previousTopic = previousTopic
        nextScene.chosenPlayer = self.chosenPlayer
		nextScene.scaleMode = .aspectFill
        if person != nil {
            nextScene.selectedPerson = person
        } else {
            nextScene.selectedPerson = selectedPerson
        }
		nextScene.dollConfig = dollConfig
		scene?.view?.presentScene(nextScene, transition: transition)
	}
	
	func showPuzzleGame(_ person:LittlePerson?, previousTopic:String?) {
		let transition = SKTransition.reveal(with: .down, duration: 0.7)
		let nextScene = PuzzleScene(size: scene!.size)
        nextScene.previousTopic = previousTopic
        nextScene.chosenPlayer = self.chosenPlayer
		nextScene.scaleMode = .aspectFill
        if person != nil {
            nextScene.selectedPerson = person
        } else {
            nextScene.selectedPerson = selectedPerson
        }
		scene?.view?.presentScene(nextScene, transition: transition)
	}
	
	func showScratchGame(_ person:LittlePerson?, previousTopic:String?) {
		let transition = SKTransition.reveal(with: .down, duration: 0.7)
        
		let nextScene = ScratchScene(size: scene!.size)
        nextScene.previousTopic = previousTopic
        nextScene.chosenPlayer = self.chosenPlayer
		nextScene.scaleMode = .aspectFill
        if person != nil {
            nextScene.selectedPerson = person
        } else {
            nextScene.selectedPerson = selectedPerson
        }
		scene?.view?.presentScene(nextScene, transition: transition)
	}
	
    func showColoringGame(_ person:LittlePerson?, previousTopic:String?) {
		let transition = SKTransition.reveal(with: .down, duration: 0.7)
		let nextScene = ColoringScene(size: scene!.size)
        nextScene.previousTopic = previousTopic
        nextScene.chosenPlayer = self.chosenPlayer
		nextScene.scaleMode = .aspectFill
        if person != nil {
            nextScene.selectedPerson = person
        } else {
            nextScene.selectedPerson = selectedPerson
        }
		scene?.view?.presentScene(nextScene, transition: transition)
	}
	
	func showTree(_ person:LittlePerson?, previousTopic:String?) {
		let transition = SKTransition.reveal(with: .down, duration: 0.7)
		let nextScene = TreeScene(size: scene!.size)
        nextScene.previousTopic = previousTopic
        nextScene.chosenPlayer = self.chosenPlayer
		nextScene.scaleMode = .aspectFill
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
	
	func showBubbleGame(_ person:LittlePerson?, previousTopic:String?) {
		let transition = SKTransition.reveal(with: .down, duration: 0.7)
		let nextScene = BubbleScene(size: scene!.size)
        nextScene.previousTopic = previousTopic
        nextScene.chosenPlayer = self.chosenPlayer
		nextScene.scaleMode = .aspectFill
        if person != nil {
            nextScene.selectedPerson = person
        } else {
            nextScene.selectedPerson = selectedPerson
        }
		scene?.view?.presentScene(nextScene, transition: transition)
	}
    
    func showSongGame(_ person:LittlePerson?, previousTopic:String?) {
        let transition = SKTransition.reveal(with: .down, duration: 0.7)
        let nextScene = SongScene(size: scene!.size)
        nextScene.previousTopic = previousTopic
        nextScene.chosenPlayer = self.chosenPlayer
        nextScene.scaleMode = .aspectFill
        if person != nil {
            nextScene.selectedPerson = person
        } else {
            nextScene.selectedPerson = selectedPerson
        }
        scene?.view?.presentScene(nextScene, transition: transition)
    }
    
    func showCardGame(_ person:LittlePerson?, previousTopic:String?) {
        let transition = SKTransition.reveal(with: .down, duration: 0.7)
        let nextScene = BirthdayPeopleScene(size: scene!.size)
        nextScene.previousTopic = previousTopic
        nextScene.chosenPlayer = self.chosenPlayer
        nextScene.scaleMode = .aspectFill
        if person != nil && person != selectedPerson {
            nextScene.birthdayPerson = person
        }
        nextScene.selectedPerson = selectedPerson
        
        scene?.view?.presentScene(nextScene, transition: transition)
    }
    
    func showBirdGame(_ person:LittlePerson?, previousTopic:String?) {
        let transition = SKTransition.reveal(with: .down, duration: 0.7)
        let nextScene = BirdScene(size: scene!.size)
        nextScene.previousTopic = previousTopic
        nextScene.chosenPlayer = self.chosenPlayer
        nextScene.scaleMode = .aspectFill
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
			let date = Foundation.Date(timeIntervalSince1970: time!)
			if date.timeIntervalSinceNow > -60 * 20 {
                if loginForParentsGuide {
                    clearDialogRect()
                    let rect = self.prepareDialogRect(CGFloat(500), height: CGFloat(450))
                    let subview = ParentsGuide(frame: rect)
                    subview.listener = self.pgListener
                    self.view?.addSubview(subview)
                } else {
                    showSettings()
                }
				return
			}
		}
        showParentLoginDialog()
    }
    
    func showParentLoginDialog() {
        if !self.dialogOpen {
            let frame = prepareDialogRect(300, height: 400)
            let subview = ParentLogin(frame: frame)
            subview.loginListener = self
            self.view?.addSubview(subview)
            self.speak("Ask an adult for help.")
        }
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
        } else if loginForParentsGuide {
            self.showParentsGuide(pgListener!, skipGate: true)
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
        var frame:CGRect? = self.view?.bounds
        if frame == nil {
            frame = self.frame
        }
        let subview = SettingsView(frame: frame!)
        subview.selectedPerson = self.selectedPerson
        subview.openingScene = self
        self.isPaused = true
        self.view?.addSubview(subview)
        return subview
    }
    
    func showManagePeople() -> SearchPeople {
        var frame:CGRect? = self.view?.bounds
        if frame == nil {
            frame = self.frame
        }
        let subview = SearchPeople(frame: frame!)
        subview.selectedPerson = self.selectedPerson
        subview.openingScene = self
        self.view?.addSubview(subview)
        return subview
    }
    
    func showPersonDetails(_ person:LittlePerson, listener:PersonDetailsCloseListener) -> PersonDetailsView {
        var frame:CGRect? = self.view?.bounds
        if frame == nil {
            frame = self.frame
        }
        let personDetailsView = PersonDetailsView(frame: frame!)
        personDetailsView.listener = listener
        personDetailsView.openingScene = self
        personDetailsView.selectedPerson = self.selectedPerson
        personDetailsView.showPerson(person)
        self.view?.addSubview(personDetailsView)
        return personDetailsView
    }
    
    func showRecordAudioDialog(_ person:LittlePerson, listener:PersonDetailsCloseListener) -> RecordAudioView {
        var frame:CGRect? = self.view?.bounds
        if frame == nil {
            frame = self.frame
        }
        let recordAudioView = RecordAudioView(frame: frame!)
        recordAudioView.openingScene = self
        recordAudioView.listener = listener
        recordAudioView.showPerson(person)
        self.view?.addSubview(recordAudioView)
        return recordAudioView
    }
    
    func showParentsGuide(_ listener:ParentsGuideCloseListener, skipGate:Bool) {
        if skipGate {
            clearDialogRect()
            let rect = self.prepareDialogRect(CGFloat(500), height: CGFloat(450))
            let subview = ParentsGuide(frame: rect)
            subview.listener = listener
            self.view?.addSubview(subview)
        } else {
            loginForParentsGuide = true
            pgListener = listener
            showParentLogin()
        }
    }
    
    func hideParentsGuide() {
        self.clearDialogRect()
    }
    
    func showSimpleDialog(_ title:String, message:String) {
        if !self.dialogOpen {
            DispatchQueue.main.async(execute: {
                let rect = self.prepareDialogRect(CGFloat(300), height: CGFloat(300))
                let subview = SimpleDialogView(frame: rect)
                subview.listener = self
                subview.setMessage(title, message: message)
                self.view?.addSubview(subview)
            })
        }
    }
    
    func onDialogClose() {
        self.clearDialogRect()
        if buyError {
            self.showHomeScreen()
        }
    }
    
    func playSuccessSound(_ wait:Double, onCompletion: @escaping () -> Void) {
        let levelUpAction = SKAction.wait(forDuration: wait)
        run(levelUpAction, completion: {
            let quietMode = DataService.getInstance().dbHelper.getProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET)
            if quietMode == nil || quietMode == "false" {
                let soundAction = SKAction.playSoundFileNamed("powerup_success", waitForCompletion: true);
                self.run(soundAction)
            }
            onCompletion()
        }) 
    }
    
    func playFailSound(_ wait:Double, onCompletion: @escaping () -> Void) {
        let levelUpAction = SKAction.wait(forDuration: wait)
        run(levelUpAction, completion: {
            let quietMode = DataService.getInstance().dbHelper.getProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET)
            if quietMode == nil || quietMode == "false" {
                let soundAction = SKAction.playSoundFileNamed("beepboop", waitForCompletion: true);
                self.run(soundAction)
            }
            onCompletion()
        }) 
    }
    
    func speak(_ message:String) {
        let quietMode = DataService.getInstance().dbHelper.getProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET)
        if quietMode == nil || quietMode == "false" {
            SpeechHelper.getInstance().speak(message)
        } else {
            showFakeToasts([message])
        }
    }
	
	func sayGivenName(_ person:LittlePerson) {
		if person.givenNameAudioPath != nil {
			let quietMode = DataService.getInstance().dbHelper.getProperty(LittleFamilyScene.TOPIC_TOGGLE_QUIET)
			if quietMode == nil || quietMode == "false" {
				let fileManager = FileManager.default
				let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
				let soundFileUrl = url.appendingPathComponent(person.givenNameAudioPath! as String)
                do {
                    let fileAttributes = try FileManager.default.attributesOfItem(atPath: soundFileUrl.path)
                    let fileSize = fileAttributes[FileAttributeKey.size]
                    print("fileSize=\(fileSize)")
                } catch {
                    print("Error setting audio session category \(error)")
                }
                do {
                    let audioSession = AVAudioSession.sharedInstance()
                    try audioSession.setCategory(AVAudioSessionCategoryPlayback)
                    try audioSession.setActive(true)
                    audioPlayer = try AVAudioPlayer(contentsOf: soundFileUrl)
                    audioPlayer.volume = 1.5
                    audioPlayer.prepareToPlay()
                    audioPlayer.play()
                } catch {
					print("audioPlayer error:  \(error)")
					speak(person.givenName!)
				}
			} else {
				showFakeToasts([person.givenName!])
			}
		} else {
			speak(person.givenName!)
		}
	}
    
    func stopAllSpeaking() {
        SpeechHelper.getInstance().stop()
    }
    
    func stopAllSounds() {
        if audioPlayer != nil {
            audioPlayer.stop()
        }
    }
    
    func showFakeToasts(_ messages:[String]) {
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
        for m in (0..<splitMessages.count).reversed() {
            let message = splitMessages[m]
            let lc = SKSpriteNode(color: UIColor(hexString: "#BBBBBBCC"), size: CGSize(width: w, height: h))
            lc.position = CGPoint(x: self.size.width / 2, y: y)
            lc.zPosition = 1000
            let speakLabel = SKLabelNode(text: message)
            speakLabel.fontColor = UIColor.black
            speakLabel.fontSize = h / 2
            speakLabel.position = CGPoint(x: 0, y: -h/4)
            speakLabel.zPosition = 1
            lc.addChild(speakLabel)
            self.addChild(lc)
            adjustLabelFontSizeToFitRect(speakLabel, node: lc, adjustUp: true)
            if maxWidth < lc.size.width {
                maxWidth = lc.size.width
            }
            
            let action = SKAction.sequence([SKAction.moveBy(x: 0, y: h/3, duration: 4.0), SKAction.removeFromParent()])
            lc.run(action)
            
            y = y + lc.size.height + 5
            toasts.append(lc)
        }
        
        for lc in toasts {
            lc.size.width = maxWidth
        }
    }
    
    func adjustLabelFontSizeToFitRect(_ labelNode:SKLabelNode, node:SKSpriteNode, adjustUp:Bool) {
        // Determine the font scaling factor that should let the label text fit in the given rectangle.
        let scalingFactor = min(node.size.width / labelNode.frame.width, (node.size.height / labelNode.frame.height)/2)
        // Change the fontSize.
        if adjustUp || scalingFactor < 1.0 {
            labelNode.fontSize *= scalingFactor
            node.size.width = labelNode.frame.width+40
        }
    }
    
    func showStars(_ rect:CGRect, starsInRect: Bool, count: Int, container:SKNode?) {
        self.starRect = rect
        self.starsInRect = starsInRect
        self.starCount = count
        self.starContainer = container
        self.starDelayCount = 0
    }
    
    func showRedStars(_ rect:CGRect, starsInRect: Bool, count: Int, container:SKNode?) {
        self.redStarRect = rect
        self.redStarsInRect = starsInRect
        self.redStarCount = count
        self.redStarContainer = container
        self.redStarDelayCount = 0
    }
    
    func showLoadingDialog() {
        if loadingDialog == nil {
            loadingDialog = SKSpriteNode(color: UIColor.white, size: CGSize(width: 270, height: 350))
            loadingDialog?.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
            loadingDialog?.zPosition = 1000
            
            let logo = SKSpriteNode(imageNamed: "loading")
            let ratio2 = logo.size.height / logo.size.width
            logo.size.width = (loadingDialog?.size.width)! - 20
            logo.size.height = ((loadingDialog?.size.width)! - 20) * ratio2
            logo.position = CGPoint(x: 10, y: ((loadingDialog?.size.height)! / -2) + logo.size.height)
            loadingDialog?.addChild(logo)
        
            let tree = SKSpriteNode(imageNamed: "growing_plant1")
            let ratio = tree.size.width / tree.size.height
            tree.size.height = (loadingDialog?.size.height)! / 1.8
            tree.size.width = tree.size.height * ratio
            tree.position = CGPoint(x: 0, y: logo.position.y + logo.size.height + tree.size.height / 2)
            
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
            let action = SKAction.repeatForever(SKAction.animate(with: growing, timePerFrame: 0.25, resize: false, restore: false))
            tree.run(action)
            
            self.addChild(loadingDialog!)
        } else {
            loadingDialog?.isHidden = false
        }
    }
    
    func hideLoadingDialog() {
        if loadingDialog != nil {
            loadingDialog?.isHidden = true
        }
    }
    
    func getTryCount(_ tryProperty:String) -> Int {
        let tryCountStr = DataService.getInstance().dbHelper.getProperty(tryProperty)
        var tryCount = 1
        if tryCountStr != nil {
            tryCount = Int(tryCountStr!)! + 1
        }
        return tryCount
    }
    
    func showLockDialog(_ tryAvailable:Bool, tries:Int) {
        if !self.dialogOpen {
            DataService.getInstance().dbHelper.checkSale(onCompletion: { sale in
                self.prepareDialogRect(CGFloat(300), height: CGFloat(300))
                
                self.lockDialog = SKSpriteNode(color: UIColor.white, size: CGSize(width: 350, height: 420))
                self.lockDialog?.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
                self.lockDialog?.zPosition = 1500
                self.lockDialog?.isUserInteractionEnabled = true
                
                var lockImg = "lock"
                var buyImg = "buyButton"
                var lockWidth = CGFloat(0.65)
                if sale != nil {
                    if sale?.price == 1.99 {
                        lockImg = "lock_50"
                        buyImg = "buy_button_199"
                        lockWidth = CGFloat(0.85)
                    }
                    if sale?.price == 2.99 {
                        lockImg = "lock_25"
                        buyImg = "buy_button_299"
                        lockWidth = CGFloat(0.85)
                    }
                }
                
                let lock = SKSpriteNode(imageNamed: lockImg)
                let ratio2 = lock.size.height / lock.size.width
                lock.size.width = self.lockDialog!.size.width * lockWidth
                lock.size.height = lock.size.width * ratio2
                lock.position = CGPoint(x: 0, y: (self.lockDialog!.size.height / 2) - (lock.size.height / 2) - 25)
                self.lockDialog?.addChild(lock)
                
                let backButton = LabelEventSprite(text: "< Back")
                backButton.topic = LittleFamilyScene.TOPIC_START_HOME
                backButton.isUserInteractionEnabled = true
                backButton.fontColor = UIColor.blue
                backButton.fontSize = self.lockDialog!.size.width / 14
                backButton.position = CGPoint(x: 5 + backButton.frame.width / 2 - self.lockDialog!.size.width / 2, y: self.lockDialog!.size.height / 2 - backButton.frame.height - 5)
                self.lockDialog?.addChild(backButton)
                
                var labelY = lock.position.y - (lock.size.height/2)
                if sale != nil {
                    let pos = CGPoint(x: 0, y: lock.position.y - (lock.size.height/2 + self.lockDialog!.size.width / 14))
                    let salesText = SKMultilineLabel(text: sale!.salesText!, labelWidth: Int(self.lockDialog!.size.width), pos: pos, fontSize: self.lockDialog!.size.width / 12)
                    salesText.fontColor = UIColor.black
                    self.lockDialog?.addChild(salesText)
                    
                    labelY = salesText.position.y - (salesText.fontSize * 1.5)
                }
                
                let label = SKLabelNode(text: "This is a premium game.")
                label.fontColor = UIColor.black
                label.fontSize = self.lockDialog!.size.width / 12
                label.fontName = "ChalkboardSE-Regular"
                label.position = CGPoint(x: 0, y: labelY - label.fontSize)
                self.lockDialog?.addChild(label)
                if (!tryAvailable) {
                    let label2 = SKLabelNode(text: "Upgrade to play again.")
                    label2.fontSize = self.lockDialog!.size.width / 12
                    label2.fontColor = UIColor.black
                    label2.fontName = "ChalkboardSE-Regular"
                    label2.position = CGPoint(x: 0, y: label.position.y - label2.fontSize)
                    self.lockDialog?.addChild(label2)
                    
                    let buyButton = EventSprite(imageNamed: buyImg)
                    buyButton.topic = LittleFamilyScene.TOPIC_BUY_PRESSED
                    buyButton.isUserInteractionEnabled = true
                    buyButton.position = CGPoint(x: 0, y: label2.position.y - label2.frame.height / 2 - buyButton.size.height / 2)
                    self.lockDialog?.addChild(buyButton)
                } else {
                    let label2 = SKLabelNode(text: "You have \(tries) tries left.")
                    if tries == 1 {
                        label2.text = "You have 1 try left."
                    }
                    label2.fontSize = self.lockDialog!.size.width / 12
                    label2.fontColor = UIColor.black
                    label2.fontName = "ChalkboardSE-Regular"
                    label2.position = CGPoint(x: 0, y: label.position.y - label2.fontSize)
                    self.lockDialog?.addChild(label2)
                    
                    let tryButton = EventSprite(imageNamed: "tryButton")
                    tryButton.topic = LittleFamilyScene.TOPIC_TRY_PRESSED
                    tryButton.isUserInteractionEnabled = true
                    tryButton.position = CGPoint(x: -tryButton.size.width / 2, y: label2.position.y - label2.frame.height / 2 - tryButton.size.height / 2)
                    self.lockDialog?.addChild(tryButton)
                    
                    let buyButton = EventSprite(imageNamed: buyImg)
                    buyButton.topic = LittleFamilyScene.TOPIC_BUY_PRESSED
                    buyButton.isUserInteractionEnabled = true
                    buyButton.position = CGPoint(x: buyButton.size.width / 2, y: label2.position.y - label2.frame.height / 2 - buyButton.size.height / 2)
                    self.lockDialog?.addChild(buyButton)
                }
                
                self.addChild(self.lockDialog!)

            })
        }
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
    
    func prepareDialogRect(_ width:CGFloat, height:CGFloat) -> CGRect {
        graybox = SKSpriteNode(color: UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.7), size: self.size)
        graybox!.isUserInteractionEnabled = true
        graybox!.zPosition = 100
        graybox!.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        self.addChild(graybox!)
        self.dialogOpen = true
        
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
        self.dialogOpen = false
        if graybox != nil {
            graybox!.removeFromParent()
        }
    }
    
    func userHasPremium(_ onCompletion: @escaping (Bool) -> Void) {
        onCompletion(true)
        /*
        let premiumStr = DataService.getInstance().dbHelper.getProperty(LittleFamilyScene.PROP_HAS_PREMIUM)
        if premiumStr == nil || premiumStr != "true" {
            let username = DataService.getInstance().getEncryptedProperty(DataService.SERVICE_USERNAME)
			let serviceType = DataService.getInstance().dbHelper.getProperty(DataService.SERVICE_TYPE)
            if username != nil && serviceType != nil {
                let encodedUsername = DataService.getInstance().dbHelper.removeSpecialCharsFromString(text: username!)
                if connectedToNetwork() {
                    let ref = Database.database().reference()
                    ref.child("users").child(serviceType!).child(encodedUsername).observeSingleEvent(of: .value, with: { (snap) in
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
                } else {
                    print("No internet connection")
                    onCompletion(false)
                }
            } else {
                onCompletion(false)
            }
        } else {
            if premiumStr == "true" {
                onCompletion(true)
            } else {
                onCompletion(false)
            }
        }
         */
    }
    
    var iapHelper:IAPHelper?
    func onProductsReady(_ productsArray: [SKProduct]) {
        iapHelper!.buyProduct(0)
        buyError = false
    }
    func onTransactionComplete() {
        DataService.getInstance().dbHelper.saveProperty(LittleFamilyScene.PROP_HAS_PREMIUM, value: "true")
        DataService.getInstance().dbHelper.fireCreateOrUpdateUser(true)
        hideLoadingDialog()
    }
    func onError(_ error:String) {
        print(error)
        hideLoadingDialog()
        buyError = true
        showSimpleDialog("Error", message: error)
    }
    
    func buyPremium() {
        showLoadingDialog()
        if iapHelper == nil {
            iapHelper = IAPHelper(listener: self)
        }
        iapHelper?.requestProductInfo()
    }
    
    func connectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
}
