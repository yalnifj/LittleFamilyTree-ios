import Foundation

class GedcomDate {
  var original:String?
  var formal:String?
  var normalized = [TextValue]()
  var fields = [Field]()
  
  static func convertJsonToDate(_ json:JSON) -> GedcomDate {
	let date = GedcomDate()
	date.original = json["original"].description
	date.formal = json["formal"].description
	if json["normalized"] != nil {
		for tv in json["normalized"].array! {
			date.normalized.append(TextValue.convertJsonToTextValue(tv))
		}
	}
	if json["fields"] != nil {
		for field in json["fields"].array! {
			date.fields.append(Field.convertJsonToField(field))
		}
	}
	return date
  }
}
