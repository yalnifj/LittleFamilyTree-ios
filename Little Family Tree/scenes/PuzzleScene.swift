//
//  PuzzleScene.swift
//  Little Family Tree
//
//  Created by Melissa on 12/10/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class PuzzleScene: LittleFamilyScene, RandomMediaListener {
    var randomMediaChooser = RandomMediaChooser.getInstance()
    
    var pieces = [PuzzleSprite]()
    var hintSprite:SKSpriteNode?
    var hintButton:SKSpriteNode?
    var lastPoint : CGPoint!
    var game : PuzzleGame?
    var rows = 2
    var cols = 1
    var movingSprite:PuzzleSprite?
    var texture:SKTexture?
    var complete = false
    var animCount = 0
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.size.width = view.bounds.width
        self.size.height = view.bounds.height
        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        let background = SKSpriteNode(imageNamed: "puzzle_background")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.size.width = self.size.width
        background.size.height = self.size.height
        background.zPosition = 0
        self.addChild(background)
        
        setupTopBar()
        
        showLoadingDialog()
        
        randomMediaChooser.listener = self
        randomMediaChooser.addPeople([selectedPerson!])
        randomMediaChooser.loadMoreFamilyMembers()
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
    }
    
    func onMediaLoaded(_ media:Media?) {
        if media == nil {
            if randomMediaChooser.counter < randomMediaChooser.maxTries {
                randomMediaChooser.loadMoreFamilyMembers()
                return
            } else {
                DispatchQueue.main.async {
                    self.hideLoadingDialog()
                    self.showSimpleDialog("No Pictures Found", message: "There are not many pictures in your family tree. This activity requires pictures. Please add more pictures to your online family tree.")
                }
                return
            }
        }
        
        let texture = TextureHelper.getTextureForMedia(media!, size: self.size)
        if texture != nil {
            complete = false
            for p in pieces {
                p.removeFromParent()
            }
            pieces.removeAll()
            
            if hintButton != nil {
                hintButton?.removeFromParent()
            }
            if hintSprite != nil {
                hintSprite?.removeFromParent()
            }
            
            if cols < rows {
                cols += 1
            }
            else {
                rows += 1
            }
            
            self.texture = texture
            let ratio = (texture?.size().width)! / (texture?.size().height)!
            var w = self.size.width
            var h = self.size.height - (topBar?.size.height)! * 3
            if ratio < 1.0 || w > h  {
                w = h * ratio
            } else {
                h = w / ratio
            }

            hintSprite = SKSpriteNode(texture: texture, size: CGSize(width: w, height: h))
            hintSprite?.zPosition = 9
            hintSprite?.position = CGPoint(x: (self.size.width / 2), y: 30 + (self.size.height / 2) - (topBar?.size.height)!)
            hintSprite?.isHidden = true
            self.addChild(hintSprite!)
            
            hintButton = SKSpriteNode(texture: texture, size: CGSize(width: topBar!.size.height * ratio, height: topBar!.size.height))
            hintButton?.zPosition = 10
            hintButton!.position = CGPoint(x: 10 + hintButton!.size.width/2, y: 10 + hintButton!.size.height/2)
            self.addChild(hintButton!)
            
            game = PuzzleGame(texture: texture!, rows: rows, cols: cols)
            
            let pw = w / CGFloat(cols)
            let ph = h / CGFloat(rows)
            
            let oy = (hintSprite?.position.y)! - (hintSprite?.size.height)! / 2
            let ox = (hintSprite?.position.x)! - (hintSprite?.size.width)! / 2
            
            pieces = (game?.pieces)!
            for p in pieces {
                p.position = CGPoint(x: (CGFloat(p.col) * pw) + pw/2 + ox, y: (CGFloat(p.row) * ph) + ph/2 + oy)
                p.zPosition = 2
                p.size.width = pw - 1
                p.size.height = ph - 1
                self.addChild(p)
            }

            hideLoadingDialog()
            
        } else {
            randomMediaChooser.loadMoreFamilyMembers()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch = touches.first
        if touch != nil && movingSprite == nil {
            lastPoint = touch!.location(in: self)
            print("began \(lastPoint)")
            let touchedNode = atPoint(lastPoint)
            if touchedNode == self.hintButton {
                hintSprite?.isHidden = false
            } else if touchedNode is PuzzleSprite {
                let ps = touchedNode as! PuzzleSprite
                if ps.isPlaced() == false && ps.animating == false && animCount == 0 {
                    movingSprite = ps
                    ps.zPosition = 3
                    ps.oldX = ps.position.x
                    ps.oldY = ps.position.y
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        var nextPoint = CGPoint(x: 0,y: 0)
        let touch = touches.first
        if touch != nil {
            nextPoint = touch!.location(in: self)
            if movingSprite != nil {
                print("moved \(nextPoint)")
                let dx = lastPoint.x - nextPoint.x
                let dy = lastPoint.y - nextPoint.y
                movingSprite?.position.x -= dx
                movingSprite?.position.y -= dy
            }
        }
        lastPoint = nextPoint
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        hintSprite?.isHidden = true
        let touch = touches.first
        if touch != nil {
            lastPoint = touch!.location(in: self)
            print("ended \(lastPoint)")
            doneMoving()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        hintSprite?.isHidden = true
        print("cancelled \(lastPoint)")
        doneMoving()
    }
    
    func doneMoving() {
        if movingSprite != nil && animCount == 0 {
            let oy = (hintSprite?.position.y)! - (hintSprite?.size.height)! / 2
            let row = Int(((movingSprite?.position.y)! - oy) / (movingSprite?.size.height)!)
            let ox = (hintSprite?.position.x)! - (hintSprite?.size.width)! / 2
            let col = Int(((movingSprite?.position.x)! - ox) / (movingSprite?.size.width)!)
            
            var sprite:PuzzleSprite? = nil
            for s in pieces {
                if s.row == row && s.col == col {
                    sprite = s
                    break
                }
            }
            if sprite == nil || sprite == movingSprite || sprite?.isPlaced()==true || sprite?.animating==true {
                //-- return to old position
                let oldX = (movingSprite?.oldX)!
                let oldY = (movingSprite?.oldY)!
                let action = SKAction.move(to: CGPoint(x: oldX, y: oldY), duration: 0.6)
                movingSprite!.animating = true
                animCount += 1
                movingSprite!.run(action, completion: {
                    self.movingSprite?.zPosition = 2
                    self.movingSprite?.animating = false
                    self.animCount -= 1
                    self.movingSprite = nil
                })
            } else {
                let mc = sprite?.col
                let mr = sprite?.row
                let sc = movingSprite!.col
                let sr = movingSprite!.row
                sprite?.zPosition = 3
                let oldX = (movingSprite?.oldX)!
                let oldY = (movingSprite?.oldY)!
                let action = SKAction.move(to: CGPoint(x: oldX, y: oldY), duration: 0.6)
                
                let x = (sprite?.position.x)!
                let y = (sprite?.position.y)!
                let action2 = SKAction.move(to: CGPoint(x: x, y: y), duration: 0.6)
                
                sprite!.animating = true
                animCount += 1
                sprite!.run(action, completion: {
                    sprite?.zPosition = 2
                    sprite?.col = sc
                    sprite?.row = sr
                    sprite?.animating = false
                    self.animCount -= 1
                    self.checkComplete()
                })
                movingSprite!.animating = true
                animCount += 1
                movingSprite!.run(action2, completion: {
                    self.movingSprite?.zPosition = 2
                    self.movingSprite?.col = mc
                    self.movingSprite?.row = mr
                    self.movingSprite?.animating = false
                    self.animCount -= 1
                    self.checkComplete()
                    self.movingSprite = nil
                })
            }
        }
    }
    
    func checkComplete() {
        if !complete && self.game!.allPlaced() {
            complete = true
            self.hintSprite?.isHidden = false
            self.hintButton?.isHidden = true
            self.showStars((self.hintSprite?.frame)!, starsInRect: false, count: Int(self.size.width / CGFloat(40)), container: self)
            self.playSuccessSound(1.0, onCompletion: {
                let relationship = RelationshipCalculator.getRelationship(self.selectedPerson, p: self.randomMediaChooser.selectedPerson)
                self.showFakeToasts([self.randomMediaChooser.selectedPerson!.name!, relationship])
                
                self.sayGivenName(self.randomMediaChooser.selectedPerson!)
                let waitAction = SKAction.wait(forDuration: 2.5)
                self.run(waitAction, completion: {
                    self.showLoadingDialog()
                    self.randomMediaChooser.loadRandomImage()
                }) 
            })
        }
    }
}
