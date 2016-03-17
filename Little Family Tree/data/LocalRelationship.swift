import Foundation

class LocalRelationship : NSObject {
	var id : Int64!
	var id1 : Int64!
	var id2 : Int64!
	var type : RelationshipType!
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let rel = object as? LocalRelationship {
            return rel.id == self.id
        }
        return false
    }
}
func ==(lhs: LocalRelationship, rhs: LocalRelationship) -> Bool {
    return lhs.id == rhs.id
}