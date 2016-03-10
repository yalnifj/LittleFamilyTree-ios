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
    var people = [LittlePerson]()
    var loadQueue = [LittlePerson]()
	var usedPeople = [Int64:LittlePerson]()
    var listener:TreeWalkerListener
    
    init(person:LittlePerson, listener:TreeWalkerListener) {
        selectedPerson = person
        dataService = DataService.getInstance()
        self.listener = listener
    }
    
    func loadFamilyMembers() {
		let dqueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        let group = dispatch_group_create()
		//-- parents
		dispatch_group_enter(group)
        dataService.getParents(selectedPerson, onCompletion: { parents, err in
            if parents != nil && parents!.count > 0 {
				for parent in parents! {
					if self.usedPeople[parent.id!] != nil {
						self.people.append(parent)
						self.usedPeople[parent.id!] = parent
						self.loadQueue.append(parent)
						
						//-- siblings
						dispatch_group_enter(group)
						self.dataService.getChildren(parent, onCompletion: {children, err in
							if children != nil && children!.count > 0 {
								for child in children! {
									if self.usedPeople[child.id!] != nil {
										self.people.append(child)
										self.usedPeople[child.id!] = child
										self.loadQueue.append(child)
									}
								}
							}
							
							//-- grandparents
							dispatch_group_enter(group)
							self.dataService.getParents(parent, onCompletion: { parents2, err in
								if parents2 != nil && parents2!.count > 0 {
									for parent in parents2! {
										if self.usedPeople[parent.id!] != nil {
											self.people.append(parent)
											self.usedPeople[parent.id!] = parent
											self.loadQueue.append(parent)
										}
									}
								}
								dispatch_group_leave(group)
							})
							dispatch_group_leave(group)
						})
					}
					
					self.parents = parents!
				}
			}
			dispatch_group_leave(group)
        })
		
		//-- children
		dispatch_group_enter(group)
		dataService.getChildren(selectedPerson, onCompletion: {children, err in
			if children != nil && children!.count > 0 {
				for child in children! {
					if self.usedPeople[child.id!] != nil {
						self.people.append(child)
						self.usedPeople[child.id!] = child
						self.loadQueue.append(child)
					}
				}
			}
			dispatch_group_leave(group)
		})
		
		dispatch_group_notify(group, dqueue) {
			if self.people.count > 4 {
				self.listener.onComplete(self.people)
			} else {
				self.loadMorePeople()
			}
		}
		
    }
    
    func loadMorePeople() {
        if loadQueue.count > 0 {
			let dqueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
            let group = dispatch_group_create()
						
			let person = loadQueue.removeFirst()
			if person.treeLevel! <= 3 {
				//-- children
				dispatch_group_enter(group)
				dataService.getChildren(person, onCompletion: {children, err in
					if children != nil && children!.count > 0 {
						for child in children! {
							if self.usedPeople[child.id!] != nil {
								self.people.append(child)
								self.usedPeople[child.id!] = child
								self.loadQueue.append(child)
							}
						}
					}
					dispatch_group_leave(group)
				})
			}
			//-- grandparents
			dispatch_group_enter(group)
			dataService.getParents(person, onCompletion: { parents2, err in
				if parents2 != nil && parents2!.count > 0 {
					for parent in parents2! {
						if self.usedPeople[parent.id!] != nil {
							self.people.append(parent)
							self.usedPeople[parent.id!] = parent
							self.loadQueue.append(parent)
						}
					}
				}
				dispatch_group_leave(group)
			})
			
			dispatch_group_notify(group, dqueue) {
				self.listener.onComplete(self.people)
			}
		} else {
			usedPeople.removeAll()
			loadFamilyMembers()
		}
    }
}

protocol TreeWalkerListener {
    func onComplete(family:[LittlePerson])
}

