//
//  MatchGameScene.swift
//  Little Family Tree
//
//  Created by Melissa on 11/25/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class MatchGameScene: LittleFamilyScene {
    var dataService:DataService?
    
    var game:MatchingGame?
    var people:[LittlePerson]?
    var loadIndex = 0
    var matchSprites = [PersonMatchSprite]()
    var flipCount = 0
    var flip1:PersonMatchSprite?
    var flip2:PersonMatchSprite?
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        self.size.width = view.bounds.width
        self.size.height = view.bounds.height
        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        let background = SKSpriteNode(imageNamed: "match_back")
        background.position = CGPointMake(self.size.width/2, self.size.height/2)
        background.size.width = self.size.width
        background.size.height = self.size.height
        background.zPosition = 0
        self.addChild(background)
        
        setupTopBar()
        
        dataService = DataService.getInstance()
        if selectedPerson != nil {
            loadMorePeople()
        }
    }
    
    func loadMorePeople() {
        if loadIndex > 0 && loadIndex >= people!.count {
            loadIndex = 0
        }
        if self.people == nil {
            self.people = [LittlePerson]()
            self.people!.append(selectedPerson!)
        }
        self.dataService?.getFamilyMembers(people![loadIndex], loadSpouse: true, onCompletion: { family, err in
            self.loadIndex++
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
        var width = CGFloat(round(self.size.width * self.size.height / game!.board!.count) - 20)
		
		var cols = Int(self.size.width / width)
		var rows = game!.board!.count / cols
		
		if  CGFloat(rows) * (width + 20) > self.size.height {
			width = CGFloat(round(self.size.height / rows) - 20)
		}
        
        for s in matchSprites {
            s.removeFromParent()
        }
        flip1 = nil
        flip2 = nil
        
        self.matchSprites.removeAll()
        var c = 0
        var r = 0
        for mp in game!.board! {
            let sprite = PersonMatchSprite()
            sprite.size.width = width
            sprite.size.height = width
            sprite.userInteractionEnabled = true
            let x = 10 + ((10 + width) * CGFloat(c))
			if x + width > self.size.width {
				r++
				c = 0
			}
            let y = (self.size.height - topBar!.size.height) - ((10 + width) * CGFloat(r+1))
            sprite.position = CGPointMake(x, y)
            sprite.gameScene = self
            sprite.person = mp
            self.addChild(sprite)
            matchSprites.append(sprite)
        }
    }
    
    override func willMoveFromView(view: SKView) {
        super.willMoveFromView(view)
    }
    
    override func update(currentTime: NSTimeInterval) {
        super.update(currentTime)
    }

    func frameTouched(sprite:PersonMatchSprite) {
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
                flipCount++
                sprite.flip()
                if flipCount == 2 {
                    if flip1?.person?.person == flip2?.person?.person {
                        flip1?.person?.matched = true
                        flip2?.person?.matched = true
                        
                        if game?.allMatched() == true {
                            self.showStars(CGRectMake(self.size.width * 0.1, self.size.height * 0.1, self.size.width * 0.8, self.size.height * 0.8), starsInRect: true, count: Int(self.size.width) / 30)
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
