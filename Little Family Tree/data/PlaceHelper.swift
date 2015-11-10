import Foundation

class PlaceHelper {

	static func countPlaceLevels(place:String) -> Int {
		let parts = place.characters.split{$0 == " "}.map(String.init)
		return parts.count
	}
	
}