import Foundation

class Fact : Conclusion {
	var type:String?
	var date:GedcomDate?
	var place:PlaceReference?
	var value:String?
	var qualifiers = [Qualifier]()
	var fields = [Field]()
	var primary:Bool?
	
	static func convertJsonToFact(_ json:JSON) -> Fact {
		let fact = Fact()
		fact.id = json["id"].description
		fact.addLinksFromJson(json)
		fact.addAttributionFromJson(json)
		fact.type = json["type"].description
		if json["date"] != JSON.null {
			fact.date = GedcomDate.convertJsonToDate(json["date"])
		}
		if json["place"] != JSON.null {
			fact.place = PlaceReference.convertJsonToPlaceReference(json["place"])
		}
		if json["value"] != JSON.null {
			fact.value = json["value"].description
		}
        
		if json["fields"] != JSON.null {
            for field in json["fields"].array! {
				fact.fields.append(Field.convertJsonToField(field))
			}
		}
		if json["primary"] != JSON.null {
			fact.primary = json["primary"].bool
		}
		return fact
	}
}
