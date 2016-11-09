import Foundation

class NamePart {
	var type:String?
	var value:String?
	var qualifiers = [Qualifier]()
	var fields = [Field]()
	
	static func convertJsonToNamePart(_ json:JSON) -> NamePart {
		let part = NamePart()
		part.type = json["type"].description
		part.value = json["value"].description
		if json["qualifiers"] != JSON.null {
			for q in json["qualifiers"].array! {
				part.qualifiers.append(Qualifier.convertJsonToQualifier(q))
			}
		}
		if json["fields"] != JSON.null {
			for field in json["fields"].array! {
				part.fields.append(Field.convertJsonToField(field))
			}
		}
		return part
	}
}
