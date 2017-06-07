//
//  ChooseCultureScene.swift
//  Little Family Tree
//
//  Created by Melissa on 11/27/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit
import Firebase

class ChooseCultureScene: LittleFamilyScene, CalculatorCompleteListener {
    static var TOPIC_PERSON_TOUCHED = "personTouched"
    var titleLabel:SKLabelNode?
    var whiteBackground:SKSpriteNode?
    var outlineSprite:SKSpriteNode?
    var pathPerson:Gallery?
    var galleryAdapter:PersonGalleryAdapter?
    //var pathPerson:PersonNameSprite?
    var doll:AnimatedStateSprite?
    var countryLabel:SKLabelNode?
    var startTime:Foundation.Date?
    var calculator:HeritageCalculator?
    var colors = [UIColor.blue, UIColor.red, UIColor.purple, UIColor.orange,
        UIColor.green, UIColor.yellow, UIColor.gray, UIColor.cyan, UIColor.magenta]
    
    var selectedPath:HeritagePath?
    var dolls = DressUpDolls()
    var dollConfig:DollConfig?
    
    var portrait = true
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.size.width = view.bounds.width
        self.size.height = view.bounds.height
        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    
        self.portrait = self.size.height > self.size.width
        
        let background = SKSpriteNode(imageNamed: "dressup_background")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.size.width = self.size.width
        background.size.height = self.size.height
        background.zPosition = 0
        self.addChild(background)
        
        setupTopBar()
        
        titleLabel = SKLabelNode(text: "Calculating your heritage. Please wait...")
        titleLabel?.fontColor = UIColor.black
        titleLabel?.fontSize = min(self.size.width, self.size.height) / 25
        titleLabel?.zPosition = 1
        titleLabel?.position = CGPoint(x: self.size.width/2, y: topBar!.position.y - (5 + topBar!.size.height))
        self.addChild(titleLabel!)
        
        var height = self.size.height * 0.5
        if !portrait {
            height = (self.size.height - self.topBar!.size.height) * 0.90
        }
        whiteBackground = SKSpriteNode(color: UIColor.white, size: CGSize(width: self.size.width, height: self.size.height * 0.5))
        if !portrait {
            whiteBackground?.size.height = height
            whiteBackground?.size.width = self.size.width * 0.66
        }
        whiteBackground?.position = CGPoint(x: self.size.width/2, y: (titleLabel?.position.y)! - ((titleLabel?.fontSize)!/2 + height/2))
        if !portrait {
            whiteBackground?.position.x = self.size.width * 0.66 / 2
        }
        whiteBackground?.zPosition = 2
        self.addChild(whiteBackground!)
        
