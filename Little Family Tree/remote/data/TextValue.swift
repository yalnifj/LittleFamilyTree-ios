import Foundation

class TextValue {
	var lang:String?
	var value:String?
	
	static func convertJsonToTextValue(_ json:JSON) -> TextValue {
		let textValue = TextValue()
		textValue.lang = json["lang"].description
		textValue.value = json["value"].description
		return textValue
	}
}
