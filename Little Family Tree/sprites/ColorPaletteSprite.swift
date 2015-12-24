//
//  ColorPaletteSprite.swift
//  Little Family Tree
//
//  Created by Melissa on 12/22/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class ColorPaletteSprite : SKSpriteNode {
    var listener:ColorPaletteListener?
    
    var colorPalette:SKSpriteNode? {
        didSet {
            let ratio = (colorPalette?.size.height)! / (colorPalette?.size.width)!
            colorPalette?.size.width = self.size.width
            colorPalette?.size.height = self.size.width * ratio
            colorPalette?.zPosition = 1
            colorPalette?.position = CGPointMake(self.size.width / 2, self.size.height / 2)
            self.addChild(colorPalette!)
        }
    }
    var paintbrush:SKSpriteNode? {
        didSet {
            setupColors()
            
            
            var i = 0
            for r in colorRects {
                let temp = SKSpriteNode(color: colors[i], size: r.size)
                temp.position = r.origin
                temp.zPosition = 3
                self.addChild(temp)
                i++
            }
            
            
            let ratio = (paintbrush?.size.height)! / (paintbrush?.size.width)!
            paintbrush?.size.width = (colorPalette?.size.height)! / 2
            paintbrush?.size.height = ratio * (colorPalette?.size.height)! / 2
            paintbrush?.zPosition = 2
            paintbrush?.position = CGPointMake(colorRects.last!.origin.x + colorRects.last!.size.width/4, colorRects.last!.origin.y)
            self.addChild(paintbrush!)
        }
    }
    
    var colorRects = [CGRect]()
    var colors = [UIColor]()
    var activeColor:UIColor?
    
    func setupColors() {
        let r = (colorPalette?.size.width)! / (colorPalette?.texture!.size().width)!
        
        let dr = CGRectMake(65*r, 133*r, 56*r, 57*r)
        colorRects.append(dr)
        colors.append(UIColor(hexString: "#aa000044"))
        
        let rr = CGRectMake(135*r, 133*r, 56*r, 57*r)
        colorRects.append(rr);
        colors.append(UIColor(hexString: "#ff000044"))
        
        let o = CGRectMake(210*r, 133*r, 56*r, 57*r)
        colorRects.append(o);
        colors.append(UIColor(hexString: "#ff660044"));
        
        let g = CGRectMake(285*r, 133*r, 56*r, 57*r)
        colorRects.append(g);
        colors.append(UIColor(hexString: "#d4aa0044"));
        
        let y = CGRectMake(355*r, 133*r, 56*r, 57*r)
        colorRects.append(y);
        colors.append(UIColor(hexString: "#ffff0044"));
        
        let gr = CGRectMake(425*r, 133*r, 56*r, 57*r)
        colorRects.append(gr);
        colors.append(UIColor(hexString: "#00b10044"));
        
        let dg = CGRectMake(75*r, 71*r, 55*r, 57*r)
        colorRects.append(dg);
        colors.append(UIColor(hexString: "#006c0044"));
        
        let b = CGRectMake(145*r, 71*r, 55*r, 57*r)
        colorRects.append(b);
        colors.append(UIColor(hexString: "#0000cf44"));
        
        let db = CGRectMake(218*r, 71*r, 55*r, 57*r)
        colorRects.append(db);
        colors.append(UIColor(hexString: "#00006f44"));
        
        let p = CGRectMake(287*r, 70*r, 55*r, 57*r)
        colorRects.append(p);
        colors.append(UIColor(hexString: "#6400aa44"));
        
        let br = CGRectMake(357*r, 70*r, 55*r, 57*r)
        colorRects.append(br);
        colors.append(UIColor(hexString: "#80330044"));
        
        let wh = CGRectMake(430*r, 70*r, 55*r, 57*r)
        colorRects.append(wh);
        colors.append(UIColor(hexString: "#00000000"));
        
        activeColor = colors.last!
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let position = touch.locationInNode(self)
            print("position=\(position)")
            var rect:CGRect?
            var i = 0
            for r in colorRects {
                if r.contains(position) {
                    rect = r
                    break
                }
                i++
            }
            if rect != nil {
                print("rect=\(rect)")
                activeColor = colors[i]
                paintbrush?.position = CGPointMake(rect!.origin.x + rect!.size.width/4, rect!.origin.y)
                if listener != nil {
                    listener?.onColorChange(activeColor!)
                }
            }
        }
    }
    
}

protocol ColorPaletteListener {
    func onColorChange(color:UIColor)
}