        var outline = "boyoutline"
        if selectedPerson?.gender == GenderType.female {
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
        outlineSprite?.position = CGPoint(x: 30 + whiteBackground!.position.x - (outlineSprite?.size.width)!/2, y: (titleLabel?.position.y)! - ((titleLabel?.fontSize)!/2 + height/2))
        outlineSprite?.zPosition = 3
        let shader = SKShader(fileNamed: "gradient.fsh")
        outlineSprite?.shader = shader
        self.addChild(outlineSprite!)
        
        galleryAdapter = PersonGalleryAdapter(people: [LittlePerson](), topic: ChooseCultureScene.TOPIC_PERSON_TOUCHED)
        
        pathPerson = Gallery()
        pathPerson?.size.width = self.size.width/2
        pathPerson?.size.height = self.size.height - ((outlineSprite?.size.height)! + 20 + (topBar?.size.height)!)
        pathPerson?.position = CGPoint(x: 0, y: 20)
        if !portrait {
            pathPerson?.position = CGPoint(x: self.size.width * 0.76, y: height / 1.7)
            pathPerson?.size.width = self.size.width / 4.5
            pathPerson?.size.height = height / 2.3
        }
        pathPerson?.zPosition = 3
        pathPerson?.isHidden = true
        pathPerson?.isUserInteractionEnabled = true
        pathPerson?.adapter = galleryAdapter
        self.addChild(pathPerson!)
        
        doll = AnimatedStateSprite()
        doll?.size.width = self.size.width/3
        doll?.size.height = self.size.width/3
        doll?.position = CGPoint(x: self.size.width*0.75, y: 70 + doll!.size.height / 2)
        if !portrait {
            doll?.size.width = self.size.width/4
            doll?.size.height = self.size.width/4
            doll?.position = CGPoint(x: self.size.width*0.82, y: 70 + doll!.size.height / 2)
        }
        doll?.zPosition = 3
        doll?.isHidden = true
        self.addChild(doll!)
        
        countryLabel = SKLabelNode(text: "country")
        countryLabel?.fontColor = UIColor.black
        countryLabel?.fontSize = 11
        countryLabel?.zPosition = 4
        countryLabel?.position = CGPoint(x: (doll?.position.x)!, y: 30)
        countryLabel?.isHidden = true
        self.addChild(countryLabel!)

        self.startTime = Foundation.Date()
        let operationQueue = OperationQueue()
        let operation1 : BlockOperation = BlockOperation (block: {
            self.calculator = HeritageCalculator(listener: self)
            self.calculator!.execute(self.selectedPerson!)
        })
        operationQueue.addOperation(operation1)
        self.speak("Calculating your heritage. Please wait...")
        
        EventHandler.getInstance().subscribe(ChooseCultureScene.TOPIC_PERSON_TOUCHED, listener: self)
        
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        EventHandler.getInstance().unSubscribe(ChooseCultureScene.TOPIC_PERSON_TOUCHED, listener: self)
    }
    
