//
//  MatchGameScene.swift
//  Little Family Tree
//
//  Created by Melissa on 11/25/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit
import Firebase

class MatchGameScene: LittleFamilyScene {
    var dataService:DataService?
    
    var game:MatchingGame?
    var people:[LittlePerson]?
    var loadIndex = 0
    var matchSprites = [PersonMatchSprite]()
    var flipCount = 0
    var flip1:PersonMatchSprite?
    var flip2:PersonMatchSprite?
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.size.width = view.bounds.width
        self.size.height = view.bounds.height
        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        let background = SKSpriteNode(imageNamed: "match_back")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.size.width = self.size.width
        background.size.height = self.size.height
        background.zPosition = 0
        self.addChild(background)
        
        setupTopBar()
        
        dataService = DataService.getInstance()
        if selectedPerson != nil {
            loadMorePeople()
        }
        
        Analytics.logEvent(AnalyticsEventViewItem, parameters: [
            AnalyticsParameterItemName: String(describing: MatchGameScene.self) as NSObject
        ])
    }
    
    func loadMorePeople() {
        if loadIndex > 0 && loadIndex >= people!.count {
            loadIndex = 0
        }
        if self.people == nil {
            self.people = [LittlePerson]()
            self.people!.append(selectedPerson!)
        }
		var loadSpouse = true
		let showStepChildren = dataService!.dbHelper.getProperty(DataService.PROPERTY_SHOW_STEP_CHILDREN)
        if showStepChildren != nil && showStepChildren == "false" {
			loadSpouse = false
		}
        self.dataService?.getFamilyMembers(people![loadIndex], loadSpouse: loadSpouse, onCompletion: { family, err in
            self.loadIndex += 1
            if family != nil {
                for p in family! {
                    if !self.people!.contains(p) {
                        self.people!.append(p)
                    }
                }
                if self.game == nil {
                    self.game = MatchingGame(startingLevel: 1, people: self.people!)
                    self.game!.setupLevel()
                } else {
                    self.game?.peoplePool = self.people!
                    if self.people!.count < self.game!.level+1 {
                        self.loadMorePeople()
                        return;
                    }
                    self.game?.levelUp()
                }
                self.setupGame()
            }
        })
    }
    
    func setupGame() {
        DispatchQueue.main.async(execute: {
            let ratio = self.size.width / self.size.height
            var cols = 2
            var rows = self.game!.board!.count / cols
            while CGFloat(cols) / CGFloat(rows) < ratio {
                cols += 1
                rows = self.game!.board!.count / cols
            }
            if self.game!.board!.count % cols > 0 {
                cols -= 1
                rows = self.game!.board!.count / cols
            }
            var width = (self.size.width / CGFloat(cols)) - 20
            
            if  CGFloat(rows) * (width + 20) > self.size.height {
                width = CGFloat(round(self.size.height / CGFloat(rows)) - 20)
            }
            
            for s in self.matchSprites {
                s.removeFromParent()
            }
            self.flip1 = nil
            self.flip2 = nil
            
            self.matchSprites.removeAll()
            var c = 0
            var r = 0
            for mp in self.game!.board! {
                let sprite = PersonMatchSprite()
                sprite.size.width = width
                sprite.size.height = width
                sprite.isUserInteractionEnabled = true
                var x = 10 + ((10 + width) * CGFloat(c))
                if x + width > self.size.width {
                    r += 1
                    x = CGFloat(10)
                    c = 0
                }
                let y = (self.size.height - self.topBar!.size.height) - ((10 + width) * CGFloat(r+1))
                sprite.position = CGPoint(x: x, y: y)
                sprite.gameScene = self
                sprite.person = mp
                self.addChild(sprite)
                self.matchSprites.append(sprite)
                c += 1
            }
        })
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
    }

    func frameTouched(_ sprite:PersonMatchSprite) {
        if sprite.person?.flipped == false {
            if flipCount >= 2 {
                for s in matchSprites {
                    if s.person?.matched == false && s.person?.flipped == true {
                        s.flip()
                    }
                }
                flipCount = 0
                flip1 = nil
                flip2 = nil
            }
            
            if flipCount < 2 {
                if flip1 == nil {
                    flip1 = sprite
                } else {
                    flip2 = sprite
                }
                flipCount += 1
                sprite.flip()
                if flipCount == 2 {
                    if flip1?.person?.person == flip2?.person?.person {
                        flip1?.person?.matched = true
                        flip2?.person?.matched = true
                        
                        if game?.allMatched() == true {
                            self.showStars(CGRect(x: self.size.width * 0.1, y: self.size.height * 0.1, width: self.size.width * 0.8, height: self.size.height * 0.8), starsInRect: true, count: 10, container: self)
                            self.playSuccessSound(2.0, onCompletion: { () in
                                self.loadMorePeople()
                            })
                        }
                    } else {
                        flip1?.delayFlip()
                        flip2?.delayFlip()
                    }
                }
            }
        }
    }
}
