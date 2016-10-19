//
//  TreeWalker.swift
//  Little Family Tree
//
//  Created by Melissa on 2/27/16.
//  Copyright © 2016 Melissa. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class TreeWalker {
    var dataService:DataService
    var selectedPerson:LittlePerson
    var parents = [LittlePerson]()
    var people = [LittlePerson]()
    var loadQueue = [LittlePerson]()
	var usedPeople = [Int64:LittlePerson]()
    var listener:TreeWalkerListener
	var resusePeople = false
    
    init(person:LittlePerson, listener:TreeWalkerListener, reusePeople:Bool) {
        selectedPerson = person
        dataService = DataService.getInstance()
        self.listener = listener
		self.resusePeople = reusePeople
    }
    
    func loadFamilyMembers() {
		let dqueue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background)
        let group = DispatchGroup()
		//-- parents
		group.enter()
        dataService.getParents(selectedPerson, onCompletion: { parents, err in
            if parents != nil && parents!.count > 0 {
				for parent in parents! {
					if (self.resusePeople && !self.people.contains(parent)) || self.usedPeople[parent.id!] == nil {
						self.people.append(parent)
						self.loadQueue.append(parent)
						
						//-- siblings
						group.enter()
						self.dataService.getChildren(parent, onCompletion: {children, err in
							if children != nil && children!.count > 0 {
								for child in children! {
									if (self.resusePeople && !self.people.contains(child)) || self.usedPeople[child.id!] == nil {
										self.people.append(child)
										self.loadQueue.append(child)
									}
								}
							}
							
							//-- grandparents
							group.enter()
							self.dataService.getParents(parent, onCompletion: { parents2, err in
								if parents2 != nil && parents2!.count > 0 {
									for parent in parents2! {
										if (self.resusePeople && !self.people.contains(parent)) || self.usedPeople[parent.id!] == nil {
											self.people.append(parent)
											self.loadQueue.append(parent)
										}
									}
								}
								group.leave()
							})
							group.leave()
						})
					}
				}
                self.parents = parents!
			}
			group.leave()
        })
		
		//-- children
		group.enter()
		dataService.getChildren(selectedPerson, onCompletion: {children, err in
			if children != nil && children!.count > 0 {
				for child in children! {
					if self.usedPeople[child.id!] == nil || (self.resusePeople && !self.people.contains(child)) {
						self.people.append(child)
						self.loadQueue.append(child)
					}
				}
			}
			group.leave()
		})
		
		group.notify(queue: dqueue) {
			if self.people.count > 4 {
				self.listener.onComplete(self.people)
			} else {
				self.loadMorePeople()
			}
		}
		
    }
    
    func loadMorePeople() {
        if loadQueue.count > 0 {
			let dqueue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background)
            let group = DispatchGroup()
						
			let person = loadQueue.removeFirst()
			if person.treeLevel != nil && person.treeLevel! <= 2 {
				//-- children
				group.enter()
				dataService.getChildren(person, onCompletion: {children, err in
					if children != nil && children!.count > 0 {
						for child in children! {
							if (self.resusePeople && !self.people.contains(child)) || self.usedPeople[child.id!] == nil {
								self.people.append(child)
								self.loadQueue.append(child)
							}
						}
					}
					group.leave()
				})
			}
			//-- grandparents
			group.enter()
			dataService.getParents(person, onCompletion: { parents2, err in
				if parents2 != nil && parents2!.count > 0 {
					for parent in parents2! {
						if (self.resusePeople && !self.people.contains(parent)) || self.usedPeople[parent.id!] == nil {
							self.people.append(parent)
							self.loadQueue.append(parent)
						}
					}
				}
				group.leave()
			})
			
			if self.resusePeople && person.treeLevel != nil && person.treeLevel > 5 {
				if !self.loadQueue.contains(self.selectedPerson) {
					loadQueue.insert(self.selectedPerson, at: 0)
				}
			}
			
			group.notify(queue: dqueue) {
				self.listener.onComplete(self.people)
			}
		} else {
			usedPeople.removeAll()
			loadFamilyMembers()
		}
    }
    
    func usePerson(_ person:LittlePerson) {
        self.usedPeople[person.id!] = person
        self.people.removeObject(person)
    }
}

protocol TreeWalkerListener {
    func onComplete(_ family:[LittlePerson])
}

