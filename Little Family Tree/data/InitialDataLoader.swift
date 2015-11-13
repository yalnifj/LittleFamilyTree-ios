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
    
    init(person:LittlePerson, listener:StatusListener) {
        self.person = person
        self.listener = listener
    }
    
    func execute(onCompletion:PeopleResponse) {
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        let downloadGroup = dispatch_group_create()
        let dataService = DataService.getInstance()
        
        var familyMembers = [LittlePerson]()
        familyMembers.append(self.person)
        
        listener.statusChanged("Loading close family members")
        dispatch_group_enter(downloadGroup)
        dataService.getFamilyMembers(self.person, loadSpouse: true, onCompletion: { people, err in
            if people != nil {
                for person in people! {
                    if familyMembers.contains(person) == false {
                        familyMembers.append(person)
                        dataService.addToSyncQ(person)
                    }
                }
            }
            
            
            var grandParents = [LittlePerson]()
            var grandChildren = [LittlePerson]()
            for p in familyMembers {
                dispatch_group_enter(downloadGroup)
                dataService.getParents(p, onCompletion: { parents, err in
                    if parents != nil {
                        for parent in parents! {
                            if (!familyMembers.contains(parent) && !grandParents.contains(parent)) {
                                grandParents.append(parent)
                                dispatch_group_enter(downloadGroup)
                                dataService.getParents(parent, onCompletion: { parents2, err in
                                    if parents2 != nil {
                                        for parent2 in parents2! {
                                            if !familyMembers.contains(parent2) {
                                                dataService.addToSyncQ(parent2)
                                            }
                                        }
                                    }
                                })
                            }
                        }
                    }
                    dispatch_group_leave(downloadGroup)
                })
                
                dispatch_group_enter(downloadGroup)
                dataService.getChildren(p, onCompletion: {children, err in
                    if children != nil {
                        for child in children! {
                            if (!familyMembers.contains(child) && !grandChildren.contains(child)) {
                                grandChildren.append(child)
                                familyMembers.append(child)
                                dataService.addToSyncQ(child)
                                dispatch_group_enter(downloadGroup)
                                dataService.getChildren(child, onCompletion: {children2, err2 in
                                    if children2 != nil {
                                        for child2 in children2! {
                                            if (!familyMembers.contains(child2) && !grandChildren.contains(child2)) {
                                                familyMembers.append(child2)
                                                dataService.addToSyncQ(child2)
                                            }
                                        }
                                    }
                                    dispatch_group_leave(downloadGroup)
                                })
                            }
                        }
                    }
                    dispatch_group_leave(downloadGroup)
                })
            }
            dispatch_group_leave(downloadGroup)

        })
        
        dispatch_group_notify(downloadGroup, queue) {
            onCompletion(familyMembers, nil)
        }
    }
}