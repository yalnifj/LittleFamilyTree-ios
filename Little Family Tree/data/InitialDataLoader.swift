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
    
    func execute(_ onCompletion:@escaping PeopleResponse) {
        print("Starting InitialDataLoader \(self)")
        self.onCompletion = onCompletion
        dataService.getFamilyMembers(self.person, loadSpouse: true, onCompletion: self.familyCallback)
    }
    
    func familyCallback(_ people:[LittlePerson]?, err: NSError?) {
        print("InitialDataLoader onComplete callback")
        let queue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)
        let downloadGroup = DispatchGroup()
        let downloadGroup2 = DispatchGroup()
        let downloadGroup3 = DispatchGroup()
        
        downloadGroup.enter()
        
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
        }
        
        for i in 0..<copy.count {
            print("loop \(i)")
            let p = copy[i]
            if p != self.person {
                downloadGroup2.enter()
                dataService.getParents(p, onCompletion: { parents, err in
                    if parents != nil {
                        for parent in parents! {
                            if (!self.familyMembers.contains(parent) && !self.grandParents.contains(parent)) {
                                self.grandParents.append(parent)
                                self.dataService.addToSyncQ(parent)
                            }
                        }
                        for parent in parents! {
                            if (!self.familyMembers.contains(parent) && !self.grandParents.contains(parent)) {
                                downloadGroup2.enter()
                                self.dataService.getParents(parent, onCompletion: { parents2, err in
                                    if parents2 != nil {
                                        for parent2 in parents2! {
                                            self.dataService.addToSyncQ(parent2)
                                            downloadGroup2.enter()
                                            self.dataService.getParents(parent2, onCompletion: { parents3, err in
                                                if parents3 != nil {
                                                    for parent3 in parents3! {
                                                        self.dataService.addToSyncQ(parent3)
                                                    }
                                                }
                                                downloadGroup2.leave()
                                            })
                                        }
                                    }
                                    downloadGroup2.leave()
                                })
                            }
                        }
                    }
                    downloadGroup2.leave()
                })
            }
        }
        
        downloadGroup2.notify(queue: queue) {
            var copy = [LittlePerson]()
            for p in self.familyMembers {
                copy.append(p)
            }
            
            for i in 0..<copy.count {
                print("loop2 \(i)")
                let p = copy[i]
                if p != self.person {
                    downloadGroup3.enter()
                    self.dataService.getChildren(p, onCompletion: { children, err in
                        if children != nil {
                            for child in children! {
                                if (!self.familyMembers.contains(child) && !self.grandChildren.contains(child)) {
                                    self.grandChildren.append(child)
                                    self.dataService.addToSyncQ(child)
                                }
                            }
                            for child in children! {
                                if (!self.familyMembers.contains(child) && !self.grandChildren.contains(child)) {
                                    downloadGroup3.enter()
                                    self.dataService.getChildren(child, onCompletion: {children2, err2 in
                                        if children2 != nil {
                                            for child2 in children2! {
                                                if (!self.grandChildren.contains(child2)) {
                                                    self.grandChildren.append(child2)
                                                    self.dataService.addToSyncQ(child2)
                                                }
                                            }
                                        }
                                        downloadGroup3.leave()
                                    })
                                }
                            }
                        }
                        downloadGroup3.leave()
                    })
                }
            }
        }
        
        downloadGroup3.notify(queue: queue) {
            downloadGroup.leave()
        }
        
        downloadGroup.notify(queue: queue) {
            for p in self.grandChildren {
                if (!self.familyMembers.contains(p)) {
                    self.familyMembers.append(p)
                }
            }
            self.onCompletion!(self.familyMembers, nil)
        }

    }
}
