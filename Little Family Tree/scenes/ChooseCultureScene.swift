//
//  ChooseCultureScene.swift
//  Little Family Tree
//
//  Created by Melissa on 11/27/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class ChooseCultureScene: LittleFamilyScene, CalculatorCompleteListener {
    var titleLabel:SKLabelNode?
    var whiteBackground:SKSpriteNode?
    var outlineSprite:SKSpriteNode?
    var pathPerson:Gallery?
    var galleryAdapter:PersonGalleryAdapter?
    //var pathPerson:PersonNameSprite?
    var doll:AnimatedStateSprite?
    var countryLabel:SKLabelNode?
    var startTime:NSDate?
    var calculator:HeritageCalculator?
    var colors = [UIColor.blueColor(), UIColor.redColor(), UIColor.purpleColor(), UIColor.orangeColor(),
        UIColor.greenColor(), UIColor.yellowColor(), UIColor.grayColor(), UIColor.cyanColor(), UIColor.magentaColor()]
    
    var selectedPath:HeritagePath?
    var dolls = DressUpDolls()
    var dollConfig:DollConfig?
    
    var portrait = true
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        self.size.width = view.bounds.width
        self.size.height = view.bounds.height
        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    
        self.portrait = self.size.height > self.size.width
        
        let background = SKSpriteNode(imageNamed: "dressup_background")
        background.position = CGPointMake(self.size.width/2, self.size.height/2)
        background.size.width = self.size.width
        background.size.height = self.size.height
        background.zPosition = 0
        self.addChild(background)
        
        setupTopBar()
        
        titleLabel = SKLabelNode(text: "Calculating your heritage. Please wait...")
        titleLabel?.fontColor = UIColor.blackColor()
        titleLabel?.fontSize = min(self.size.width, self.size.height) / 25
        titleLabel?.zPosition = 1
        titleLabel?.position = CGPointMake(self.size.width/2, topBar!.position.y - (5 + topBar!.size.height))
        self.addChild(titleLabel!)
        
        var height = self.size.height * 0.5
        if !portrait {
            height = (self.size.height - self.topBar!.size.height) * 0.90
        }
        whiteBackground = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeMake(self.size.width, self.size.height * 0.5))
        if !portrait {
            whiteBackground?.size.height = height
            whiteBackground?.size.width = self.size.width * 0.66
        }
        whiteBackground?.position = CGPointMake(self.size.width/2, (titleLabel?.position.y)! - ((titleLabel?.fontSize)!/2 + height/2))
        if !portrait {
            whiteBackground?.position.x = self.size.width * 0.66 / 2
        }
        whiteBackground?.zPosition = 2
        self.addChild(whiteBackground!)
        
        var outline = "boyoutline"
        if selectedPerson?.gender == GenderType.FEMALE {
            outline = "girloutline"
        }
        let outlineTexture = SKTexture(imageNamed: "dolls/\(outline)")
        let ratio = outlineTexture.size().width / outlineTexture.size().height
        outlineSprite = SKSpriteNode(texture: outlineTexture)
        outlineSprite?.size.width = height * ratio
        outlineSprite?.size.height = height
        if !portrait {
            outlineSprite?.size.width = whiteBackground!.size.width / 2
            outlineSprite?.size.height = (whiteBackground!.size.width / 2) / ratio
        }
        outlineSprite?.position = CGPointMake(30 + whiteBackground!.position.x - (outlineSprite?.size.width)!/2, (titleLabel?.position.y)! - ((titleLabel?.fontSize)!/2 + height/2))
        outlineSprite?.zPosition = 3
        let shader = SKShader(fileNamed: "gradient.fsh")
        outlineSprite?.shader = shader
        self.addChild(outlineSprite!)
        
        galleryAdapter = PersonGalleryAdapter(people: [LittlePerson]())
        
        pathPerson = Gallery()
        pathPerson?.size.width = self.size.width/2
        pathPerson?.size.height = self.size.height - ((outlineSprite?.size.height)! + 20 + (topBar?.size.height)!)
        pathPerson?.position = CGPointMake(0, 20)
        if !portrait {
            pathPerson?.position = CGPointMake(self.size.width * 0.76, height / 1.7)
            pathPerson?.size.width = self.size.width / 4.5
            pathPerson?.size.height = height / 2.3
        }
        pathPerson?.zPosition = 3
        pathPerson?.hidden = true
        pathPerson?.userInteractionEnabled = true
        pathPerson?.adapter = galleryAdapter
        self.addChild(pathPerson!)
        
        doll = AnimatedStateSprite()
        doll?.size.width = self.size.width/3
        doll?.size.height = self.size.width/3
        doll?.position = CGPointMake(self.size.width*0.75, 70 + doll!.size.height / 2)
        if !portrait {
            doll?.size.width = self.size.width/4
            doll?.size.height = self.size.width/4
            doll?.position = CGPointMake(self.size.width*0.82, 70 + doll!.size.height / 2)
        }
        doll?.zPosition = 3
        doll?.hidden = true
        self.addChild(doll!)
        
        countryLabel = SKLabelNode(text: "country")
        countryLabel?.fontColor = UIColor.blackColor()
        countryLabel?.fontSize = 11
        countryLabel?.zPosition = 4
        countryLabel?.position = CGPointMake((doll?.position.x)!, 30)
        countryLabel?.hidden = true
        self.addChild(countryLabel!)

        self.startTime = NSDate()
        let operationQueue = NSOperationQueue()
        let operation1 : NSBlockOperation = NSBlockOperation (block: {
            self.calculator = HeritageCalculator(listener: self)
            self.calculator!.execute(self.selectedPerson!)
        })
        operationQueue.addOperation(operation1)
        self.speak("Calculating your heritage. Please wait...")
    }
    
    func onCalculationComplete() {
        var diff = Int64(3 + self.startTime!.timeIntervalSinceNow)
        if diff < 0 {
            diff = 0
        }
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), diff * Int64(NSEC_PER_SEC))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.calculator?.mapPaths()
            
            self.outlineSprite?.shader = nil
            
            var c = 0
            var y:CGFloat = self.outlineSprite!.position.y - (self.outlineSprite!.size.height / 2)
            let rpaths = self.calculator!.uniquePaths.reverse()
            var theight = CGFloat(0)
            var tpercent = Double(0)
            var count = 0
            for path in rpaths {
                var height = self.outlineSprite!.size.height * CGFloat(path.percent)
                if height < self.outlineSprite!.size.height / 20 {
                    height = self.outlineSprite!.size.height / 20
                } else {
                    if theight + height > CGFloat(1) + self.outlineSprite!.size.height {
                        height = self.outlineSprite!.size.height - theight
                    }
                }
                tpercent += path.percent
                theight += height
                count += 1
                let pathColor = SKSpriteNode(color: self.colors[c % self.colors.count], size: CGSizeMake((self.outlineSprite?.size.width)!, height))
                pathColor.zPosition = 2
                pathColor.position = CGPointMake((self.outlineSprite?.position.x)!, y + height/2)
                self.addChild(pathColor)
                
                let pathTitle = SKLabelNode(text: "\(path.place) " + String(format: "%.1f", path.percent*100) + "%")
                pathTitle.fontColor = UIColor.blackColor()
                pathTitle.fontSize = self.outlineSprite!.size.height / 20
                pathTitle.zPosition = 4
                pathTitle.position = CGPointMake(self.whiteBackground!.size.width*0.75, y + height/3)
                self.addChild(pathTitle)
                print(pathTitle.text)
                
                let linePath = CGPathCreateMutable()
                CGPathMoveToPoint(linePath, nil, pathColor.position.x+20, pathColor.position.y)
                CGPathAddLineToPoint(linePath, nil, pathColor.position.x + pathColor.size.width/2, pathTitle.position.y-2)
                CGPathAddLineToPoint(linePath, nil, self.whiteBackground!.size.width - 10, pathTitle.position.y-2)
                let line = SKShapeNode()
                line.path = linePath
                line.strokeColor = UIColor.blackColor()
                line.lineWidth = 1
                line.zPosition = 4
                self.addChild(line)
                
                c += 1
                y += height
            }
            
            if count > 0 && count < 3 && self.calculator!.paths.count < 10 {
                SyncQ.getInstance().start()
                self.showSimpleDialog("Loading Data", message:"The game is still loading data.  As more data is loaded, the calculations will get more accurate.  Please try again in a few minutes.  You may continue to play while more data is loaded in the background.");
            }
            
            if count > 0 {
               self.setSelectedPath(self.calculator!.uniquePaths[0]) 
            }
        }
    }
    
    func speakDetails(relative:LittlePerson) {
        let relationship = RelationshipCalculator.getAncestralRelationship(selectedPath!.treePath.count, p: relative, me: selectedPerson!, isRoot: false, isChild: false, isInLaw: false);
        
        relative.relationship = relationship
        let percString = String(format: "%.1f", selectedPath!.percent*100)
        var text = "You are \(percString) percent from \(selectedPath!.place) from your \(relationship). "
        if (relative.birthDate != nil) {
            let df = NSDateFormatter()
            df.dateStyle = .LongStyle
            let dateText = df.stringFromDate(relative.birthDate!)
            if (relative.birthPlace != nil ) {
                text += " \(relative.name!) was born in \(relative.birthPlace!) on \(dateText)"
            } else {
                text += " \(relative.name!) was born on \(dateText)"
            }
        } else {
            if (relative.birthPlace != nil ) {
                text += " \(relative.name!) was born in \(relative.birthPlace!)"
            } else {
                text += " \(relative.name!)"
            }
        }
        self.speak(text);
    }

    
    func setSelectedPath(path:HeritagePath) {
        self.selectedPath = path
        
        titleLabel?.text = "Choose a country"

        //pathPerson?.person = self.calculator!.culturePeople[path.place.lowercaseString]![0]
        galleryAdapter?.people = self.calculator!.culturePeople[path.place.lowercaseString]!
        pathPerson?.hidden = false
        
        dollConfig = self.dolls.getDollConfig(path.place, person: selectedPerson!)

        let texture = SKTexture(imageNamed: dollConfig!.getThumbnail())
        let ratio = texture.size().width / texture.size().height
        doll?.size.width = (doll?.size.height)! * ratio
        doll?.texture = texture
        doll?.hidden = false
        
        let personNode = pathPerson!.visibleNodes[0] as! PersonNameSprite
        
        countryLabel?.text = path.place
        countryLabel?.fontSize = personNode.nameLabel!.fontSize
        countryLabel?.hidden = false
        
        speakDetails(personNode.person!)
        //speakDetails(pathPerson!.person!)
    }

    override func willMoveFromView(view: SKView) {
        super.willMoveFromView(view)
    }
    
    override func update(currentTime: NSTimeInterval) {
        super.update(currentTime)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            checkForPath(touch)
            break
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            checkForPath(touch)
            break
        }
    }

    func checkForPath(touch:UITouch) {
        let location = touch.locationInNode(self)
        let touchedNode = nodeAtPoint(location)
        
        if touchedNode == self.doll || touchedNode == self.countryLabel {
            if dollConfig != nil {
                self.showDressupGame(dollConfig!, person: selectedPerson!, previousTopic: GameScene.TOPIC_START_DRESSUP)
                return
            }
        }
        
        var y:CGFloat = self.outlineSprite!.position.y - self.outlineSprite!.size.height / 2
        let x:CGFloat = self.whiteBackground!.position.x + self.whiteBackground!.size.width / 2
        let ty = self.size.height - touch.locationInView(self.view).y
        let tx = touch.locationInView(self.view).x
        if tx > x {
            return
        }
        let rpaths = self.calculator!.uniquePaths.reverse()
        var theight = CGFloat(0)
        for path in rpaths {
            var height = self.outlineSprite!.size.height * CGFloat(path.percent)
            if height < self.outlineSprite!.size.height / 20 {
                height = self.outlineSprite!.size.height / 20
            } else {
                if theight + height > CGFloat(1) + self.outlineSprite!.size.height {
                    height = self.outlineSprite!.size.height - theight
                }
            }
            theight += height
            print("y=\(y) height=\(height) ty=\(ty)")
            if ty >= y && ty < y + height {
                setSelectedPath(path)
                break
            }
            
            y += height
        }
    }
}