import Foundation

class Qualifier {
	var name:NSString?
	var value:NSString?
	
	static func convertJsonToQualifier(_ json:JSON) -> Qualifier {
		let qualifier = Qualifier()
		qualifier.name = json["name"].description as NSString?
		qualifier.value = json["value"].description as NSString?
		return qualifier
	}
}
