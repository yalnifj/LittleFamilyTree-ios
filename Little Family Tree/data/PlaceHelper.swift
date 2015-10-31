import Foundation

class PlaceHelper {

	static func countPlaceLevels(place:NSString) -> Int {
		let parts = place.characters.split{$0 == " "}.map(String.init)
		return parts.count
	}
	
}