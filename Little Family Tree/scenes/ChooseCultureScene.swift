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
    var pathPerson:PersonNameSprite?
    var doll:AnimatedStateSprite?
    var startTime:NSDate?
    var calculator:HeritageCalculator?
    var colors = [UIColor.blueColor(), UIColor.redColor(), UIColor.purpleColor(), UIColor.orangeColor(),
        UIColor.greenColor(), UIColor.yellowColor(), UIColor.grayColor(), UIColor.cyanColor(), UIColor.magentaColor()]
    
    var selectedPath:HeritagePath?
    
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
        
        pathPerson = PersonNameSprite()
        pathPerson?.size.width = self.size.width/2
        pathPerson?.size.height = self.size.height - ((outlineSprite?.size.height)! + 20 + (topBar?.size.height)!)
        pathPerson?.position = CGPointMake(self.size.width*0.25, (pathPerson?.size.height)!/2)
        pathPerson?.zPosition = 3
        pathPerson?.hidden = true
        self.addChild(pathPerson!)
        
        doll = AnimatedStateSprite()
        doll?.size.width = self.size.width/2
        doll?.size.height = (pathPerson?.size.height)!
        doll?.position = CGPointMake(self.size.width*0.75, (doll?.size.height)!/2)
        doll?.zPosition = 3
        doll?.hidden = true
        self.addChild(doll!)

        self.startTime = NSDate()
        let operationQueue = NSOperationQueue()
        let operation1 : NSBlockOperation = NSBlockOperation (block: {
            self.calculator = HeritageCalculator()
            self.calculator!.execute(self.selectedPerson!)
            
            var diff = Int64(3 + self.startTime!.timeIntervalSinceNow)
            if diff < 0 {
                diff = 0
            }
            let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), diff * Int64(NSEC_PER_SEC))
            dispatch_after(time, dispatch_get_main_queue()) {
                self.calculator?.mapPaths()
                
                self.outlineSprite?.shader = nil
                
                var c = 0
                var y:CGFloat = (self.outlineSprite?.position.y)! + (self.outlineSprite?.size.height)!/2
                for path in (self.calculator?.uniquePaths)! {
                    var height = (self.outlineSprite?.size.height)! * CGFloat(path.percent)
                    if height < 10 {
                        height = CGFloat(10)
                    }
                    let pathColor = SKSpriteNode(color: self.colors[c % self.colors.count], size: CGSizeMake((self.outlineSprite?.size.width)!, height))
                    pathColor.zPosition = 2
                    pathColor.position = CGPointMake((self.outlineSprite?.position.x)!, y - height/2)
                    self.addChild(pathColor)
                    
                    let pathTitle = SKLabelNode(text: "\(path.place) " + String(format: "%.1f", path.percent*100) + "%")
                    pathTitle.fontColor = UIColor.blackColor()
                    pathTitle.fontSize = 12
                    pathTitle.zPosition = 4
                    pathTitle.position = CGPointMake(self.size.width*0.75, y - height/3)
                    self.addChild(pathTitle)
                    print(pathTitle.text)
                    
                    let linePath = CGPathCreateMutable()
                    CGPathMoveToPoint(linePath, nil, pathColor.position.x+20, pathColor.position.y)
                    CGPathAddLineToPoint(linePath, nil, pathColor.position.x + pathColor.size.width/2, pathTitle.position.y-2)
                    CGPathAddLineToPoint(linePath, nil, self.size.width - 20, pathTitle.position.y-2)
                    let line = SKShapeNode()
                    line.path = linePath
                    line.strokeColor = UIColor.blackColor()
                    line.lineWidth = 1
                    line.zPosition = 4
                    self.addChild(line)

                    c++
                    y -= height
                }
                
                self.setSelectedPath((self.calculator?.uniquePaths[0])!)
            }
        
        })
        operationQueue.addOperation(operation1)
        SpeechHelper.getInstance().speak("Calculating your heritage. Please wait...")
    }
    
    func setSelectedPath(path:HeritagePath) {
        self.selectedPath = path

        pathPerson?.person = self.calculator!.culturePeople[path.place]![0]
        pathPerson?.hidden = false
        
        doll?.texture = SKTexture(imageNamed: "usa/girl_thumb")
        doll?.hidden = false
    }

    override func willMoveFromView(view: SKView) {
        super.willMoveFromView(view)
    }
    
    override func update(currentTime: NSTimeInterval) {
        
    }
}