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
            if (colorPalette?.size.height)! > self.size.height {
                colorPalette?.size.height = self.size.height
                colorPalette?.size.width = self.size.height / ratio
            }
            colorPalette?.zPosition = 1
            colorPalette?.position = CGPoint(x: (colorPalette?.size.width)! / 2, y: (colorPalette?.size.height)! / 2)
            self.addChild(colorPalette!)
        }
    }
    var paintbrush:SKSpriteNode? {
        didSet {
            setupColors()
            
            /*
            var i = 0
            for r in colorRects {
                let temp = SKSpriteNode(color: colors[i], size: r.size)
                temp.position = r.origin
                temp.zPosition = 3
                self.addChild(temp)
                i++
            }
            */
            
            let ratio = (paintbrush?.size.height)! / (paintbrush?.size.width)!
            paintbrush?.size.width = (colorPalette?.size.height)! / 2
            paintbrush?.size.height = ratio * (colorPalette?.size.height)! / 2
            paintbrush?.zPosition = 2
            paintbrush?.position = CGPoint(x: colorRects.last!.origin.x + colorRects.last!.size.width/4, y: colorRects.last!.origin.y)
            self.addChild(paintbrush!)
        }
    }
    
    var colorRects = [CGRect]()
    var colors = [UIColor]()
    var activeColor:UIColor?
    
    func setupColors() {
        let rw = (colorPalette?.size.width)! / (colorPalette?.texture!.size().width)!
        let rh = (colorPalette?.size.height)! / (colorPalette?.texture!.size().height)!
        
        let dr = CGRect(x: 65*rw, y: 110*rh, width: 56*rw, height: 57*rh)
        colorRects.append(dr)
        colors.append(UIColor(hexString: "#aa000044"))
        
        let rr = CGRect(x: 135*rw, y: 110*rh, width: 56*rw, height: 57*rh)
        colorRects.append(rr);
        colors.append(UIColor(hexString: "#ff000044"))
        
        let o = CGRect(x: 210*rw, y: 110*rh, width: 56*rw, height: 57*rh)
        colorRects.append(o);
        colors.append(UIColor(hexString: "#ff660044"));
        
        let g = CGRect(x: 285*rw, y: 110*rh, width: 56*rw, height: 57*rh)
        colorRects.append(g);
        colors.append(UIColor(hexString: "#d4aa0044"));
        
        let y = CGRect(x: 355*rw, y: 110*rh, width: 56*rw, height: 57*rh)
        colorRects.append(y);
        colors.append(UIColor(hexString: "#ffff0044"));
        
        let gr = CGRect(x: 425*rw, y: 110*rh, width: 56*rw, height: 57*rh)
        colorRects.append(gr);
        colors.append(UIColor(hexString: "#00b10044"));
        
        let dg = CGRect(x: 75*rw, y: 35*rh, width: 55*rw, height: 57*rh)
        colorRects.append(dg);
        colors.append(UIColor(hexString: "#006c0044"));
        
        let b = CGRect(x: 145*rw, y: 35*rh, width: 56*rw, height: 57*rh)
        colorRects.append(b);
        colors.append(UIColor(hexString: "#0000cf44"));
        
        let db = CGRect(x: 218*rw, y: 35*rh, width: 56*rw, height: 57*rh)
        colorRects.append(db);
        colors.append(UIColor(hexString: "#00006f44"));
        
        let p = CGRect(x: 287*rw, y: 35*rh, width: 56*rw, height: 57*rh)
        colorRects.append(p);
        colors.append(UIColor(hexString: "#6400aa44"));
        
        let br = CGRect(x: 357*rw, y: 35*rh, width: 56*rw, height: 57*rh)
        colorRects.append(br);
        colors.append(UIColor(hexString: "#80330044"));
        
        let wh = CGRect(x: 430*rw, y: 35*rh, width: 56*rw, height: 57*rh)
        colorRects.append(wh);
        colors.append(UIColor(hexString: "#00000000"));
        
        activeColor = colors.last!
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            var position = touch.location(in: colorPalette!)
            position.x = position.x + colorPalette!.size.width / 2
            position.y = position.y + colorPalette!.size.height / 2
            
            if selectColor(position) {
                break
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            var position = touch.location(in: colorPalette!)
            position.x = position.x + colorPalette!.size.width / 2
            position.y = position.y + colorPalette!.size.height / 2
            
            if selectColor(position) {
                break
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            var position = touch.location(in: colorPalette!)
            position.x = position.x + colorPalette!.size.width / 2
            position.y = position.y + colorPalette!.size.height / 2
            
            if selectColor(position) {
                break
            }
        }
    }
    
    func selectColor(_ position:CGPoint) -> Bool {
        var rect:CGRect? = nil
        var i = 0
        for r in colorRects {
            //print("r=\(r) position=\(position)")
            if r.contains(position) ||
                (position.x >= r.origin.x && position.x <= r.origin.x + r.size.width && position.y >= r.origin.y && position.y <= r.origin.y + r.size.height){
                    rect = r
                    break
            }
            i += 1
        }
        if rect != nil {
            //print("rect=\(rect)")
            activeColor = colors[i]
            paintbrush?.position = CGPoint(x: rect!.origin.x + rect!.size.width/3, y: rect!.origin.y + rect!.size.height/3)
            if listener != nil {
                listener?.onColorChange(activeColor!)
            }
            return true
        }
        return false
    }
    
}

protocol ColorPaletteListener {
    func onColorChange(_ color:UIColor)
}
