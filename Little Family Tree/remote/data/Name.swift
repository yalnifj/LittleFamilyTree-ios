import Foundation

class Name : Conclusion {
  var type:NSString?
  var date:Date?
  var nameForms = [NameForm]()
  var preferred:Bool?
  
  static func convertJsonToName(json:JSON) -> Name {
	var name = Name()
	name.id = json["id"]?
	name.addLinksFromJson(json)
	name.addAttributionFromJson(json)
	name.type = json["type"]?
	if json["nameForms"] != nil {
		for nson in json["nameForms"] {
			var nameForm = NameForm.convertJsonToName(nson)
			nameForms.append(nameForm)
		}
	}
	name.preferred = json["preferred"]?
	return name
  }
}