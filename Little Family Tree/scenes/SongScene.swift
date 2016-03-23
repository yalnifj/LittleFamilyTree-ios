//
//  SongScene.swift
//  Little Family Tree
//
//  Created by Melissa on 2/22/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

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
	
	var peopleSprites = [PersonNameSprite]()
	var onStage = [PersonNameSprite]()
	
	var treeWalker:TreeWalker?
	var songAlbum:SongAlbum?
    var song:Song?
    
    var drumsOn = true
    var fluteOn = true
    var violinOn = true
    var pianoOn = true
	
	var drumTrack:AVAudioPlayer?
	var fluteTrack:AVAudioPlayer?
	var violinTrack:AVAudioPlayer?
	var pianoTrack:AVAudioPlayer?
	var voiceTrack:AVAudioPlayer?
	
	var songPlaying = false
	var songPaused = false
    
    var lastPoint:CGPoint?
    var movingPerson:PersonNameSprite?
    var songChosen = false
    var scrolling = false
    var dropReady = false
    
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
        let growAction = SKAction.scaleTo(1.1, duration: 1.0)
        let shrinkAction = SKAction.scaleTo(1.0, duration: 1.0)
        let waitAction = SKAction.waitForDuration(2.0)
        let gswAction = SKAction.sequence([growAction, shrinkAction, waitAction, waitAction])
        let repeatAction = SKAction.repeatActionForever(gswAction)
        song1Button?.runAction(repeatAction)
		
		song2Button = EventSprite(imageNamed:"song2")
		ratio = song2Button!.size.height / song2Button!.size.width
		song2Button?.size = CGSizeMake(personWidth * 1.7, personWidth * 1.7 * ratio)
		song2Button?.zPosition = 2
		song2Button?.position = CGPointMake(xOffset + (stage!.size.width / 2), yOffset + 20 + song2Button!.size.height / 2)
		song2Button?.userInteractionEnabled = true
		song2Button?.topic = SongScene.TOPIC_CHOOSE_SONG2
		self.addChild(song2Button!)
        let gswAction2 = SKAction.sequence([waitAction, growAction, shrinkAction, waitAction])
        let repeatAction2 = SKAction.repeatActionForever(gswAction2)
        song2Button?.runAction(repeatAction2)
		
		song3Button = EventSprite(imageNamed:"song3")
		ratio = song3Button!.size.height / song3Button!.size.width
		song3Button?.size = CGSizeMake(personWidth * 1.7, personWidth * 1.7 * ratio)
		song3Button?.zPosition = 2
		song3Button?.position = CGPointMake(xOffset + 30 + stage!.size.width - song3Button!.size.width, yOffset + 25 + song3Button!.size.height / 2)
		song3Button?.userInteractionEnabled = true
		song3Button?.topic = SongScene.TOPIC_CHOOSE_SONG3
		self.addChild(song3Button!)
        let gswAction3 = SKAction.sequence([waitAction, waitAction, growAction, shrinkAction])
        let repeatAction3 = SKAction.repeatActionForever(gswAction3)
        song3Button?.runAction(repeatAction3)
		
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
		violin?.position = CGPointMake(xOffset + (stage!.size.width / 2) + (violin!.size.width / 3), yOffset + violin!.size.height / 2)
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
		playButton?.position = CGPointMake(xOffset + (stage!.size.width / 2) - personWidth / 2, yOffset + stage!.size.height - 60)
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
		resetButton?.position = CGPointMake(xOffset + (stage!.size.width / 2) + personWidth / 2, yOffset + stage!.size.height - 60)
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
        speak("Choose a song.")
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
        for s in peopleSprites {
            s.removeFromParent()
        }
        for s in onStage {
            s.removeFromParent()
        }
		peopleSprites.removeAll()
        onStage.removeAll()
		
		let x = 10 + stage!.position.x + stage!.size.width / 2
		var y = topBar!.position.y - topBar!.size.height * 3
		for person in family {
			let sprite = PersonNameSprite()
			//sprite.userInteractionEnabled = true
			sprite.position = CGPointMake(x, y)
			sprite.size.width = personWidth
			sprite.size.height = personWidth
			sprite.showLabel = false
			sprite.person = person
			//sprite.topic = ChoosePlayerScene.TOPIC_CHOOSE_PERSON
			self.addChild(sprite)
			self.peopleSprites.append(sprite)
			
			y = y - (personWidth - 15)
		}
        if family.count < 4 {
            self.treeWalker?.loadMorePeople()
        }
	}
    
    override func update(currentTime: NSTimeInterval) {
        super.update(currentTime)
        if dropReady {
            selPerson1!.setScale(1.1)
            selPerson2!.setScale(1.1)
            selPerson3!.setScale(1.1)
            selPerson4!.setScale(1.1)
        } else {
            selPerson1!.setScale(1.0)
            selPerson2!.setScale(1.0)
            selPerson3!.setScale(1.0)
            selPerson4!.setScale(1.0)
        }
    }
    
    func showInstruments() {
        speak("Place your dancers on stage")
        
        song1Button?.hidden = true
        song2Button?.hidden = true
        song3Button?.hidden = true
        
        playButton?.hidden = false
        resetButton?.hidden = false
        
        songChosen = true
        
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
        speak("Place your dancers on stage.")
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
        songChosen = false
        speak("Choose a song.")
    }
    
    func reorderPeople() {
        let x = 10 + stage!.position.x + stage!.size.width / 2
        var y = topBar!.position.y - topBar!.size.height * 3
        for s in self.peopleSprites {
            let act = SKAction.moveTo(CGPointMake(x, y), duration: 1.0)
            s.runAction(act)
            y = y - (personWidth - 15)
        }
    }
	
	func resetSong() {
		songPlaying = false
		songPaused = false
        for ds in onStage {
            peopleSprites.insert(ds, atIndex: 0)
        }
        reorderPeople()
        setupSong()
    }
    
    func setupSong() {
		let drumTrackUrl = NSURL(fileURLWithPath: song!.drumTrack!)
        do {
            drumTrack = try AVAudioPlayer(contentsOfURL: drumTrackUrl)
        } catch {
            drumTrack = nil
        }
		if drumsOn {
			drumTrack!.volume = 1.0
		} else {
			drumTrack!.volume = 0.0
		}
		let fluteTrackUrl = NSURL(fileURLWithPath: song!.fluteTrack!)
        do {
            fluteTrack = try AVAudioPlayer(contentsOfURL: fluteTrackUrl)
        } catch {
            fluteTrack = nil
        }
		if fluteOn {
			fluteTrack!.volume = 1.0
		} else {
			fluteTrack!.volume = 0.0
		}
		let violinTrackUrl = NSURL(fileURLWithPath: song!.violinTrack!)
        do {
            violinTrack = try AVAudioPlayer(contentsOfURL: violinTrackUrl)
        } catch {
            violinTrack = nil
        }
		if violinOn {
			violinTrack!.volume = 1.0
		} else {
			violinTrack!.volume = 0.0
		}
		let pianoTrackUrl = NSURL(fileURLWithPath: song!.pianoTrack!)
        do {
            pianoTrack = try AVAudioPlayer(contentsOfURL: pianoTrackUrl)
        } catch {
            pianoTrack = nil
        }
		if pianoOn {
			pianoTrack!.volume = 1.0
		} else {
			pianoTrack!.volume = 0.0
		}
		let voiceTrackUrl = NSURL(fileURLWithPath: song!.voiceTrack!)
        do {
            voiceTrack = try AVAudioPlayer(contentsOfURL: voiceTrackUrl)
        } catch {
            voiceTrack = nil
        }
	}
	
	func playSong() {
        if !songPlaying {
            while onStage.count < 4 && peopleSprites.count > 0 {
                let ds = peopleSprites.removeFirst()
                var moveToSprite = selPerson1!
                if onStage.count == 2 {
                    moveToSprite = selPerson2!
                } else if onStage.count == 3 {
                    moveToSprite = selPerson3!
                } else if onStage.count == 4 {
                    moveToSprite = selPerson4!
                }
                let act = SKAction.moveTo(moveToSprite.position, duration: 1.0)
                ds.runAction(act)
                onStage.append(ds)
            }
            for ds in onStage {
                let act1 = SKAction.rotateToAngle(0.43, duration: 1.0)
                let act2 = SKAction.rotateToAngle(-0.43, duration: 1.0)
                let act3 = SKAction.sequence([act1, act2])
                let act4 = SKAction.repeatActionForever(act3)
                ds.runAction(act4)
            }
        } else {
            for ds in onStage {
                ds.paused = false
            }
        }
		songPlaying = true
		if songPaused {
			if drumTrack != nil {
				drumTrack!.play()
			}
			if fluteTrack != nil {
				fluteTrack!.play()
			}
			if violinTrack != nil {
				violinTrack!.play()
			}
			if pianoTrack != nil {
				pianoTrack!.play()
			}
			if voiceTrack != nil {
				voiceTrack!.play()
			}
		}
        songPaused = false
	}
	
	func pauseSong() {
		songPaused = true
        for ds in onStage {
            ds.paused = true
        }
		if drumTrack != nil {
			drumTrack!.pause()
		}
		if fluteTrack != nil {
			fluteTrack!.pause()
		}
		if violinTrack != nil {
			violinTrack!.pause()
		}
		if pianoTrack != nil {
			pianoTrack!.pause()
		}
		if voiceTrack != nil {
			voiceTrack!.pause()
		}
	}
	
	override func onEvent(topic: String, data: NSObject?) {
        super.onEvent(topic, data: data)
		if topic == SongScene.TOPIC_CHOOSE_SONG1 {
			self.song = songAlbum!.songs[0]
            showInstruments()
            setupSong()
		}
        else if topic == SongScene.TOPIC_CHOOSE_SONG2 {
            self.song = songAlbum!.songs[1]
            showInstruments()
            setupSong()
        }
        else if topic == SongScene.TOPIC_CHOOSE_SONG3 {
            self.song = songAlbum!.songs[2]
            showInstruments()
            setupSong()
        } else if topic == SongScene.TOPIC_PLAY_SONG {
            if !songPlaying {
                playSong()
            } else {
                if songPaused {
                    playSong()
                } else {
                    pauseSong()
                }
            }
			
		} else if topic == SongScene.TOPIC_PLAY_RESET {
            resetSong()
		} else if topic == SongScene.TOPIC_TOGGLE_DRUMS {
			drumsOn = !drumsOn
			if drumTrack != nil {
				if drumsOn {
					drumTrack!.volume = 1.0
					drumKit!.state = 0
				} else {
					drumTrack!.volume = 0.0
					drumKit!.state = 1
				}
			}
		} else if topic == SongScene.TOPIC_TOGGLE_BASS {
			fluteOn = !fluteOn
			if fluteTrack != nil {
				if fluteOn {
					fluteTrack!.volume = 1.0
					bass!.state = 0
				} else {
					fluteTrack!.volume = 0.0
					bass!.state = 1
				}
			}
		} else if topic == SongScene.TOPIC_TOGGLE_FLUTE {
			fluteOn = !fluteOn
			if fluteTrack != nil {
				if fluteOn {
					fluteTrack!.volume = 1.0
					clarinet!.state = 0
				} else {
					fluteTrack!.volume = 0.0
					clarinet!.state = 1
				}
			}
		} else if topic == SongScene.TOPIC_TOGGLE_GUITAR {
			violinOn = !violinOn
			if violinTrack != nil {
				if violinOn {
					violinTrack!.volume = 1.0
					guitar!.state = 0
				} else {
					violinTrack!.volume = 0.0
					guitar!.state = 1
				}
			}
		} else if topic == SongScene.TOPIC_TOGGLE_VIOLIN {
			violinOn = !violinOn
			if violinTrack != nil {
				if violinOn {
					violinTrack!.volume = 1.0
					violin!.state = 0
				} else {
					violinTrack!.volume = 0.0
					violin!.state = 1
				}
			}
		} else if topic == SongScene.TOPIC_TOGGLE_PIANO {
			pianoOn = !pianoOn
			if pianoTrack != nil {
				if pianoOn {
					pianoTrack!.volume = 1.0
					gPiano!.state = 0
				} else {
					pianoTrack!.volume = 0.0
					gPiano!.state = 1
				}
			}
		}
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        movingPerson = nil
        for touch in touches {
            lastPoint = touch.locationInNode(self)
            if lastPoint!.x >= self.stage!.position.x + self.stage!.size.width / 2 {
                scrolling = true
            }
            let touchedNode = nodeAtPoint(lastPoint!)
            if !songPlaying && touchedNode.parent is PersonNameSprite {
                movingPerson = touchedNode.parent as? PersonNameSprite
            }
            break
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        for touch in touches {
            let nextPoint = touch.locationInNode(self)
            let dx = nextPoint.x - lastPoint!.x
            var dy = nextPoint.y - lastPoint!.y
            if scrolling {
                if dx < -5 && nextPoint.x < xOffset + stage!.size.width {
                    scrolling = false
                } else {
                    if peopleSprites.count > 0 {
                        if peopleSprites.last!.position.y + dy > topBar!.position.y - topBar!.size.height * 3 {
                            dy = (topBar!.position.y - topBar!.size.height * 3) - peopleSprites.last!.position.y
                        }
                        if peopleSprites.first!.position.y + dy < personWidth {
                            dy = personWidth - peopleSprites.first!.position.y
                        }
                        for s in peopleSprites {
                            s.position.y += dy
                        }
                    }
                }
            }
            if movingPerson != nil && scrolling == false {
                movingPerson!.position.x += dx
                movingPerson!.position.y += dy
            
                if onStage.count < 4 && nextPoint.x > xOffset && nextPoint.x < xOffset + stage!.size.width && nextPoint.y > stage!.size.height / 2 && nextPoint.y < stage!.size.height / 2 + personWidth * 2 {
                    dropReady = true
                }
            }
            lastPoint = nextPoint
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        for touch in touches {
            let nextPoint = touch.locationInNode(self)
            if onStage.count < 4 && nextPoint.x > xOffset && nextPoint.x < xOffset + stage!.size.width && nextPoint.y > stage!.size.height / 2 && nextPoint.y < stage!.size.height / 2 + personWidth * 2 {
                dropReady = true
            }
        
            if movingPerson != nil {
                if dropReady && scrolling == false && onStage.count < 4 {
                    if peopleSprites.contains(movingPerson!){
                        peopleSprites.removeObject(movingPerson!)
                        onStage.append(movingPerson!)
                    }
                    var moveToSprite = selPerson1!
                    if onStage.count == 2 {
                        moveToSprite = selPerson2!
                    } else if onStage.count == 3 {
                        moveToSprite = selPerson3!
                    } else if onStage.count == 4 {
                        moveToSprite = selPerson4!
                    }
                    let act = SKAction.moveTo(moveToSprite.position, duration: 1.0)
                    movingPerson!.runAction(act)
                } else if onStage.contains(movingPerson!) && nextPoint.x > xOffset + stage!.size.width {
                    onStage.removeObject(movingPerson!)
                    var index = 0
                    for ds in peopleSprites {
                        if ds.position.y < movingPerson!.position.y {
                            index += 1
                        }
                    }
                    peopleSprites.insert(movingPerson!, atIndex: index)
                }
                reorderPeople()
            }
            break
        }
        dropReady = false
        scrolling = false
        movingPerson = nil
    }
}
