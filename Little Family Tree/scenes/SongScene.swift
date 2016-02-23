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
        
        showLoadingDialog()
        
    }
    
    override func willMoveFromView(view: SKView) {
        super.willMoveFromView(view)
    }
    
    override func update(currentTime: NSTimeInterval) {
        super.update(currentTime)
    }

}