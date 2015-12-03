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
    var startTime:NSDate?
    var paths: [HeritagePath]?
    
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
        
        titleLabel = SKLabelNode(text: "Calculating your heritage. Please wait...")
        titleLabel?.fontColor = UIColor.blackColor()
        titleLabel?.fontSize = 14
        titleLabel?.zPosition = 1
        titleLabel?.position = CGPointMake(self.size.width/2, (topBar?.position.y)! - (topBar?.size.height)!)
        self.addChild(titleLabel!)
        
        let height = self.size.height * 0.5
        let whiteBackground = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeMake(self.size.width, self.size.height * 0.5))
        whiteBackground.position = CGPointMake(self.size.width/2, (titleLabel?.position.y)! - (5 + height/2))
        whiteBackground.zPosition = 2
        self.addChild(whiteBackground)
        
        var outline = "boyoutline"
        if selectedPerson?.gender == GenderType.FEMALE {
            outline = "girloutline"
        }
        let outlineTexture = SKTexture(imageNamed: outline)
        let ratio = outlineTexture.size().width / outlineTexture.size().height
        outlineSprite = SKSpriteNode(texture: outlineTexture)
        outlineSprite?.size.width = height * ratio
        outlineSprite?.size.height = height
        outlineSprite?.position = CGPointMake(20 + self.size.width/2 - (outlineSprite?.size.width)!/2, (titleLabel?.position.y)! - (5 + height/2))
        outlineSprite?.zPosition = 3
        let shader = SKShader(fileNamed: "gradient.fsh")
        outlineSprite?.shader = shader
        self.addChild(outlineSprite!)

        self.startTime = NSDate()
        let operationQueue = NSOperationQueue()
        let operation1 : NSBlockOperation = NSBlockOperation (block: {
            let task = HeritageCalculator()
            task.execute(self.selectedPerson!, onCompletion: {paths in
                var diff = Int64(3 + self.startTime!.timeIntervalSinceNow)
                if diff < 0 {
                    diff = 0
                }
                self.paths = paths
                let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), diff * Int64(NSEC_PER_SEC))
                dispatch_after(time, dispatch_get_main_queue()) {
                    //self.outlineSprite?.shader = nil
                    let test = SKLabelNode(text: "found \(self.paths?.count) paths")
                    test.fontColor = UIColor.blackColor()
                    test.fontSize = 14
                    test.zPosition = 4
                    test.position = CGPointMake(self.size.width/1.5, self.size.height/1.5)
                    self.addChild(test)
                }
            })
        })
        operationQueue.addOperation(operation1)
        SpeechHelper.getInstance().speak("Calculating your heritage. Please wait...")
    }

    override func willMoveFromView(view: SKView) {
        super.willMoveFromView(view)
    }
    
    override func update(currentTime: NSTimeInterval) {
        
    }
}