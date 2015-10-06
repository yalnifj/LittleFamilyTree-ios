import Foundation

class Date {
  var original:NSString?
  var formal:NSString?
  var normalized = [TextValue]()
  var fields = [Field]()
  
  static func convertJsonToDate(json:JSON) -> Date {
	var date = Date()
	date.original = json["original"]
	date.formal = json["formal"]
	if json["normalized"] != nil {
		for tv in json["normalized"] {
			normalized.append(TextValue.convertJsonToTextValue(nv))
		}
	}
	if json["fields"] != nil {
		for field in json["fields"] {
			date.fields.append(Field.convertJsonToField(field))
		}
	}
	return date
  }
}