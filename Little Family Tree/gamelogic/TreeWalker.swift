//
//  TreeWalker.swift
//  Little Family Tree
//
//  Created by Melissa on 2/27/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import Foundation

class TreeWalker {
    var dataService:DataService
    var selectedPerson:LittlePerson
    var parents = [LittlePerson]()
    var family = [LittlePerson]()
    var loadQueue = [LittlePerson]()
    var listener:TreeWalkerListener
    
    init(person:LittlePerson, listener:TreeWalkerListener) {
        selectedPerson = person
        dataService = DataService.getInstance()
        self.listener = listener
    }
    
    func loadFamilyMembers() {
        dataService.getParents(selectedPerson, onCompletion: { parents, err in
            
        })
    }
    
    func loadMorePeople() {
        
    }
}

protocol TreeWalkerListener {
    func onComplete(family:[LittlePerson])
}