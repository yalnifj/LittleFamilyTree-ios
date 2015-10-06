import Foundation

class Qualifier {
	var name:NSString?
	var value:NSString?
	
	static func convertJsonToQualifier(json:JSON) -> Qualifier {
		var qualifier = Qualifier()
		qualifier.name = json["name"]
		qualifier.value = json["value"]
		return qualifier
	}
}