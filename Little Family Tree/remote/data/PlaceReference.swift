import Foundation

class PlaceReference {
	var original:NSString?
	var descriptionRef:NSString?
	var fields = [Field]()
	var normalized = [TextValue]()
	
	static func convertJsonToPlaceReference(json:JSON) -> PlaceReference {
		var place = PlaceReference()
		place.original = json["original"]
		place.descriptionRef = json["descriptionRef"]
		if json["fields"] != nil {
			for field in json["fields"] {
				place.fields.append(Field.convertJsonToNamePart(field))
			}
		}
		if json["normalized"] != nil {
			for tv in json["normalized"] {
				normalized.append(TextValue.convertJsonToTextValue(nv))
			}
		}
		return place
	}
}