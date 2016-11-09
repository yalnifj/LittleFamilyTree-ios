import Foundation

class LocalResource : NSObject {
	var id : Int64!
	var personId: Int64!
	var localPath : String?
	var type : String?
    
    override func isEqual(_ object: Any?) -> Bool {
        if let media = object as? LocalResource {
			if media.id > 0 && self.id > 0 {
				return media.id == self.id
			} else {
				return (media.personId == self.personId) && (media.type == self.type)
			}
        }
        return false
    }
}
func ==(lhs: LocalResource, rhs: LocalResource) -> Bool {
    if lhs.id > 0 && rhs.id > 0 {
		return lhs.id == rhs.id
	} else {
		return (lhs.personId == rhs.personId) && (lhs.type == rhs.type)
	}
}
