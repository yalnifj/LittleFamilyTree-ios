import Foundation

class Attribution {
	var contributor:ResourceReference?
	var modified:NSDate?
	var changeMessage:NSString?
	
	static func convertJsonToAttribution(json:JSON) -> Attribution {
		var attr = Attribution()
		attr.changeMessage = json["changeMessage"]
		if json["contributor"] != nil {
			attr.contributor = ResourceReference.convertJsonToResourceReference(json["contributor"])
		}
		
		return attr
	}
}