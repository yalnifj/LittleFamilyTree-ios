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
    var minSize:CGFloat = 5
    var brushSize:CGFloat = 15
    var brushColor:UIColor = UIColor.blue {
        didSet {
            if preview != nil {
                preview?.fillColor = brushColor
            }
        }
    }
    
    var listener : BrushSizeListener? {
        didSet {
            preview = SKShapeNode(circleOfRadius: maxSize/2)
            preview?.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
            preview?.fillColor = color
            preview?.strokeColor = UIColor.black
            preview?.glowWidth = 2.0
            preview?.setScale(brushSize/maxSize)
            self.addChild(preview!)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        for touch in touches {
            lastPoint = touch.location(in: self)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        var nextPoint = CGPoint(x: 0,y: 0)
        for touch in touches {
            nextPoint = touch.location(in: self)
            if lastPoint != nil {
                let dx = nextPoint.x - (lastPoint?.x)!
                let dy = nextPoint.y - (lastPoint?.y)!
                let distance = sqrt((dx*dx) + (dy*dy)) / 3
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
                let scaleAction = SKAction.scale(to: scale, duration: 0)
                preview?.run(scaleAction)
            }
        }
        lastPoint = nextPoint
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        lastPoint = nil
        if listener != nil {
            listener?.onBrushSizeChange(brushSize)
        }
    }

}

protocol BrushSizeListener {
    func onBrushSizeChange(_ size:CGFloat)
}
