import Foundation

class Field {
	var label:NSString?
	var type:NSString?
	var values = [FieldValue]()
	
	static func convertJsonToField(_ json:JSON) -> Field {
		let field = Field()
		field.label = json["label"].description as NSString?
		field.type = json["type"].description as NSString?
		if json["values"] != JSON.null {
			for val in json["values"].array! {
				field.values.append(FieldValue.convertJsonToFieldValue(val))
			}
		}
		return field
	}
}
