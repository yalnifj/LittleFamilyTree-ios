import Foundation

class NamePart {
	var type:NSString?
	var value:NSString?
	var qualifiers = [Qualifier]()
	var fields = [Field]()
	
	static func convertJsonToNamePart(json:JSON) -> NamePart {
		let part = NamePart()
		part.type = json["type"].description
		part.value = json["value"].description
		if json["qualifiers"] != nil {
			for q in json["qualifiers"].array! {
				part.qualifiers.append(Qualifier.convertJsonToQualifier(q))
			}
		}
		if json["fields"] != nil {
			for field in json["fields"].array! {
				part.fields.append(Field.convertJsonToField(field))
			}
		}
		return part
	}
}