//
//  SongScene.swift
//  Little Family Tree
//
//  Created by Melissa on 2/22/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class SongScene: LittleFamilyScene {
    
    var stage:SKSpriteNode?
    
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
        
        var width = min(self.size.width, self.size.height)
        if width == self.size.width {
            width = width * 0.8
        }
        
        let stageTexture = SKTexture(imageNamed: "stage")
        let ratio = stageTexture.size().width / stageTexture.size().height
        let height = width / ratio
        
        stage = SKSpriteNode(texture: stageTexture)
        stage?.size = CGSizeMake(width, height)
        stage?.zPosition = 1
        stage?.position = CGPointMake(0, 0)
        self.addChild(stage!)
        
        setupTopBar()
        
        showLoadingDialog()
        
    }
    
    override func willMoveFromView(view: SKView) {
        super.willMoveFromView(view)
    }
    
    override func update(currentTime: NSTimeInterval) {
        super.update(currentTime)
    }

}