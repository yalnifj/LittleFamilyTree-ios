//
//  RecentPersonTracker.swift
//  Little Family Tree
//
//  Created by Melissa on 12/30/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation

class RecentPersonTracker
{
    var recentPersonIds = [Int64]()
    var maxRecent:Int = 16
    
    private static var instance:RecentPersonTracker?
    
    static func getInstance() -> RecentPersonTracker {
        if (instance == nil) {
            instance = RecentPersonTracker()
        }
    
        return instance!
    }
    
    func addPerson(person:LittlePerson) {
        recentPersonIds.removeObject(person.id!)
        recentPersonIds.append(person.id!);
        if (recentPersonIds.count > maxRecent) {
            recentPersonIds.removeFirst()
        }
    }
    
    func personRecentlyUsed(person:LittlePerson) -> Bool {
        if recentPersonIds.contains(person.id!) {
            return true
        }
        return false
    }
}