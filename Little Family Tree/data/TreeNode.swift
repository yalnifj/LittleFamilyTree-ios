import Foundation

class TreeNode {
	var leftPerson:LittlePerson?
	var rightPerson:LittlePerson?
	var leftNode:TreeNode?
	var rightNode:TreeNode?
	var children:[TreeNode]?
	var level:Int = 0
	var isRoot = false
	var hasParents = false
	var isChild = false
	var isInLaw = false
}