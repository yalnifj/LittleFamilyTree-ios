import Foundation

class Identifier {
	var hasUniqueKey:Bool = false
	var value:NSString?
	var type:NSString?
	
	static func convertJsonToIdentifier(type:NSString, json:JSON) -> [Identifier] {
		var ids = [Identifier]()
        let stype = type as String
        if json[stype] != nil {
            for val in json[stype].array! {
                let id = Identifier()
                id.type = type
                id.value = val.description
                ids.append(id)
            }
        }
		return ids
	}
}