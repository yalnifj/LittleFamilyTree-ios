//
//  ChooseCultureScene.swift
//  Little Family Tree
//
//  Created by Melissa on 11/27/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class ChooseCultureScene: LittleFamilyScene {
    var titleLabel:SKLabelNode?
    var outlineSprite:SKSpriteNode?
    
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
        
        SpeechHelper.getInstance().speak("Calculating your heritage. Please wait...")
        titleLabel = SKLabelNode(text: "Calculating your heritage. Please wait...")
        titleLabel?.fontColor = UIColor.blackColor()
        titleLabel?.fontSize = 14
        titleLabel?.zPosition = 1
        titleLabel?.position = CGPointMake(self.size.width/2, (topBar?.position.y)! - (topBar?.size.height)!)
        self.addChild(titleLabel!)
        
        var outline = "boyoutline"
        if selectedPerson?.gender == GenderType.FEMALE {
            outline = "girloutline"
        }
        let outlineTexture = SKTexture(imageNamed: outline)
        let ratio = outlineTexture.size().width / outlineTexture.size().height
        let height = self.size.height * 0.6
        outlineSprite = SKSpriteNode(texture: outlineTexture)
        outlineSprite?.size.width = height * ratio
        outlineSprite?.size.height = height
        outlineSprite?.position = CGPointMake(self.size.width/2, (titleLabel?.position.y)! - (5 + height/2))
        titleLabel?.zPosition = 3
        self.addChild(outlineSprite!)
    }

    override func willMoveFromView(view: SKView) {
        super.willMoveFromView(view)
    }
    
    override func update(currentTime: NSTimeInterval) {
        
    }
}