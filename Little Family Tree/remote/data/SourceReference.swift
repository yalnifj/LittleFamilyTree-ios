import Foundation

class SourceReference : HypermediaEnabledData {
	var descriptionRef:String?
	var attribution:Attribution?
	var qualifiers = [Qualifier]()
	
	func addAttributionFromJson(_ json:JSON) {
		if json["attribution"] != JSON.null {
			self.attribution = Attribution.convertJsonToAttribution(json["attribution"])
		}
	}
	
	static func convertJsonToSourceReference(_ json:JSON) -> SourceReference {
		let source = SourceReference()
		source.id = json["id"].description
		source.addLinksFromJson(json)
		source.addAttributionFromJson(json)
		if json["qualifiers"] != JSON.null {
			for q in json["qualifiers"].array! {
				source.qualifiers.append(Qualifier.convertJsonToQualifier(q))
			}
		}
		return source
	}
}
