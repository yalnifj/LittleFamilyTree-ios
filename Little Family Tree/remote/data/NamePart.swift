import Foundation

class NamePart {
	var type:NSString?
	var value:NSString?
	var qualifiers = [Qualifier]()
	var fields = [Field]()
	
	static func convertJsonToNamePart(json:JSON) -> NamePart {
		var part = NamePart()
		part.type = json["type"]
		part.value = json["value"]
		if json["qualifiers"] != nil {
			for q in json["qualifiers"] {
				part.qualifiers.append(Qualifier.convertJsonToQualifier(q))
			}
		}
		if json["fields"] != nil {
			for field in json["fields"] {
				part.fields.append(Field.convertJsonToNamePart(field))
			}
		}
		return part
	}
}