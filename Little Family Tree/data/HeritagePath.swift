//
//  HeritagePath.swift
//  Little Family Tree
//
//  Created by Melissa on 11/27/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation

class HeritagePath : Comparable {
    var treePath = [LittlePerson]()
    var percent = 0.0
    var place:String
    
    init(place:String) {
        self.place = place
    }
}
func ==(lhs: HeritagePath, rhs: HeritagePath) -> Bool {
    return lhs.place == rhs.place && lhs.treePath.count == rhs.treePath.count && lhs.percent == rhs.percent
}
func <(lhs: HeritagePath, rhs: HeritagePath) -> Bool {
    return lhs.percent < rhs.percent
}
func <=(lhs: HeritagePath, rhs: HeritagePath) -> Bool {
    return lhs.percent <= rhs.percent
}
func >(lhs: HeritagePath, rhs: HeritagePath) -> Bool {
    return lhs.percent > rhs.percent
}
func >=(lhs: HeritagePath, rhs: HeritagePath) -> Bool {
    return lhs.percent >= rhs.percent
}