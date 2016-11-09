import Foundation

class PlaceReference {
	var original:String?
	var descriptionRef:String?
	var fields = [Field]()
	var normalized = [TextValue]()
	
	static func convertJsonToPlaceReference(_ json:JSON) -> PlaceReference {
		let place = PlaceReference()
		place.original = json["original"].description
		place.descriptionRef = json["descriptionRef"].description
		if json["fields"] != JSON.null {
			for field in json["fields"].array! {
				place.fields.append(Field.convertJsonToField(field))
			}
		}
		if json["normalized"] != JSON.null {
			for tv in json["normalized"].array! {
				place.normalized.append(TextValue.convertJsonToTextValue(tv))
			}
		}
		return place
	}
}