    func onCalculationComplete() {
        var diff = Int64(3 + self.startTime!.timeIntervalSinceNow)
        if diff < 0 {
            diff = 0
        }
        let time = DispatchTime.now() + Double(diff * Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.calculator?.mapPaths()
            
            self.outlineSprite?.shader = nil
            
            var c = 0
            var y:CGFloat = self.outlineSprite!.position.y - (self.outlineSprite!.size.height / 2)
            let rpaths = self.calculator!.uniquePaths.reversed()
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
                let pathColor = SKSpriteNode(color: self.colors[c % self.colors.count], size: CGSize(width: (self.outlineSprite?.size.width)!, height: height))
                pathColor.zPosition = 2
                pathColor.position = CGPoint(x: (self.outlineSprite?.position.x)!, y: y + height/2)
                self.addChild(pathColor)
                
                let pathTitle = SKLabelNode(text: "\(path.place) " + String(format: "%.1f", path.percent*100) + "%")
                pathTitle.fontColor = UIColor.black
                pathTitle.fontSize = self.outlineSprite!.size.height / 20
                pathTitle.zPosition = 4
                pathTitle.position = CGPoint(x: self.whiteBackground!.size.width*0.75, y: y + height/3)
                self.addChild(pathTitle)
                print(pathTitle.text)
                
                let linePath = CGMutablePath()
                linePath.move(to: CGPoint(x: pathColor.position.x+20, y: pathColor.position.y))
                //CGPathMoveToPoint(linePath, nil, pathColor.position.x+20, pathColor.position.y)
                linePath.addLine(to: CGPoint(x: pathColor.position.x + pathColor.size.width/2, y: pathTitle.position.y-2))
                //CGPathAddLineToPoint(linePath, nil, pathColor.position.x + pathColor.size.width/2, pathTitle.position.y-2)
                linePath.addLine(to: CGPoint(x: self.whiteBackground!.size.width - 10, y: pathTitle.position.y-2))
                //CGPathAddLineToPoint(linePath, nil, self.whiteBackground!.size.width - 10, pathTitle.position.y-2)
                let line = SKShapeNode()
                line.path = linePath
                line.strokeColor = UIColor.black
                line.lineWidth = 1
                line.zPosition = 4
                self.addChild(line)
                
                c += 1
                y += height
            }
            
            let tryCount = self.getTryCount("try_heritage_count")
            
            var littleData = false
            if count > 0 && count < 3 && self.calculator!.paths.count < 10 {
                SyncQ.getInstance().start()
                if tryCount <= 3 {
                    self.showSimpleDialog("Loading Data", message:"The game is still loading data.  As more data is loaded, the calculations will get more accurate.  Please try again in a few minutes.  You may continue to play while more data is loaded in the background.");
                }
                littleData = true
            }
            
            self.userHasPremium({ premium in
                if !premium {
                    var tryAvailable = true
                    if (littleData && tryCount > 5) || tryCount > 3 {
                        tryAvailable = false
                    }
                    if !littleData || !tryAvailable {
                        self.showLockDialog(tryAvailable,  tries: LittleFamilyScene.FREE_TRIES - (tryCount-1))
                    }
                }
            })
            
            if count > 0 {
               self.setSelectedPath(self.calculator!.uniquePaths[0]) 
            }
            
            Analytics.logEvent(AnalyticsEventViewItem, parameters: [
                AnalyticsParameterItemName: String(describing: ChooseCultureScene.self) as NSObject,
                "NumberOfCultures": count as NSObject
            ])
        }
    }
    
    func speakDetails(_ relative:LittlePerson) {
        let relationship = RelationshipCalculator.getAncestralRelationship(selectedPath!.treePath.count, p: relative, me: selectedPerson!, isRoot: false, isChild: false, isInLaw: false);
        
        relative.relationship = relationship
        let percString = String(format: "%.1f", selectedPath!.percent*100)
        var text = "You are \(percString) percent from \(selectedPath!.place) from your \(relationship). "
        if (relative.birthDate != nil) {
            let df = DateFormatter()
            df.dateStyle = .long
            let dateText = df.string(from: relative.birthDate!)
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

    
    func setSelectedPath(_ path:HeritagePath) {
        self.selectedPath = path
        
        titleLabel?.text = "Choose a country"

        //pathPerson?.person = self.calculator!.culturePeople[path.place.lowercaseString]![0]
        galleryAdapter?.people = self.calculator!.culturePeople[path.place.lowercased()]!
        pathPerson?.isHidden = false
        
        dollConfig = self.dolls.getDollConfig(path.place, person: selectedPerson!)

        let texture = SKTexture(imageNamed: dollConfig!.getThumbnail())
        let ratio = texture.size().width / texture.size().height
        doll?.size.width = (doll?.size.height)! * ratio
        doll?.texture = texture
        doll?.isHidden = false
        
        let personNode = pathPerson!.visibleNodes[0] as! PersonNameSprite
        
        countryLabel?.text = path.place
        countryLabel?.fontSize = personNode.nameLabel!.fontSize
        countryLabel?.isHidden = false
        
        speakDetails(personNode.person!)
        //speakDetails(pathPerson!.person!)
    }
    
    override func onEvent(_ topic: String, data: NSObject?) {
        super.onEvent(topic, data: data)
        if topic == ChooseCultureScene.TOPIC_PERSON_TOUCHED {
            let person = data as! LittlePerson
            self.speakDetails(person)
        } else if topic == LittleFamilyScene.TOPIC_TRY_PRESSED {
            let tryCount = getTryCount("try_heritage_count")
            DataService.getInstance().dbHelper.saveProperty("try_heritage_count", value: "\(tryCount)")
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            checkForPath(touch)
            break
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            checkForPath(touch)
            break
        }
    }

    func checkForPath(_ touch:UITouch) {
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        if touchedNode == self.doll || touchedNode == self.countryLabel {
            if dollConfig != nil {
                self.showDressupGame(dollConfig!, person: selectedPerson!, previousTopic: GameScene.TOPIC_START_DRESSUP)
                return
            }
        }
        
        var y:CGFloat = self.outlineSprite!.position.y - self.outlineSprite!.size.height / 2
        let x:CGFloat = self.whiteBackground!.position.x + self.whiteBackground!.size.width / 2
        let ty = self.size.height - touch.location(in: self.view).y
        let tx = touch.location(in: self.view).x
        if tx > x {
            return
        }
        let rpaths = self.calculator!.uniquePaths.reversed()
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
