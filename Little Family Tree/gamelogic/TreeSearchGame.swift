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


class TreeSearchGame {
    var rootPerson:LittlePerson?
    var rootNode:TreeNode?
    var targetPerson:LittlePerson?
    var targetNode:TreeNode?
    var complete = false
    var clues = [TreeClue]()
    var clueNumber:Int = 0
	var recentPeople = [LittlePerson]()
	var retryCounter:Int = 0;
    var me:LittlePerson

    init(me:LittlePerson) {
        complete = true;
        self.me = me
        clues.append(GenderTreeClue())
        clues.append(NameTreeClue())
        clues.append(FullNameTreeClue())
        clues.append(RelationshipTreeClue(me: me))
    }
   
    func findRandomPerson(_ root:TreeNode) {
        rootNode = root
        rootPerson = root.leftPerson
        targetPerson = nil
		var counter = 0;
        let upDown = arc4random_uniform(UInt32(3))
        if (upDown == 0) {
            if (root.children != nil && root.children?.count > 0) {
                targetNode = root
                while (counter < 10 && (targetPerson == nil || recentPeople.contains(targetPerson!))) {
					let cnode = root.children?[Int(arc4random_uniform(UInt32((root.children?.count)!)))]
                    targetPerson = cnode!.leftPerson
                    if targetPerson == nil {
                        targetPerson = cnode!.rightPerson
                    }
					counter += 1
				}
            } else if (root.leftNode != nil && root.leftNode?.children != nil && root.leftNode?.children?.count > 0) {
                targetNode = root.leftNode
				while (counter<10 && (targetPerson == nil || recentPeople.contains(targetPerson!))) {
                    let c = Int(arc4random_uniform(UInt32((targetNode?.children!.count)!)))
                	let cnode = targetNode?.children![c]
                    targetPerson = cnode!.leftPerson
                    if targetPerson == nil {
                        targetPerson = cnode!.rightPerson
                    }
					counter += 1
				}
            }
        }
        if (targetPerson == nil) {
            targetNode = root
            let p = arc4random_uniform(UInt32(2))
            if (targetNode?.leftNode != nil) {
				targetNode = targetNode?.leftNode
			}
            if (p > 0 && targetNode?.rightNode != nil) {
				targetNode = targetNode?.rightNode
			}
            while (counter < 10 && (targetPerson == nil || recentPeople.contains(targetPerson!))) {
                let n = arc4random_uniform(UInt32(4))
                switch (n) {
                    case 0:
                        if (targetNode?.leftNode != nil) {
							targetNode = targetNode?.leftNode
						}
                        else {
                            targetPerson = targetNode?.leftPerson
                        }
                        break
                    case 1:
                        if (targetNode?.rightNode != nil) {
							targetNode = targetNode?.rightNode
						}
                        else {
							targetPerson = targetNode?.rightPerson
						}
                        break
                    case 2:
                        targetPerson = targetNode?.leftPerson
                        break
                    default:
                        targetPerson = targetNode?.rightPerson
                        break
                }
				counter += 1
            }
        }

        if (targetPerson==nil && retryCounter < 10) {
            retryCounter += 1
            findRandomPerson(root)
        }
        retryCounter = 0

        complete = false
        clueNumber = Int(arc4random_uniform(UInt32(clues.count)))
    }

    func getClueText() -> String {
        if targetPerson != nil {
            return clues[clueNumber].getClueText(targetPerson!);
        } else {
            return ""
        }
    }

    func nextClue() {
        clueNumber += 1
        if (clueNumber >= clues.count) {
			clueNumber = 0
		}
    }

    func isMatch(_ person:LittlePerson) -> Bool {
        if (targetPerson == nil) {
            return false
        }
        let clue = clues[clueNumber]
        let ret = clue.isMatch(person, targetPerson: targetPerson!)
        if (ret) {
			complete = true
            recentPeople.append(person)
			if (recentPeople.count > 5) {
				recentPeople.removeFirst()
			}
		}
        return ret
    }
}

protocol TreeClue {
	func getClueText(_ targetPerson:LittlePerson) -> String
    func isMatch(_ person:LittlePerson, targetPerson:LittlePerson) -> Bool
}

class NameTreeClue : TreeClue {
    func getClueText(_ targetPerson:LittlePerson) -> String {
		let clue = "I spy in your family tree, someone named, \(targetPerson.givenName!)"
		return clue
	}

    func isMatch(_ person:LittlePerson, targetPerson:LittlePerson) -> Bool {
        if (person == targetPerson) {
            return true
        }
        if person.givenName?.lowercased() == targetPerson.givenName?.lowercased() {
            return true
        }
		return false
	}
}

class FullNameTreeClue : TreeClue {
	
	func getClueText(_ targetPerson:LittlePerson) -> String {
		let clue = "I spy in your family tree, someone named, \(targetPerson.name!)"
		return clue
	}

	func isMatch(_ person:LittlePerson, targetPerson:LittlePerson) -> Bool {
        if (person == targetPerson) {
            return true
        }
        if person.name?.lowercased() == targetPerson.name?.lowercased() {
            return true
        }
		return false
	}
}

class RelationshipTreeClue : TreeClue {
    var me:LittlePerson
    init(me:LittlePerson) {
        self.me = me
    }

	func getClueText(_ targetPerson:LittlePerson) -> String {
        let relationship = RelationshipCalculator.getRelationship(me, p: targetPerson)
		let clue = "I spy in your family tree, someone who is your, \(relationship)"
		return clue
	}

	func isMatch(_ person:LittlePerson, targetPerson:LittlePerson) -> Bool {
        if (person == targetPerson) {
            return true
        }
        let relationship1 = RelationshipCalculator.getRelationship(me, p: targetPerson)
        let relationship2 = RelationshipCalculator.getRelationship(me, p: person)
        if relationship1 == relationship2 {
            return true
        }
		
		return false
	}
}

class GenderTreeClue : TreeClue {

	func getClueText(_ targetPerson:LittlePerson) -> String {
		var genderType = "boy"
		if (targetPerson.gender == GenderType.female) {
			genderType = "girl"
		}
		let clue = "I spy in your family tree, someone who is a, \(genderType)"
		return clue
	}

	func isMatch(_ person:LittlePerson, targetPerson:LittlePerson) -> Bool {
        if (person == targetPerson) {
            return true
        }
        let gender1 = targetPerson.gender
        let gender2 = person.gender
        if (gender1 == gender2) {
            return true
        }
		return false
	}
}
