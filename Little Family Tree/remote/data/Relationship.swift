import Foundation

class Relationship : Subject {
	var type:NSString?
	var person1:ResourceReference?
	var person2:ResourceReference?
	var facts = [Fact]()
	var fields = [Field]()
	
	static func convertJsonToRelationships(json:JSON) -> [Relationship] {
		var relationships = [Relationship]()
		
        for rson:JSON in json["relationships"] {
			var rel = Relationship()
			rel.id = rson["id"]
			rel.addLinksFromJson(rson)
			rel.type = rson["type"]
			rel.person1 = ResourceReference.convertJsonToResourceReference(rson["person1"])
			rel.person2 = ResourceReference.convertJsonToResourceReference(rson["person1"])
			rel.addIdentifiersFromJson(rson)
			relationships.append(rel)
		}
		
        return relationships;
    }
}