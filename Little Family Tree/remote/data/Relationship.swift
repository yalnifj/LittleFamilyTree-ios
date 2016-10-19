import Foundation

class Relationship : Subject {
	var type:NSString?
	var person1:ResourceReference?
	var person2:ResourceReference?
	var facts = [Fact]()
	var fields = [Field]()
	
	static func convertJsonToRelationships(_ json:JSON) -> [Relationship] {
		var relationships = [Relationship]()
		
        if json["relationships"] != JSON.null {
            for rson:JSON in json["relationships"].array! {
                let rel = Relationship()
                rel.id = rson["id"].description as NSString?
                rel.addLinksFromJson(rson)
                rel.type = rson["type"].description as NSString?
                rel.person1 = ResourceReference.convertJsonToResourceReference(rson["person1"])
                rel.person2 = ResourceReference.convertJsonToResourceReference(rson["person2"])
                rel.addIdentifiersFromJson(rson)
                relationships.append(rel)
            }
        }
		
        return relationships;
    }
}
