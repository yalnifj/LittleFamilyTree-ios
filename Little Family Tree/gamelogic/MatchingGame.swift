//
//  MatchingGame.swift
//  Little Family Tree
//
//  Created by Melissa on 11/25/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation

class MatchingGame {
    static var frameCount:UInt32 = 7
    var level:Int
    var peoplePool:[LittlePerson]
    var board:[MatchPerson]?
    
    init(startingLevel:Int, people:[LittlePerson]) {
        self.level = startingLevel
        if (self.level < 1) { self.level = 1 }
        self.peoplePool = people
    }
    
    func setupLevel() {
        let gridSize = level+1;
        board = [MatchPerson]()
        for i in 0..<gridSize {
            let p = peoplePool[i % peoplePool.count]
            let frame1 = Int(arc4random_uniform(MatchingGame.frameCount)) + 1
            let m1 = MatchPerson(person: p, frame: frame1)
            board!.append(m1);
            let frame2 = Int(arc4random_uniform(MatchingGame.frameCount)) + 1
            let m2 = MatchPerson(person: p, frame: frame2)
            board!.append(m2);
        }
        
        randomizeBoard();
    }
    
    func randomizeBoard() {
        for _ in 0..<board!.count {
            let r1 = Int(arc4random_uniform(UInt32(board!.count)))
            let r2 = Int(arc4random_uniform(UInt32(board!.count)))
            let p1 = board![r1];
            let p2 = board![r2];
            board![r2] = p1
            board![r1] = p2
        }
    }
    
    func isMatch(pos1:Int, pos2:Int) -> Bool {
        if (pos1 != pos2 && pos1 >= 0 && pos2 >= 0 && pos1 < board!.count && pos2 < board!.count) {
            let p1 = board![pos1]
            let p2 = board![pos2]
            if p1.person == p2.person {
                return true
            }
        }
        return false;
    }
    
    func allMatched() -> Bool {
        for p in board! {
            if !p.matched {
                return false
            }
        }
        return true
    }

    func levelUp() {
        self.level += 1
        setupLevel()
    }
    
}