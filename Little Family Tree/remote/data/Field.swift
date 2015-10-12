import Foundation

class Field {
	var label:NSString?
	var type:NSString?
	var values = [FieldValue]()
	
	static func convertJsonToField(json:JSON) -> Field {
		var field = Field()
		field.label = json["label"].description
		field.type = json["type"].description
		if json["values"] != nil {
			for val in json["values"] {
				field.values.append(FieldValue.convertJsonToFieldValue(val))
			}
		}
		return field
	}
}