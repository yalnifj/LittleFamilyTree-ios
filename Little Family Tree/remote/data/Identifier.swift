import Foundation

class Identifier {
	var hasUniqueKey:Bool = false
	var value:String?
	var type:String?
	
	static func convertJsonToIdentifier(_ type:String, json:JSON) -> [Identifier] {
		var ids = [Identifier]()
        if json[type] != JSON.null {
            for val in json[type].array! {
                let id = Identifier()
                id.type = type
                id.value = val.description
                ids.append(id)
            }
        }
		return ids
	}
}
