import Foundation

class Qualifier {
	var name:NSString?
	var value:NSString?
	
	static func convertJsonToQualifier(json:JSON) -> Qualifier {
		let qualifier = Qualifier()
		qualifier.name = json["name"].description
		qualifier.value = json["value"].description
		return qualifier
	}
}