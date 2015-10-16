import Foundation

class Name : Conclusion {
  var type:NSString?
  var date:Date?
  var nameForms = [NameForm]()
  var preferred:Bool?
  
  static func convertJsonToName(json:JSON) -> Name {
	let name = Name()
	name.id = json["id"].description
	name.addLinksFromJson(json)
	name.addAttributionFromJson(json)
	name.type = json["type"].description
	if json["nameForms"] != nil {
		for nson in json["nameForms"].array! {
			let nameForm = NameForm.convertJsonToNameForm(nson)
			name.nameForms.append(nameForm)
		}
	}
	name.preferred = json["preferred"].bool
	return name
  }
}