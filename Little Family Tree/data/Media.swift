import Foundation

class Media : NSObject {
	var id : Int64!
	var familySearchId : NSString?
	var localPath : NSString?
	var type : NSString?
    
    override func isEqual(_ object: Any?) -> Bool {
        if let media = object as? Media {
            return media.id == self.id
        }
        return false
    }
}
func ==(lhs: Media, rhs: Media) -> Bool {
    return lhs.id == rhs.id
}
