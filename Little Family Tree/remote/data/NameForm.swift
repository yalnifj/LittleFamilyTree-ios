import Foundation

class NameForm {
	var lang:String?
	var fulltext:String?
	var parts = [NamePart]()
	var fields = [Field]()
	
	static func convertJsonToNameForm(_ json:JSON) -> NameForm {
		let nameForm = NameForm()
		nameForm.fulltext = json["fullText"].description
		if json["parts"] != JSON.null {
			for part in json["parts"].array! {
				nameForm.parts.append(NamePart.convertJsonToNamePart(part))
			}
		}
		if json["fields"] != JSON.null {
			for field in json["fields"].array! {
				nameForm.fields.append(Field.convertJsonToField(field))
			}
		}
		return nameForm
	}
}
