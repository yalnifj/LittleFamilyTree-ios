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
	
	var song1Button:EventSprite?
	var song2Button:EventSprite?
	var song3Button:EventSprite?
	var song4Button:EventSprite?
	
    
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
        
		setupTopBar()
		
		var height = self.size.height - topBar!.size.height
        var width = min(self.size.width, height)
        if width == self.size.width {
            width = width * 0.8
        }
		
		let stageTexture = SKTexture(imageNamed: "stage")
        let ratio = stageTexture.size().width / stageTexture.size().height
        height = width / ratio
		xOffset = (self.size.width - width) / CGFloat(2)
		yOffset = (self.size.height - (height + topBar!.size.height)) / CGFloat(2)
        
        stage = SKSpriteNode(texture: stageTexture)
        stage?.size = CGSizeMake(width, height)
        stage?.zPosition = 1
        stage?.position = CGPointMake(xOffset + width / 2, yOffset + height / 2)
        self.addChild(stage!)
		
		manWidth = stage.size.width / CGFloat(7)
        womanWidth = manWidth + 4
		
		var personWidth = width * CGFloat(0.17);
		if personWidth > 250 {
			personWidth = CGFloat(250)
		}
		
		song1Button = EventSprite(imageNamed:"song1")
		song1Button?.size = CGSizeMake(personWidth * 1.7, personWidth * 1.7)
		song1Button?.zPosition = 2
		song1Button?.position = CGPointMake(xOffset + 15 + song1Button!.size.width / 2, yOffset + 50 + song1Button!.size.height / 2)
		song1Button?.userInteractionEnabled = true
		song1Button?.topic = SongScene.TOPIC_CHOOSE_SONG1
		self.addChild(song1Button!)
		
		song2Button = EventSprite(imageNamed:"song2")
		song2Button?.size = CGSizeMake(personWidth * 1.7, personWidth * 1.7)
		song2Button?.zPosition = 2
		song2Button?.position = CGPointMake(xOffset + (stage!.size.width / 2) - song2Button!.size.width / 2, yOffset + 20 + song2Button!.size.height / 2)
		song2Button?.userInteractionEnabled = true
		song2Button?.topic = SongScene.TOPIC_CHOOSE_SONG2
		self.addChild(song2Button!)
		
		song3Button = EventSprite(imageNamed:"song3")
		song3Button?.size = CGSizeMake(personWidth * 1.7, personWidth * 1.7)
		song3Button?.zPosition = 2
		song3Button?.position = CGPointMake(xOffset + 15 + stage!.size.width - song3Button!.size.width / 2, yOffset + 55 + song3Button!.size.height / 2)
		song3Button?.userInteractionEnabled = true
		song3Button?.topic = SongScene.TOPIC_CHOOSE_SONG3
		self.addChild(song3Button!)
        
        showLoadingDialog()
		
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
	}
    
    override func update(currentTime: NSTimeInterval) {
        super.update(currentTime)
    }

}
