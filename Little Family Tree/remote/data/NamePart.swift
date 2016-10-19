import Foundation

class NamePart {
	var type:NSString?
	var value:NSString?
	var qualifiers = [Qualifier]()
	var fields = [Field]()
	
	static func convertJsonToNamePart(_ json:JSON) -> NamePart {
		let part = NamePart()
		part.type = json["type"].description as NSString?
		part.value = json["value"].description as NSString?
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
