import Foundation

class Date {
  var original:NSString?
  var formal:NSString?
  var normalized = [TextValue]()
  var fields = [Field]()
  
  static func convertJsonToDate(json:JSON) -> Date {
	let date = Date()
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