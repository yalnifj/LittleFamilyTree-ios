//
//  InitialDataLoader.swift
//  Little Family Tree
//
//  Created by Melissa on 11/13/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation

class InitialDataLoader {
    var person:LittlePerson
    var listener:StatusListener
    var dataService:DataService
    var onCompletion:PeopleResponse?
    
    var familyMembers = [LittlePerson]()
    var grandParents = [LittlePerson]()
    var grandChildren = [LittlePerson]()
    
    init(person:LittlePerson, listener:StatusListener) {
        self.person = person
        self.listener = listener
        self.dataService = DataService.getInstance()
    }
    
    func execute(onCompletion:PeopleResponse) {
        print("Starting InitialDataLoader \(self)")
        self.onCompletion = onCompletion
        dataService.getFamilyMembers(self.person, loadSpouse: true, onCompletion: self.familyCallback)
    }
    
    func familyCallback(people:[LittlePerson]?, err: NSError?) {
        print("InitialDataLoader onComplete callback")
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        let downloadGroup = dispatch_group_create()
        let downloadGroup2 = dispatch_group_create()
        let downloadGroup3 = dispatch_group_create()
        
        dispatch_group_enter(downloadGroup)
        
        familyMembers.append(self.person)
        if people != nil {
            for person in people! {
                if familyMembers.contains(person) == false {
                    familyMembers.append(person)
                    dataService.addToSyncQ(person)
                }
            }
        }
        
        var copy = [LittlePerson]()
        for p in familyMembers {
            copy.append(p)
            if p != self.person {
                dispatch_group_enter(downloadGroup2)
            }
        }
        
        for i in 0..<copy.count {
            print("loop \(i)")
            let p = copy[i]
            if p != self.person {
                dataService.getParents(p, onCompletion: { parents, err in
                    if parents != nil {
                        for parent in parents! {
                            if (!self.familyMembers.contains(parent) && !self.grandParents.contains(parent)) {
                                self.grandParents.append(parent)
                                self.dataService.addToSyncQ(parent)
                                dispatch_group_enter(downloadGroup2)
                            }
                        }
                        for parent in parents! {
                            if (!self.familyMembers.contains(parent) && !self.grandParents.contains(parent)) {
                                self.dataService.getParents(parent, onCompletion: { parents2, err in
                                    if parents2 != nil {
                                        for parent2 in parents2! {
                                            self.dataService.addToSyncQ(parent2)
                                        }
                                    }
                                    dispatch_group_leave(downloadGroup2)
                                })
                            }
                        }
                    }
                    dispatch_group_leave(downloadGroup2)
                })
            }
        }
        
        dispatch_group_notify(downloadGroup2, queue) {
            var copy = [LittlePerson]()
            for p in self.familyMembers {
                copy.append(p)
                if p != self.person {
                    dispatch_group_enter(downloadGroup3)
                }
            }
            
            for i in 0..<copy.count {
                print("loop2 \(i)")
                let p = copy[i]
                if p != self.person {
                    self.dataService.getChildren(p, onCompletion: { children, err in
                        if children != nil {
                            for child in children! {
                                if (!self.familyMembers.contains(child) && !self.grandChildren.contains(child)) {
                                    self.grandChildren.append(child)
                                    self.dataService.addToSyncQ(child)
                                    dispatch_group_enter(downloadGroup3)
                                }
                            }
                            for child in children! {
                                if (!self.familyMembers.contains(child) && !self.grandChildren.contains(child)) {
                                    self.dataService.getChildren(child, onCompletion: {children2, err2 in
                                        if children2 != nil {
                                            for child2 in children2! {
                                                if (!self.grandChildren.contains(child2)) {
                                                    self.grandChildren.append(child2)
                                                    self.dataService.addToSyncQ(child2)
                                                }
                                            }
                                        }
                                        dispatch_group_leave(downloadGroup3)
                                    })
                                }
                            }
                        }
                        dispatch_group_leave(downloadGroup3)
                    })
                }
            }
        }
        
        dispatch_group_notify(downloadGroup3, queue) {
            dispatch_group_leave(downloadGroup)
        }
        
        dispatch_group_notify(downloadGroup, queue) {
            for p in self.grandChildren {
                if (!self.familyMembers.contains(p)) {
                    self.familyMembers.append(p)
                }
            }
            self.onCompletion!(self.familyMembers, nil)
        }

    }
}