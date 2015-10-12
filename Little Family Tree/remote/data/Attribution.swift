import Foundation

class Attribution {
	var contributor:ResourceReference?
	var modified:NSDate?
	var changeMessage:NSString?
	
	static func convertJsonToAttribution(json:JSON) -> Attribution {
		let attr = Attribution()
		attr.changeMessage = json["changeMessage"].description
		if json["contributor"] != nil {
			attr.contributor = ResourceReference.convertJsonToResourceReference(json["contributor"])
		}
		
		return attr
	}
}