import Foundation

class Qualifier {
	var name:String?
	var value:String?
	
	static func convertJsonToQualifier(_ json:JSON) -> Qualifier {
		let qualifier = Qualifier()
		qualifier.name = json["name"].description
		qualifier.value = json["value"].description
		return qualifier
	}
}
