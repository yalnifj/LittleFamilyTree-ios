//
//  BrushSizeSprite.swift
//  Little Family Tree
//
//  Created by Melissa on 12/23/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class BrushSizeSprite : SKSpriteNode {
    var preview : SKShapeNode?
    var lastPoint : CGPoint?
    var maxSize:CGFloat = 30
    var minSize:CGFloat = 1
    var brushSize:CGFloat = 15
    var brushColor:UIColor = UIColor.blueColor() {
        didSet {
            if preview != nil {
                preview?.fillColor = brushColor
            }
        }
    }
    
    var listener : BrushSizeListener? {
        didSet {
            preview = SKShapeNode(circleOfRadius: maxSize/2)
            preview?.position = CGPointMake(self.size.width / 2, self.size.height / 2)
            preview?.fillColor = color
            preview?.strokeColor = UIColor.blackColor()
            preview?.glowWidth = 2.0
            preview?.setScale(brushSize/maxSize)
            self.addChild(preview!)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        for touch in touches {
            lastPoint = touch.locationInNode(self)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var nextPoint = CGPointMake(0,0)
        for touch in touches {
            nextPoint = touch.locationInNode(self)
            if lastPoint != nil {
                let dx = nextPoint.x - (lastPoint?.x)!
                let dy = nextPoint.y - (lastPoint?.y)!
                let distance = sqrt((dx*dx) + (dy*dy)) / 5
                if dx < 0 || dy < 0 {
                    brushSize -= distance
                } else {
                    brushSize += distance
                }
                if brushSize < minSize {
                    brushSize = minSize
                }
                if brushSize > maxSize {
                    brushSize = maxSize
                }
                let scale = brushSize / maxSize
                let scaleAction = SKAction.scaleTo(scale, duration: 0)
                preview?.runAction(scaleAction)
            }
        }
        lastPoint = nextPoint
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        lastPoint = nil
        if listener != nil {
            listener?.onBrushSizeChange(brushSize)
        }
    }

}

protocol BrushSizeListener {
    func onBrushSizeChange(size:CGFloat)
}