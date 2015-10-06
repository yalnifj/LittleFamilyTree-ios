import Foundation

class ResourceReference {
	var resource:NSString?
	var resourceId:NSString?
	
	static func convertJsonToResourceReference(json:JSON) -> ResourceReference {
		var ref = ResourceReference()
		ref.resource = json["resource"]
		ref.resourceId = json["resourceId"]
		return ref
	}
}