import Foundation

class Fact : Conclusion {
	var type:NSString?
	var date:Date?
	var place:PlaceReference?
	var value:NSString?
	var qualifiers = [Qualifier]()
	var fields = [Field]()
	var primary:Bool?
	
	static func convertJsonToFact(json:JSON) -> Fact {
		var fact = Fact()
		fact.id = json["id"]?
		fact.addLinksFromJson(json)
		fact.addAttributionFromJson(json)
		fact.type = json["type"]
		if json["date"] != nil {
			fact.date = Date.convertJsonToDate(json["date"])
		}
		if json["place"] != nil {
			fact.place = PlaceReference.convertJsonToPlaceReference(json["place"])
		}
		if json["value"] != nil {
			value = json["value"]
		}
		if json["fields"] != nil {
			for field in json["fields"] {
				fact.fields.append(Field.convertJsonToField(field))
			}
		}
		if json["primary"] != nil {
			fact.primary = json["primary"]
		}
		return fact
	}
}