import Foundation

class TextValue {
	var lang:NSString?
	var value:NSString?
	
	static func convertJsonToTextValue(json:JSON) -> TextValue {
		let textValue = TextValue()
		textValue.lang = json["lang"].description
		textValue.value = json["value"].description
		return textValue
	}
}