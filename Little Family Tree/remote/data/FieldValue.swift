import Foundation

class FieldValue {
	var type:String?
	var text:String?
	var datatype:String?
	var resource:String?
	var labelId:String?
	
	static func convertJsonToFieldValue(_ json:JSON) -> FieldValue {
		let value = FieldValue()
		value.type = json["type"].description
		value.text = json["text"].description
		value.datatype = json["datatype"].description
		value.resource = json["resource"].description
		value.labelId = json["labelId"].description
		return value
	}
}
