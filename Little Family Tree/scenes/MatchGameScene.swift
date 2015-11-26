//
//  MatchGameScene.swift
//  Little Family Tree
//
//  Created by Melissa on 11/25/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class MatchGameScene: SKScene {
    var dataService:DataService?
    var selectedPerson:LittlePerson?
    var game:MatchingGame?
    var people:[LittlePerson]?
    var matchSprites = [PersonMatchSprite]()
    var flipCount = 0
    var topBar:TopBar?
    var flip1:PersonMatchSprite?
    var flip2:PersonMatchSprite?
    
    override func didMoveToView(view: SKView) {
        self.size.width = view.bounds.width
        self.size.height = view.bounds.height
        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        let background = SKSpriteNode(imageNamed: "match_back")
        background.position = CGPointMake(self.size.width/2, self.size.height/2)
        background.size.width = self.size.width
        background.size.height = self.size.height
        background.zPosition = 0
        self.addChild(background)
        
        let tsie = CGSizeMake(self.size.width, 40)
        topBar = TopBar(color: UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.7), size: tsie)
        topBar!.position = CGPointMake(self.size.width/2, self.size.height-(topBar!.size.height / 2))
        topBar!.person = selectedPerson
        topBar!.homeTexture = SKTexture(imageNamed: "home")
        topBar!.zPosition = 100
        self.addChild(topBar!)
        
        dataService = DataService.getInstance()
        if selectedPerson != nil {
            self.dataService?.getFamilyMembers(selectedPerson!, loadSpouse: true, onCompletion: { family, err in
                self.people = family
                self.game = MatchingGame(startingLevel: 1, people: self.people!)
                self.game!.setupLevel()
                self.setupGame()
            })
        }
    }
    
    func setupGame() {
        var cols = 2
        var rows = game!.board!.count / cols
        var width = (self.size.width / CGFloat(cols)) - 20
        
        while CGFloat(rows) * width > self.size.height-40 {
            cols++
            rows = game!.board!.count / cols
            width = (self.size.width / CGFloat(cols)) - 20
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
            let y = (self.size.height - 40) - ((10 + width) * CGFloat(r+1))
            sprite.position = CGPointMake(x, y)
            sprite.gameScene = self
            sprite.person = mp
            self.addChild(sprite)
            matchSprites.append(sprite)
            
            c++
            if c >= cols {
                r++
                c = 0
            }
        }
    }
    
    override func willMoveFromView(view: SKView) {
        super.willMoveFromView(view)
    }
    
    override func update(currentTime: NSTimeInterval) {
        
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
                            game?.levelUp()
                            setupGame()
                        }
                    }
                }
            }
        }
    }
}
