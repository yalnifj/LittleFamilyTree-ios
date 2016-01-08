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
    var nameLabel:SKLabelNode?
    var relationshipLabel:SKLabelNode?
    var lastPoint : CGPoint!
    var game : PuzzleGame?
    var rows = 2
    var cols = 1
    var movingSprite:PuzzleSprite?
    var texture:SKTexture?
    var complete = false
    var animCount = 0
    
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
        
        randomMediaChooser.listener = self
        randomMediaChooser.addPeople([selectedPerson!])
        randomMediaChooser.loadMoreFamilyMembers()
    }
    
    override func willMoveFromView(view: SKView) {
        super.willMoveFromView(view)
    }
    
    override func update(currentTime: NSTimeInterval) {
        super.update(currentTime)
    }
    
    func onMediaLoaded(media:Media?) {
        if media == nil {
            randomMediaChooser.loadMoreFamilyMembers()
            return
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
            if nameLabel != nil {
                nameLabel?.removeFromParent()
            }
            if relationshipLabel != nil {
                relationshipLabel?.removeFromParent()
            }
            
            if cols < rows {
                cols++
            }
            else {
                rows++
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

            hintSprite = SKSpriteNode(texture: texture, size: CGSizeMake(w, h))
            hintSprite?.zPosition = 9
            hintSprite?.position = CGPointMake((self.size.width / 2), 30 + (self.size.height / 2) - (topBar?.size.height)!)
            hintSprite?.hidden = true
            self.addChild(hintSprite!)
            
            hintButton = SKSpriteNode(texture: texture, size: CGSizeMake(topBar!.size.height * ratio, topBar!.size.height))
            hintButton?.zPosition = 10
            hintButton!.position = CGPointMake(10 + hintButton!.size.width/2, 10 + hintButton!.size.height/2)
            self.addChild(hintButton!)
            
            game = PuzzleGame(texture: texture!, rows: rows, cols: cols)
            
            let pw = w / CGFloat(cols)
            let ph = h / CGFloat(rows)
            
            let oy = (hintSprite?.position.y)! - (hintSprite?.size.height)! / 2
            let ox = (hintSprite?.position.x)! - (hintSprite?.size.width)! / 2
            
            pieces = (game?.pieces)!
            for p in pieces {
                p.position = CGPointMake((CGFloat(p.col) * pw) + pw/2 + ox, (CGFloat(p.row) * ph) + ph/2 + oy)
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        for touch in touches {
            lastPoint = touch.locationInNode(self)
            let touchedNode = nodeAtPoint(lastPoint)
            if touchedNode == self.hintButton {
                hintSprite?.hidden = false
            } else if touchedNode is PuzzleSprite {
                let ps = touchedNode as! PuzzleSprite
                if ps.isPlaced() == false && ps.animating == false && animCount == 0{
                    movingSprite = ps
                    ps.zPosition = 3
                    ps.oldX = ps.position.x
                    ps.oldY = ps.position.y
                    break;
                }
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var nextPoint = CGPointMake(0,0)
        for touch in touches {
            nextPoint = touch.locationInNode(self)
            if movingSprite != nil {
                let dx = lastPoint.x - nextPoint.x
                let dy = lastPoint.y - nextPoint.y
                movingSprite?.position.x -= dx
                movingSprite?.position.y -= dy
            }
            break;
        }
        lastPoint = nextPoint
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        hintSprite?.hidden = true
        for touch in touches {
            lastPoint = touch.locationInNode(self)
            
            if movingSprite != nil {
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
                    let action = SKAction.moveTo(CGPointMake(oldX, oldY), duration: 0.6)
                    movingSprite!.animating = true
                    animCount++
                    movingSprite!.runAction(action, completion: {
                        self.movingSprite?.zPosition = 2
                        self.movingSprite?.animating = false
                        self.animCount--
                    })
                } else {
                    let mc = sprite?.col
                    let mr = sprite?.row
                    let sc = movingSprite!.col
                    let sr = movingSprite!.row
                    sprite?.zPosition = 3
                    let oldX = (movingSprite?.oldX)!
                    let oldY = (movingSprite?.oldY)!
                    let action = SKAction.moveTo(CGPointMake(oldX, oldY), duration: 0.6)
                    
                    let x = (sprite?.position.x)!
                    let y = (sprite?.position.y)!
                    let action2 = SKAction.moveTo(CGPointMake(x, y), duration: 0.6)
                    
                    sprite!.animating = true
                    animCount++
                    sprite!.runAction(action, completion: {
                        sprite?.zPosition = 2
                        sprite?.col = sc
                        sprite?.row = sr
                        sprite?.animating = false
                        self.animCount--
                        self.checkComplete()
                    })
                    movingSprite!.animating = true
                    animCount++
                    movingSprite!.runAction(action2, completion: {
                        self.movingSprite?.zPosition = 2
                        self.movingSprite?.col = mc
                        self.movingSprite?.row = mr
                        self.movingSprite?.animating = false
                        self.animCount--
                        self.checkComplete()
                        self.movingSprite = nil
                    })
                }
            }
            break;
        }
    }
    
    func checkComplete() {
        if !complete && self.game!.allPlaced() {
            complete = true
            self.hintSprite?.hidden = false
            self.hintButton?.hidden = true
            self.showStars((self.hintSprite?.frame)!, starsInRect: false, count: Int(self.size.width / CGFloat(40)), container: self)
            self.playSuccessSound(1.0, onCompletion: {
                self.nameLabel = SKLabelNode(text: self.randomMediaChooser.selectedPerson?.name as? String)
                self.nameLabel?.fontSize = self.size.height / 30
                self.nameLabel?.position = CGPointMake(self.size.width / 2, (self.nameLabel?.fontSize)! * 2)
                self.nameLabel?.zPosition = 12
                self.nameLabel?.fontName = (self.nameLabel?.fontName)! + "-Bold"
                self.addChild(self.nameLabel!)
                
                let relationship = RelationshipCalculator.getRelationship(self.selectedPerson, p: self.randomMediaChooser.selectedPerson)
                self.relationshipLabel = SKLabelNode(text: relationship)
                self.relationshipLabel?.fontSize = (self.nameLabel?.fontSize)!
                self.relationshipLabel?.position = CGPointMake(self.size.width / 2, (self.nameLabel?.fontSize)! / 2)
                self.relationshipLabel?.zPosition = 12
                self.relationshipLabel?.fontName = (self.nameLabel?.fontName)! + "-Bold"
                self.addChild(self.relationshipLabel!)
                
                SpeechHelper.getInstance().speak(self.randomMediaChooser.selectedPerson?.givenName as! String)
                let waitAction = SKAction.waitForDuration(2.5)
                self.runAction(waitAction) {
                    self.showLoadingDialog()
                    self.randomMediaChooser.loadRandomImage()
                }
            })
        }
    }
}