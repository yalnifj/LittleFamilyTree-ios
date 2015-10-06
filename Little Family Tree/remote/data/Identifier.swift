import Foundation

class Identifier {
	var hasUniqueKey:Bool = false
	var value:NSString?
	var type:NSString?
	
	static func convertJsonToIdentifier(type:NSString, json:JSON) -> [Identifier] {
		var ids = [Identifier]()
		for val in json[type].values {
			var id = Identifier()
			id.type = type
			id.value = val
			ids.append(id)
		}
		return ids
	}
}