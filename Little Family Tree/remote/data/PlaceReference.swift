import Foundation

class PlaceReference {
	var original:NSString?
	var descriptionRef:NSString?
	var fields = [Field]()
	var normalized = [TextValue]()
	
	static func convertJsonToPlaceReference(json:JSON) -> PlaceReference {
		let place = PlaceReference()
		place.original = json["original"].description
		place.descriptionRef = json["descriptionRef"].description
		if json["fields"] != nil {
			for field in json["fields"].array! {
				place.fields.append(Field.convertJsonToField(field))
			}
		}
		if json["normalized"] != nil {
			for tv in json["normalized"].array! {
				place.normalized.append(TextValue.convertJsonToTextValue(tv))
			}
		}
		return place
	}
}