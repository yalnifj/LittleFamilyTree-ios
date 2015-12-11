import Foundation

class Media : NSObject {
	var id : Int64!
	var familySearchId : NSString?
	var localPath : NSString?
	var type : NSString?
}
func ==(lhs: Media, rhs: Media) -> Bool {
    return lhs.id == rhs.id
}