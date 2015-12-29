import foundation

class TreeSearchGame {
    var rootPerson:LittlePerson?
    var rootNode:TreeNode?
    var targetPerson:LittlePerson?
    var targetNode:TreeNode?
    var complete = false
    var clues = [TreeClue]()
    var clueNumber:Int = 0
	var recentPeople:[LittlePerson]()
	var retryCounter:Int = 0;

    init() {
        complete = true;
        clues.append(GenderTreeClue())
        clues.append(NameTreeClue())
        clues.append(FullNameTreeClue())
        clues.append(RelationshipTreeClue())
    }
   
    func findRandomPerson(root:TreeNode) {
        rootNode = root
        rootPerson = root.leftPerson
        targetPerson = nil
		let counter = 0;
        let upDown = arc4random_uniform(UInt32(3))
        if (upDown == 0) {
            if (root?.children != nil && root?.children?.count > 0) {
                targetNode = root
                while (counter < 10 && (targetPerson == nil || recentPeople.contains(targetPerson!))) {
					targetPerson = root?.children[Int(arc4random_uniform(UInt32(root?.children?.count)))]
					counter++
				}
            } else if (root?.leftNode != nil && root?.leftNode?.children != nil && root?.leftNode?.children?.count > 0) {
                targetNode = root?.leftNode
				while (counter<10 && (targetPerson == nil || recentPeople.contains(targetPerson!))) {
                	targetPerson = targetNode?.children[Int(arc4random_uniform(UInt32(targetNode?.children?.count)))]
					counter++
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
                        if (targetNode.leftNode != nil) {
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
                    case 3:
                        targetPerson = targetNode?.rightPerson
                        break
                }
				counter++
            }
        }

        if (targetPerson==nil && retryCounter < 5) {
            retryCounter++
            findRandomPerson(root)
        }
        retryCounter = 0

        complete = false
        clueNumber = arc4random_uniform(UInt32(clues.count))
    }

    func getClueText() -> String {
        return clues[clueNumber].getClueText();
    }

    func nextClue() {
        clueNumber++
        if (clueNumber >= clues.count) {
			clueNumber = 0
		}
    }

    func isMatch(node:TreeNode, isSpouse:Bool) -> Bool {
        let clue = clues[clueNumber]
        let ret = clue.isMatch(node, isSpouse: isSpouse)
        if (ret) {
			complete = true
			if (isSpouse) {
				recentPeople.append(node.rightPerson)
			}
			else {
				recentPeople.append(node.leftPerson)
			}
			if (recentPeople.count > 5) {
				recentPeople.removeFirst()
			}
		}
        return ret
    }
}

protocol TreeClue {
	func getClueText() -> String
	func isMatch(node:TreeNode, isSpouse:Bool) -> Bool
}

class NameTreeClue : TreeClue {
	@Override
	func getClueText() -> String {
		let clue = "I spy in your family tree, someone named, \(targetPerson.givenName)"
		return clue
	}

	@Override
	func isMatch(node:TreeNode, isSpouse:Bool) -> Bool {
		var person = node.leftPerson
		if (isSpouse) {
			person = node.rightPerson
		}
		if person != nil {
			if (person == targetPerson) {
				return true
			}
			if person.givenName.lowerCaseStr == targetPerson.givenName.lowerCastStr {
				return true
			}
		}
		return false
	}
}

class FullNameTreeClue : TreeClue {
	@Override
	func getClueText() -> String {
		let clue = "I spy in your family tree, someone named, \(targetPerson.name?)"
		return clue
	}

	@Override
	func isMatch(node:TreeNode, isSpouse:Bool) -> Bool {
		var person = node.leftPerson
		if (isSpouse) {
			person = node.rightPerson
		}
		if (person != nil) {
			if (person == targetPerson) {
				return true
			}
			if person.name.lowerCastStr == targetPerson.name.lowerCaseStr {
				return true
			}
		}
		return false
	}
}

class RelationshipTreeClue : TreeClue {
	@Override
	func getClueText() -> String {
		let relationship = RelationshipCalculator.getAncestralRelationship(targetNode.level, targetPerson, targetNode.leftPerson, 
			targetNode.isRoot(), targetNode.isChild, targetNode.isInLaw)
		let clue = "I spy in your family tree, someone who is your, \(relationship)"
		return clue
	}

	@Override
	func isMatch(node:TreeNode, isSpouse:Bool) -> Bool {
		var person = node.leftPerson
		if (isSpouse) {
			person = node.rightPerson
		}
		if (person != nil) {
			if (person == targetPerson) {
				return true
			}
			let relationship1 = RelationshipCalculator.getAncestralRelationship(targetNode.level, targetPerson, targetNode.leftPerson, 
				targetNode.isRoot(), targetNode.isChild, targetNode.isInLaw)
			let relationship2 = RelationshipCalculator.getAncestralRelationship(node.level, person, node.leftPerson, 
				node.isRoot(), node.isChild, node.isInLaw)
			if relationship1 == relationship2 {
				return true
			}
		}
		return false
	}
}

class GenderTreeClue : TreeClue {
	@Override
	func getClueText() -> String {
		var genderType = "boy"
		if (targetPerson.gender == GenderType.FEMALE) {
			genderType = "girl"
		}
		let clue = "I spy in your family tree, someone who is a, \(genderType)"
		return clue
	}

	@Override
	func isMatch(node:TreeNode, isSpouse:Bool) -> Bool {
		var person = node.leftPerson
		if (isSpouse) {
			person = node.rightPerson
		}
		if (person != nil) {
			if (person == targetPerson) {
				return true
			}
			let gender1 = targetPerson.gender
			let gender2 = person.gender
			if (gender1 == gender2) {
				return true
			}
		}
		return false
	}
}
