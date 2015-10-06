import Foundation

class TextValue {
	var lang:NSString?
	var value:NSString?
	
	static func convertJsonToTextValue(json:JSON) -> TextValue {
		var textValue = TextValue()
		textValue.lang = json["lang"]
		textValue.value = json["value"]
		return textValue
	}
}