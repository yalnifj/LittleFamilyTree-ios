import Foundation

class Name : Conclusion {
  var type:NSString?
  var date:Date?
  var nameForms = [NameForm]()
  var preferred:Bool?
  
  static func convertJsonToName(_ json:JSON) -> Name {
	let name = Name()
	name.id = json["id"].description as NSString?
	name.addLinksFromJson(json)
	name.addAttributionFromJson(json)
	name.type = json["type"].description as NSString?
	if json["nameForms"] != JSON.null {
		for nson in json["nameForms"].array! {
			let nameForm = NameForm.convertJsonToNameForm(nson)
			name.nameForms.append(nameForm)
		}
	}
	name.preferred = json["preferred"].bool
	return name
  }
}
