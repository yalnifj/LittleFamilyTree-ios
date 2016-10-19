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
        let pw = pieceWidth / texture.size().width
        let ph = pieceHeight / texture.size().height
        
        // create pieces
        for r in  0..<self.rows {
            let y = CGFloat(r) * ph
            for c in 0..<self.cols {
                let x = CGFloat(c) * pw
                let rect = CGRect(x: x, y: y, width: pw, height: ph)
                let tp = SKTexture(rect: rect , in: self.texture)
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
        for i in 0..<pieces.count {
            let r = Int(arc4random_uniform(UInt32(pieces.count)))
            if r != i {
                let p1 = pieces[i]
                let p2 = pieces[r]
                let col = p2.col
                let row = p2.row
                p2.col = p1.col
                p2.row = p1.row
                p1.col = col
                p1.row = row
            }
        }
        if allPlaced() {
            shuffle()
        }
    }
    
    func allPlaced() -> Bool {
        var allPlaced = true
        for p in self.pieces {
            if p.isPlaced() == false {
                allPlaced = false
                break
            }
        }
        return allPlaced
    }
}
