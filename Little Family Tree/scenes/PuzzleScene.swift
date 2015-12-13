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
        
        randomMediaChooser.listener = self
        randomMediaChooser.addPeople([selectedPerson!])
        randomMediaChooser.loadMoreFamilyMembers()
    }
    
    override func willMoveFromView(view: SKView) {
        super.willMoveFromView(view)
    }
    
    override func update(currentTime: NSTimeInterval) {
        
    }
    
    func onMediaLoaded(media:Media?) {
        if media == nil {
            randomMediaChooser.loadMoreFamilyMembers()
            return
        }
        
        let texture = TextureHelper.getTextureForMedia(media!)
        if texture != nil {
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
                cols++
            }
            else {
                rows++
            }
            game = PuzzleGame(texture: texture!, rows: rows, cols: cols)
            
            let ratio = (texture?.size().width)! / (texture?.size().height)!
            var w = self.size.width
            var h = self.size.height - (topBar?.size.height)!
            if h < w {
                w = h * ratio
            } else {
                h = w / ratio
            }
            
            let pw = w / CGFloat(cols)
            let ph = h / CGFloat(rows)
            
            pieces = (game?.pieces)!
            for p in pieces {
                p.position = CGPointMake((CGFloat(p.col) * w) + w/2, (CGFloat(p.row) * h) + h/2)
                p.zPosition = 2
                p.size.width = pw
                p.size.height = ph
                self.addChild(p)
            }
            
            hintSprite = SKSpriteNode(texture: texture, size: CGSizeMake(w, h))
            hintSprite?.zPosition = 9
            hintSprite?.position = CGPointMake(self.size.width / 2, h / 2)
            hintSprite?.size.width = w
            hintSprite?.size.height = h
            hintSprite?.hidden = true
            self.addChild(hintSprite!)
            
            hintButton = SKSpriteNode(texture: texture, size: CGSizeMake(topBar!.size.height, topBar!.size.height))
            hintButton?.zPosition = 10
            hintButton!.position = CGPointMake(10 + hintButton!.size.width/2, 10 + hintButton!.size.height/2)
            self.addChild(hintButton!)
            
        } else {
            randomMediaChooser.loadMoreFamilyMembers()
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        for touch in touches {
            lastPoint = touch.locationInNode(self)
            let touchedNode = nodeAtPoint(lastPoint)
            if touchedNode == hintSprite {
                hintSprite?.hidden = false
            } else if touchedNode is PuzzleSprite {
                let ps = touchedNode as! PuzzleSprite
                if !ps.isPlaced() {
                    movingSprite = ps
                    ps.zPosition = 3
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
        }
        lastPoint = nextPoint
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        for touch in touches {
            lastPoint = touch.locationInNode(self)
            let touchedNode = nodeAtPoint(lastPoint)
            if touchedNode == hintSprite {
                hintSprite?.hidden = true
            }
            
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
                if sprite == nil || sprite?.isPlaced()==true {
                    //-- return to old position
                    var oldX = CGFloat((movingSprite?.col)!) * (movingSprite?.size.width)!
                    oldX = oldX + ox + (movingSprite?.size.width)! / 2
                    var oldY = CGFloat((movingSprite?.row)!) * (movingSprite?.size.height)!
                    oldY = oldY + oy + (movingSprite?.size.height)! / 2
                    let action = SKAction.moveTo(CGPointMake(oldX, oldY), duration: 1.0)
                    movingSprite!.runAction(action, completion: {
                        self.movingSprite?.zPosition = 2
                    })
                } else {
                    let mc = sprite?.col
                    let mr = sprite?.row
                    let sc = movingSprite!.col
                    let sr = movingSprite!.row
                    sprite?.zPosition = 3
                    var oldX = CGFloat((movingSprite?.col)!) * (movingSprite?.size.width)!
                    oldX = oldX + ox + (movingSprite?.size.width)! / 2
                    var oldY = CGFloat((movingSprite?.row)!) * (movingSprite?.size.height)!
                    oldY = oldY + oy + (movingSprite?.size.height)! / 2
                    let action = SKAction.moveTo(CGPointMake(oldX, oldY), duration: 1.0)
                    
                    var x = CGFloat((sprite?.col)!) * (sprite?.size.width)!
                    x = x + ox + (sprite?.size.width)! / 2
                    var y = CGFloat((sprite?.row)!) * (sprite?.size.height)!
                    y = y + oy + (sprite?.size.height)! / 2
                    let action2 = SKAction.moveTo(CGPointMake(x, y), duration: 0.5)
                    
                    sprite!.runAction(action, completion: {
                        sprite?.zPosition = 2
                        sprite?.col = mc
                        sprite?.row = mr
                        
                        var allPlaced = true
                        for p in self.pieces {
                            if p.isPlaced() == false {
                                allPlaced = false
                                break
                            }
                        }
                        
                        if allPlaced {
                            self.playSuccessSound(0.5, onCompletion: {
                                self.randomMediaChooser.loadRandomImage()
                            })
                        }
                    })
                    movingSprite!.runAction(action2, completion: {
                        self.movingSprite?.zPosition = 2
                        self.movingSprite?.col = sc
                        self.movingSprite?.row = sr
                    })
                }
            }
        }
        movingSprite = nil
    }
}