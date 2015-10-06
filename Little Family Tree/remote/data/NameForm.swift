import Foundation

class NameForm {
	var lang:NSString?
	var fulltext:NSString?
	var parts = [NamePart]()
	var fields = [Field]()
	
	static func converJsonToNameForm(json:JSON) -> NameForm {
		var nameForm = NameForm()
		nameForm.fullText = json["fullText"]
		if json["parts"] != nil {
			for part in json["parts"] {
				nameForm.parts.append(NamePart.convertJsonToNamePart(part))
			}
		}
		if json["fields"] != nil {
			for field in json["fields"] {
				nameForm.fields.append(Field.convertJsonToField(field))
			}
		}
		return nameForm
	}
}
