import Foundation

class Attribution {
	var contributor:ResourceReference?
	var modified:Foundation.Date?
	var changeMessage:NSString?
	
	static func convertJsonToAttribution(_ json:JSON) -> Attribution {
		let attr = Attribution()
		attr.changeMessage = json["changeMessage"].description as NSString?
		if json["contributor"] != JSON.null {
			attr.contributor = ResourceReference.convertJsonToResourceReference(json["contributor"])
		}
		
		return attr
	}
}
