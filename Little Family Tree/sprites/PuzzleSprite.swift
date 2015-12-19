//
//  PuzzleSprite.swift
//  Little Family Tree
//
//  Created by Melissa on 12/12/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation
import SpriteKit

class PuzzleSprite: SKSpriteNode {
    var row:Int!
    var col:Int!
    var correctRow:Int!
    var correctCol:Int!
    var oldX:CGFloat?
    var oldY:CGFloat?
    var animating = false

    func isPlaced() -> Bool {
        if row == correctRow && col == correctCol {
            return true
        }
        return false
    }
}