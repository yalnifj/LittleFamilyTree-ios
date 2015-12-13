//
//  PuzzleGame.swift
//  Little Family Tree
//
//  Created by Melissa on 12/12/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class PuzzleGame {
    var pieces = [PuzzleSprite]()
    var texture:SKTexture
    var rows:Int
    var cols:Int
    var pieceWidth:CGFloat
    var pieceHeight:CGFloat
    
    init(texture:SKTexture, rows:Int, cols:Int) {
        self.rows = rows
        self.cols = cols
        self.texture = texture
        
        pieceWidth = texture.size().width / CGFloat(self.cols)
        pieceHeight = texture.size().height / CGFloat(self.rows)
        
        // create pieces
        for r in  0..<self.rows {
            let y = CGFloat(r) * pieceHeight
            for c in 0..<self.cols {
                let x = CGFloat(c) * pieceWidth
                let rect = CGRectMake(x, y, pieceWidth, pieceHeight)
                let tp = SKTexture(rect: rect , inTexture: self.texture)
                let piece = PuzzleSprite(texture: tp)
                piece.correctCol = c
                piece.correctRow = r
                piece.col = c
                piece.row = r
                pieces.append(piece)
            }
        }
        self.shuffle()
    }
    
    func shuffle() {
        var i = 1
        for p1 in pieces {
            let r = i + Int(arc4random_uniform(UInt32(pieces.count - i)))
            if r < pieces.count {
            let p2 = pieces[r]
                let col = p2.col
                let row = p2.row
                p2.col = p1.col
                p2.row = p1.row
                p1.col = col
                p2.row = row
                i++
            }
        }
    }
}