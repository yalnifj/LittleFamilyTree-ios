//
//  DressUpScene.swift
//  Little Family Tree
//
//  Created by Melissa on 12/5/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class DressUpScene: LittleFamilyScene {
    var dolls = DressUpDolls()
    var dollConfig:DollConfig?
    var clothing:[DollClothing]?
    var clotheSprites:[SKSpriteNode] = [SKSpriteNode]()
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        self.size.width = view.bounds.width
        self.size.height = view.bounds.height
        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        let background = SKSpriteNode(imageNamed: "dressup_background")
        background.position = CGPointMake(self.size.width/2, self.size.height/2)
        background.size.width = self.size.width
        background.size.height = self.size.height
        background.zPosition = 0
        self.addChild(background)
        
        setupTopBar()
        var boygirl = "boy"
        if (selectedPerson!.gender == GenderType.FEMALE) {
            boygirl = "girl"
        }
        clothing = dollConfig?.getClothing()

        var scale = CGFloat(1.0)
        let doll = SKSpriteNode(imageNamed: "dolls/\(boygirl)doll")
        doll.zPosition = 2
        scale = (self.size.height * 0.6) / doll.size.height
        doll.setScale(scale)
        doll.position = CGPointMake(self.size.width/2, self.size.height - (10 + (topBar?.size.height)! + doll.size.height / 2))
        self.addChild(doll)
        
        if clothing != nil {
            var x = CGFloat(0)
            var y = CGFloat(0)
            var z = CGFloat(3)
            for cloth in clothing! {
                let clothSprite = SKSpriteNode(imageNamed: cloth.filename)
                clothSprite.zPosition = z++
                clothSprite.setScale(scale)
                if x > self.size.width - clothSprite.size.width/2 {
                    x = CGFloat(0)
                    y = y + clothSprite.size.height
                }
                if x == 0 {
                    x = 10 + clothSprite.size.width / 2
                }
                if y == 0  {
                    y = clothSprite.size.height * 3
                }
                clothSprite.position = CGPointMake(x, y)
                self.addChild(clothSprite)
                x = x + clothSprite.size.width + 20
                clotheSprites.append(clothSprite)
            }
        }
    }
}