//
//  SongScene.swift
//  Little Family Tree
//
//  Created by Melissa on 2/22/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class SongScene: LittleFamilyScene, TreeWalkerListener {
    static var TOPIC_PERSON_TOUCHED = "topic_person_touched"
    static var TOPIC_PLAY_SONG = "playPauseSong"
    static var TOPIC_PLAY_RESET = "resetStage"
	static var TOPIC_TOGGLE_PIANO = "togglePiano"
	static var TOPIC_TOGGLE_DRUMS = "toggleDrums"
	static var TOPIC_TOGGLE_FLUTE = "toggleFlute"
	static var TOPIC_TOGGLE_VIOLIN = "toggleViolin"
    static var TOPIC_TOGGLE_BASS = "toggleBass"
    static var TOPIC_TOGGLE_GUITAR = "toggleGuitar"
    static var TOPIC_CHOOSE_SONG1 = "chooseSong1"
    static var TOPIC_CHOOSE_SONG2 = "chooseSong2"
    static var TOPIC_CHOOSE_SONG3 = "chooseSong3"
	
    var stage:SKSpriteNode?
	var xOffset = CGFloat(0)
	var yOffset = CGFloat(0)
	var manWidth = CGFloat(0)
	var womanWidth = CGFloat(0)
	var personWidth = CGFloat(0)
	
	var song1Button:EventSprite?
	var song2Button:EventSprite?
	var song3Button:EventSprite?
	var song4Button:EventSprite?
	
	var drumKit:AnimatedStateSprite?
	var gPiano:AnimatedStateSprite?
	var violin:AnimatedStateSprite?
	var bass:AnimatedStateSprite?
	var clarinet:AnimatedStateSprite?
	var guitar:AnimatedStateSprite?
	
	var selPerson1:SKSpriteNode?
	var selPerson2:SKSpriteNode?
	var selPerson3:SKSpriteNode?
	var selPerson4:SKSpriteNode?
	
	var playButton:AnimatedStateSprite?
	var resetButton:EventSprite?
	
	var peopleHolder:SKSpriteNode?
	
	var peopleSprites = [PersonNameSprite]()
	var onStage = [PersonNameSprite]()
	
	var treeWalker:TreeWalker?
	var songAlbum:SongAlbum?
    var song:Song?
    
    var drumsOn = true
    var fluteOn = true
    var violinOn = true
    var pianoOn = true
    
    var lastPoint:CGPoint?
    var movingPerson:PersonNameSprite?
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        self.size.width = view.bounds.width
        self.size.height = view.bounds.height
        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        let background = SKSpriteNode(imageNamed: "puzzle_background")
        background.position = CGPointMake(self.size.width/2, self.size.height/2)
        background.size.width = self.size.width
        background.size.height = self.size.height
        background.zPosition = 0
        self.addChild(background)
		
		songAlbum = SongAlbum(person: selectedPerson!)
        
		setupTopBar()
		
		var height = self.size.height - topBar!.size.height
        var width = min(self.size.width, height)
        if width == self.size.width {
            width = width * 0.8
        }
        
        personWidth = width * CGFloat(0.20);
        if personWidth > 250 {
            personWidth = CGFloat(250)
        }
		
		let stageTexture = SKTexture(imageNamed: "stage")
        var ratio = stageTexture.size().width / stageTexture.size().height
        height = width / ratio
		xOffset = (self.size.width - width - personWidth) / CGFloat(2)
		yOffset = (self.size.height - (height + topBar!.size.height)) / CGFloat(2)
        
        stage = SKSpriteNode(texture: stageTexture)
        stage?.size = CGSizeMake(width, height)
        stage?.zPosition = 1
        stage?.position = CGPointMake(xOffset + width / 2, yOffset + height / 2)
        self.addChild(stage!)
		
		peopleHolder = SKSpriteNode()
		peopleHolder?.zPosition = 3
		peopleHolder?.position = CGPointMake(10 + stage!.position.x + stage!.size.width / 2, topBar!.position.y - topBar!.size.height * 3)
		self.addChild(peopleHolder!)
		
		manWidth = stage!.size.width / CGFloat(7)
        womanWidth = manWidth + 4
		
		song1Button = EventSprite(imageNamed:"song1")
		ratio = song1Button!.size.height / song1Button!.size.width
		song1Button?.size = CGSizeMake(personWidth * 1.7, personWidth * 1.7 * ratio)
		song1Button?.zPosition = 2
		song1Button?.position = CGPointMake(xOffset + 15 + song1Button!.size.width / 2, yOffset + 50 + song1Button!.size.height / 2)
		song1Button?.userInteractionEnabled = true
		song1Button?.topic = SongScene.TOPIC_CHOOSE_SONG1
		self.addChild(song1Button!)
		
		song2Button = EventSprite(imageNamed:"song2")
		ratio = song2Button!.size.height / song2Button!.size.width
		song2Button?.size = CGSizeMake(personWidth * 1.7, personWidth * 1.7 * ratio)
		song2Button?.zPosition = 2
		song2Button?.position = CGPointMake(xOffset + (stage!.size.width / 2), yOffset + 20 + song2Button!.size.height / 2)
		song2Button?.userInteractionEnabled = true
		song2Button?.topic = SongScene.TOPIC_CHOOSE_SONG2
		self.addChild(song2Button!)
		
		song3Button = EventSprite(imageNamed:"song3")
		ratio = song3Button!.size.height / song3Button!.size.width
		song3Button?.size = CGSizeMake(personWidth * 1.7, personWidth * 1.7 * ratio)
		song3Button?.zPosition = 2
		song3Button?.position = CGPointMake(xOffset + 30 + stage!.size.width - song3Button!.size.width, yOffset + 25 + song3Button!.size.height / 2)
		song3Button?.userInteractionEnabled = true
		song3Button?.topic = SongScene.TOPIC_CHOOSE_SONG3
		self.addChild(song3Button!)
		
		drumKit = AnimatedStateSprite(imageNamed: "drums")
		ratio = drumKit!.size.height / drumKit!.size.width
		drumKit?.zPosition = 3
		drumKit?.size = CGSizeMake(personWidth * 1.7, personWidth * 1.7 * ratio)
		drumKit?.position = CGPointMake(xOffset + 10 + drumKit!.size.width / 2, yOffset + 55 + drumKit!.size.height / 2)
		drumKit?.addEvent(0, topic: SongScene.TOPIC_TOGGLE_DRUMS)
		drumKit?.addEvent(1, topic: SongScene.TOPIC_TOGGLE_DRUMS)
		drumKit?.addTexture(1, texture: SKTexture(imageNamed: "drums_off"))
		drumKit?.userInteractionEnabled = true
		drumKit?.hidden = true
		self.addChild(drumKit!)
		
		gPiano = AnimatedStateSprite(imageNamed: "piano")
		ratio = gPiano!.size.height / gPiano!.size.width
		gPiano?.zPosition = 3
		gPiano?.size = CGSizeMake(personWidth * 1.7, personWidth * 1.7 * ratio)
		gPiano?.position = CGPointMake(xOffset + stage!.size.width - (15 + gPiano!.size.width / 2), yOffset + 35 + gPiano!.size.height / 2)
		gPiano?.addEvent(0, topic: SongScene.TOPIC_TOGGLE_PIANO)
		gPiano?.addEvent(1, topic: SongScene.TOPIC_TOGGLE_PIANO)
		gPiano?.addTexture(1, texture: SKTexture(imageNamed: "piano_off"))
		gPiano?.userInteractionEnabled = true
		gPiano?.hidden = true
		self.addChild(gPiano!)
		
		violin = AnimatedStateSprite(imageNamed: "violin")
		ratio = violin!.size.height / violin!.size.width
		violin?.zPosition = 3
		violin?.size = CGSizeMake(personWidth * 1.7 / ratio, personWidth * 1.7)
		violin?.position = CGPointMake(xOffset + (stage!.size.width / 2) - (violin!.size.width / 3), yOffset + violin!.size.height / 2)
		violin?.addEvent(0, topic: SongScene.TOPIC_TOGGLE_VIOLIN)
		violin?.addEvent(1, topic: SongScene.TOPIC_TOGGLE_VIOLIN)
		violin?.addTexture(1, texture: SKTexture(imageNamed: "violin_off"))
		violin?.userInteractionEnabled = true
		violin?.hidden = true
		self.addChild(violin!)
		
		bass = AnimatedStateSprite(imageNamed: "bass")
		ratio = bass!.size.height / bass!.size.width
		bass?.zPosition = 3
		bass?.size = CGSizeMake(personWidth * 1.7 / ratio, personWidth * 1.7)
		bass?.position = CGPointMake(xOffset + (stage!.size.width / 2) - (bass!.size.width / 3), yOffset + bass!.size.height / 2)
		bass?.addEvent(0, topic: SongScene.TOPIC_TOGGLE_BASS)
		bass?.addEvent(1, topic: SongScene.TOPIC_TOGGLE_BASS)
		bass?.addTexture(1, texture: SKTexture(imageNamed: "bass_off"))
		bass?.userInteractionEnabled = true
		bass?.state = 1
		bass?.hidden = true
		self.addChild(bass!)
		
		clarinet = AnimatedStateSprite(imageNamed: "clarinet")
		ratio = clarinet!.size.height / clarinet!.size.width
		clarinet?.zPosition = 3
		clarinet?.size = CGSizeMake(personWidth * 1.7 / ratio, personWidth * 1.7)
		clarinet?.position = CGPointMake(xOffset + (stage!.size.width / 2) - (clarinet!.size.width / 3), yOffset + 20 + clarinet!.size.height / 2)
		clarinet?.addEvent(0, topic: SongScene.TOPIC_TOGGLE_FLUTE)
		clarinet?.addEvent(1, topic: SongScene.TOPIC_TOGGLE_FLUTE)
		clarinet?.addTexture(1, texture: SKTexture(imageNamed: "clarinet_off"))
		clarinet?.userInteractionEnabled = true
		clarinet?.hidden = true
		self.addChild(clarinet!)
		
		guitar = AnimatedStateSprite(imageNamed: "guitar")
		ratio = guitar!.size.height / guitar!.size.width
		guitar?.zPosition = 3
		guitar?.size = CGSizeMake(personWidth * 1.7 / ratio, personWidth * 1.7)
		guitar?.position = CGPointMake(xOffset + (stage!.size.width / 2) - (guitar!.size.width / 3), yOffset + 20 + guitar!.size.height / 2)
		guitar?.addEvent(0, topic: SongScene.TOPIC_TOGGLE_GUITAR)
		guitar?.addEvent(1, topic: SongScene.TOPIC_TOGGLE_GUITAR)
		guitar?.addTexture(1, texture: SKTexture(imageNamed: "guitar_off"))
		guitar?.userInteractionEnabled = true
		guitar?.hidden = true
		self.addChild(guitar!)
		
		selPerson1 = SKSpriteNode(imageNamed: "man_silhouette")
		ratio = selPerson1!.size.height / selPerson1!.size.width
		selPerson1?.zPosition = 3
		selPerson1?.size = CGSizeMake(manWidth, manWidth * ratio)
		selPerson1?.position = CGPointMake(xOffset + personWidth * 1.5, yOffset + stage!.size.height/2)
		self.addChild(selPerson1!)
		
		selPerson2 = SKSpriteNode(imageNamed: "woman_silhouette")
		ratio = selPerson2!.size.height / selPerson2!.size.width
		selPerson2?.zPosition = 3
		selPerson2?.size = CGSizeMake(womanWidth, womanWidth * ratio)
		selPerson2?.position = CGPointMake(selPerson1!.position.x + selPerson1!.size.width, selPerson1!.position.y)
		self.addChild(selPerson2!)
		
		selPerson3 = SKSpriteNode(imageNamed: "man_silhouette")
		ratio = selPerson3!.size.height / selPerson3!.size.width
		selPerson3?.zPosition = 3
		selPerson3?.size = CGSizeMake(manWidth, manWidth * ratio)
		selPerson3?.position = CGPointMake(selPerson2!.position.x + selPerson2!.size.width, selPerson2!.position.y)
		self.addChild(selPerson3!)
		
		selPerson4 = SKSpriteNode(imageNamed: "woman_silhouette")
		ratio = selPerson4!.size.height / selPerson4!.size.width
		selPerson4?.zPosition = 3
		selPerson4?.size = CGSizeMake(womanWidth, womanWidth * ratio)
		selPerson4?.position = CGPointMake(selPerson3!.position.x + selPerson3!.size.width, selPerson3!.position.y)
		self.addChild(selPerson4!)
		
		playButton = AnimatedStateSprite(imageNamed: "media_play")
		ratio = playButton!.size.height / playButton!.size.width
		playButton?.zPosition = 3
		playButton?.size = CGSizeMake(personWidth, personWidth * ratio)
		playButton?.position = CGPointMake(xOffset + (stage!.size.width / 2) - personWidth, yOffset + stage!.size.height - 60)
		playButton?.addEvent(0, topic: SongScene.TOPIC_PLAY_SONG)
		playButton?.addEvent(1, topic: SongScene.TOPIC_PLAY_SONG)
		playButton?.addTexture(1, texture: SKTexture(imageNamed: "media_pause"))
		playButton?.userInteractionEnabled = true
		playButton?.hidden = true
		self.addChild(playButton!)
		
		resetButton = EventSprite(imageNamed: "media_reset")
		ratio = resetButton!.size.height / resetButton!.size.width
		resetButton?.zPosition = 3
		resetButton?.size = CGSizeMake(personWidth, personWidth * ratio)
		resetButton?.position = CGPointMake(xOffset + (stage!.size.width / 2) + personWidth, yOffset + stage!.size.height - 60)
		resetButton?.topic = SongScene.TOPIC_PLAY_RESET
		resetButton?.userInteractionEnabled = true
		resetButton?.hidden = true
		self.addChild(resetButton!)
		
		EventHandler.getInstance().subscribe(SongScene.TOPIC_PERSON_TOUCHED, listener: self)
        EventHandler.getInstance().subscribe(SongScene.TOPIC_PLAY_SONG, listener: self)
		EventHandler.getInstance().subscribe(SongScene.TOPIC_PLAY_RESET, listener: self)
        EventHandler.getInstance().subscribe(SongScene.TOPIC_TOGGLE_PIANO, listener: self)
		EventHandler.getInstance().subscribe(SongScene.TOPIC_TOGGLE_DRUMS, listener: self)
		EventHandler.getInstance().subscribe(SongScene.TOPIC_TOGGLE_FLUTE, listener: self)
		EventHandler.getInstance().subscribe(SongScene.TOPIC_TOGGLE_VIOLIN, listener: self)
		EventHandler.getInstance().subscribe(SongScene.TOPIC_TOGGLE_BASS, listener: self)
		EventHandler.getInstance().subscribe(SongScene.TOPIC_TOGGLE_GUITAR, listener: self)
		EventHandler.getInstance().subscribe(SongScene.TOPIC_CHOOSE_SONG1, listener: self)
		EventHandler.getInstance().subscribe(SongScene.TOPIC_CHOOSE_SONG2, listener: self)
		EventHandler.getInstance().subscribe(SongScene.TOPIC_CHOOSE_SONG3, listener: self)
        
        treeWalker = TreeWalker(person: selectedPerson!, listener:self)
        treeWalker!.loadFamilyMembers()
    }
    
    override func willMoveFromView(view: SKView) {
        super.willMoveFromView(view)
		
		EventHandler.getInstance().unSubscribe(SongScene.TOPIC_PERSON_TOUCHED, listener: self)
        EventHandler.getInstance().unSubscribe(SongScene.TOPIC_PLAY_SONG, listener: self)
		EventHandler.getInstance().unSubscribe(SongScene.TOPIC_PLAY_RESET, listener: self)
        EventHandler.getInstance().unSubscribe(SongScene.TOPIC_TOGGLE_PIANO, listener: self)
		EventHandler.getInstance().unSubscribe(SongScene.TOPIC_TOGGLE_DRUMS, listener: self)
		EventHandler.getInstance().unSubscribe(SongScene.TOPIC_TOGGLE_FLUTE, listener: self)
		EventHandler.getInstance().unSubscribe(SongScene.TOPIC_TOGGLE_VIOLIN, listener: self)
		EventHandler.getInstance().unSubscribe(SongScene.TOPIC_TOGGLE_BASS, listener: self)
		EventHandler.getInstance().unSubscribe(SongScene.TOPIC_TOGGLE_GUITAR, listener: self)
		EventHandler.getInstance().unSubscribe(SongScene.TOPIC_CHOOSE_SONG1, listener: self)
		EventHandler.getInstance().unSubscribe(SongScene.TOPIC_CHOOSE_SONG2, listener: self)
		EventHandler.getInstance().unSubscribe(SongScene.TOPIC_CHOOSE_SONG3, listener: self)
    }
	
	func onComplete(family:[LittlePerson]) {
		peopleSprites.removeAll()
		peopleHolder!.removeAllChildren()
		
		let x = CGFloat(0)
		var y = CGFloat(0)  
		for person in family {
			let sprite = PersonNameSprite()
			//sprite.userInteractionEnabled = true
			sprite.position = CGPointMake(x, y)
			sprite.size.width = personWidth
			sprite.size.height = personWidth
			sprite.showLabel = false
			sprite.person = person
			//sprite.topic = ChoosePlayerScene.TOPIC_CHOOSE_PERSON
			self.peopleHolder!.addChild(sprite)
			self.peopleSprites.append(sprite)
			
			y = y - (personWidth - 15)
		}
	}
    
    override func update(currentTime: NSTimeInterval) {
        super.update(currentTime)
    }
    
    func showInstruments() {
        speak("Place your dancers on stage")
        
        song1Button?.hidden = true
        song2Button?.hidden = true
        song3Button?.hidden = true
        
        playButton?.hidden = false
        resetButton?.hidden = false
        
        for instrument in song!.instruments {
            if instrument=="drums" {
                drumKit?.hidden = false
                drumKit?.state = drumsOn ? 0 : 1
            }
            else if instrument=="flute" {
                clarinet?.hidden = false
                clarinet?.state = fluteOn ? 0 : 1
            }
            else if instrument=="violin" {
                violin?.hidden = false
                violin?.state = violinOn ? 0 : 1
            }
            else if instrument=="piano" {
                gPiano?.hidden = false
                gPiano?.state = pianoOn ? 0 : 1
            }
            else if instrument=="bass" {
                bass?.hidden = false
                bass?.state = fluteOn ? 0 : 1
            }
            else if instrument=="guitar" {
                guitar?.hidden = false
                guitar?.state = violinOn ? 0 : 1
            }
        }
    }
    
    func showSongButtons() {
        speak("Choose a song")
        
        song1Button?.hidden = false
        song2Button?.hidden = false
        song3Button?.hidden = false
        
        drumKit?.hidden = true
        clarinet?.hidden = true
        violin?.hidden = true
        gPiano?.hidden = true
        guitar?.hidden = true
        bass?.hidden = true
        
        playButton?.hidden = true
        resetButton?.hidden = true
    }
	
	override func onEvent(topic: String, data: NSObject?) {
        super.onEvent(topic, data: data)
		if topic == SongScene.TOPIC_CHOOSE_SONG1 {
			self.song = songAlbum!.songs[0]
            showInstruments()
		}
        else if topic == SongScene.TOPIC_CHOOSE_SONG2 {
            self.song = songAlbum!.songs[1]
            showInstruments()
        }
        else if topic == SongScene.TOPIC_CHOOSE_SONG3 {
            self.song = songAlbum!.songs[2]
            showInstruments()
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        movingPerson = nil
        for touch in touches {
            lastPoint = touch.locationInNode(self)
            let touchedNode = nodeAtPoint(lastPoint!)
            if touchedNode is PersonNameSprite {
            }
            break
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
    }
}
