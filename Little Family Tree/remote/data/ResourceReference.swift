import Foundation

class ResourceReference {
	var resource:NSString?
	var resourceId:NSString?
	
	static func convertJsonToResourceReference(json:JSON) -> ResourceReference {
		let ref = ResourceReference()
		ref.resource = json["resource"].description
		ref.resourceId = json["resourceId"].description
		return ref
	}
}