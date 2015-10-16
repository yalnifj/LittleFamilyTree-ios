import Foundation

class SourceReference : HypermediaEnabledData {
	var descriptionRef:NSString?
	var attribution:Attribution?
	var qualifiers = [Qualifier]()
	
	func addAttributionFromJson(json:JSON) {
		if json["attribution"] != nil {
			self.attribution = Attribution.convertJsonToAttribution(json["attribution"])
		}
	}
	
	static func convertJsonToSourceReference(json:JSON) -> SourceReference {
		let source = SourceReference()
		source.id = json["id"].description
		source.addLinksFromJson(json)
		source.addAttributionFromJson(json)
		if json["qualifiers"] != nil {
			for q in json["qualifiers"].array! {
				source.qualifiers.append(Qualifier.convertJsonToQualifier(q))
			}
		}
		return source
	}
}