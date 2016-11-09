import Foundation

class Attribution {
	var contributor:ResourceReference?
	var modified:Foundation.Date?
	var changeMessage:String?
	
	static func convertJsonToAttribution(_ json:JSON) -> Attribution {
		let attr = Attribution()
		attr.changeMessage = json["changeMessage"].description
		if json["contributor"] != JSON.null {
			attr.contributor = ResourceReference.convertJsonToResourceReference(json["contributor"])
		}
		
		return attr
	}
}
