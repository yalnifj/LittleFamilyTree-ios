import Foundation

class TextValue {
	var lang:NSString?
	var value:NSString?
	
	static func convertJsonToTextValue(_ json:JSON) -> TextValue {
		let textValue = TextValue()
		textValue.lang = json["lang"].description as NSString?
		textValue.value = json["value"].description as NSString?
		return textValue
	}
}
