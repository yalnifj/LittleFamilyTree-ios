import Foundation

class Fact : Conclusion {
	var type:NSString?
	var date:Date?
	var place:PlaceReference?
	var value:NSString?
	var qualifiers = [Qualifier]()
	var fields = [Field]()
	var primary:Bool?
	
	static func convertJsonToFact(_ json:JSON) -> Fact {
		let fact = Fact()
		fact.id = json["id"].description
		fact.addLinksFromJson(json)
		fact.addAttributionFromJson(json)
		fact.type = json["type"].description
		if json["date"] != nil {
			fact.date = Date.convertJsonToDate(json["date"])
		}
		if json["place"] != nil {
			fact.place = PlaceReference.convertJsonToPlaceReference(json["place"])
		}
		if json["value"] != nil {
			fact.value = json["value"].description
		}
        
		if json["fields"] != nil {
            for field in json["fields"].array! {
				fact.fields.append(Field.convertJsonToField(field))
			}
		}
		if json["primary"] != nil {
			fact.primary = json["primary"].bool
		}
		return fact
	}
}
