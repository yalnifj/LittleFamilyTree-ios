import Foundation

class LocalRelationship : NSObject {
	var id : Int64!
	var id1 : Int64!
	var id2 : Int64!
	var type : RelationshipType!
}
func ==(lhs: LocalRelationship, rhs: LocalRelationship) -> Bool {
    return lhs.id == rhs.id
}