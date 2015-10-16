import Foundation

class NameForm {
	var lang:NSString?
	var fulltext:NSString?
	var parts = [NamePart]()
	var fields = [Field]()
	
	static func convertJsonToNameForm(json:JSON) -> NameForm {
		let nameForm = NameForm()
		nameForm.fulltext = json["fullText"].description
		if json["parts"] != nil {
			for part in json["parts"].array! {
				nameForm.parts.append(NamePart.convertJsonToNamePart(part))
			}
		}
		if json["fields"] != nil {
			for field in json["fields"].array! {
				nameForm.fields.append(Field.convertJsonToField(field))
			}
		}
		return nameForm
	}
}
