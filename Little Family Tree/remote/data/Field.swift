import Foundation

class Field {
	var label:String?
	var type:String?
	var values = [FieldValue]()
	
	static func convertJsonToField(_ json:JSON) -> Field {
		let field = Field()
		field.label = json["label"].description
		field.type = json["type"].description
		if json["values"] != JSON.null {
			for val in json["values"].array! {
				field.values.append(FieldValue.convertJsonToFieldValue(val))
			}
		}
		return field
	}
}
