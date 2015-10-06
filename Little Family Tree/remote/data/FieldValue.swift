import Foundation

class FieldValue {
	var type:NSString?
	var text:NSString?
	vat datatype:NSString?
	var resource:NSString?
	var labelId:NSString?
	
	static func convertJsonToFieldValue(json:JSON) -> FieldValue {
		var value = FieldValue()
		value.type = json["type"]
		value.text = json["text"]
		value.datatype = json["datatype"]
		value.resource = json["resource"]
		value.labelId = json["labelId"]
		return value
	}
}