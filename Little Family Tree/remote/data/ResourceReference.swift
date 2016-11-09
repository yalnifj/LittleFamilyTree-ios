import Foundation

class ResourceReference {
	var resource:String?
	var resourceId:String?
	
	static func convertJsonToResourceReference(_ json:JSON) -> ResourceReference {
		let ref = ResourceReference()
		ref.resource = json["resource"].description
		ref.resourceId = json["resourceId"].description
		return ref
	}
}
