import Foundation

class Conclusion : HypermediaEnabledData {
	var lang:NSString?
	var confidence:NSString?
	var sources = [SourceReference]()
	var notes = [Note]()
	var attribution:Attribution?
	var analysis:ResourceReference?
	
	func addAttributionFromJson(_ json:JSON) {
		if json["attribution"] != nil {
			self.attribution = Attribution.convertJsonToAttribution(json["attribution"])
		}
	}
}
