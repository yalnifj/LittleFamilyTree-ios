//
//  SplashScene.swift
//  Little Family Tree
//
//  Created by Melissa on 10/7/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import SpriteKit

class ChoosePlayerScene: SKScene {
    var dataService:DataService?
    
    override func didMoveToView(view: SKView) {
        view.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        dataService = DataService.getInstance()
        dataService?.getDefaultPerson(false, onCompletion: { person, err in
            self.dataService?.getFamilyMembers(person!, loadSpouse: false, onCompletion: { family, err in
                var width = (self.size.width / 3) - 10
                if self.size.width > self.size.height {
                    width = (self.size.height / 3) - 10
                }
                var x = CGFloat(10.0)
                var y = CGFloat(10.0)
                for p in family! {
                    let sprite = PersonNameSprite()
                    sprite.position = CGPointMake(x, y)
                    sprite.size.width = width
                    sprite.size.height = width
                    sprite.person = p
                    self.addChild(sprite)
                    x += width + 10
                    if x > self.size.width - width {
                        x = CGFloat(10)
                        y += width + 10
                    }
                }
            })
        })
    }
    
    override func update(currentTime: NSTimeInterval) {

    }
}
