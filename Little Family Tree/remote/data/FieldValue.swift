import Foundation

class FieldValue {
	var type:NSString?
	var text:NSString?
	var datatype:NSString?
	var resource:NSString?
	var labelId:NSString?
	
	static func convertJsonToFieldValue(json:JSON) -> FieldValue {
		let value = FieldValue()
		value.type = json["type"].description
		value.text = json["text"].description
		value.datatype = json["datatype"].description
		value.resource = json["resource"].description
		value.labelId = json["labelId"].description
		return value
	}
}